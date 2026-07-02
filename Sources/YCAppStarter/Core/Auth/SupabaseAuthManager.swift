import Foundation
import AuthenticationServices
import CryptoKit
import UIKit
#if canImport(Supabase)
import Supabase
#endif

@MainActor
final class SupabaseAuthManager: AuthManaging, ObservableObject {
    @Published private(set) var snapshot: AuthSessionSnapshot = .signedOut
    private(set) var lastEventMessage: String?

    private let supabaseURLString: String
    private let supabaseKey: String
    private let redirectScheme: String
    private let logger: AppLogging

    #if canImport(Supabase)
    private var client: SupabaseClient?
    #endif

    var isConfigured: Bool {
        guard URL(string: supabaseURLString) != nil else { return false }
        return !supabaseKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(supabaseURL: String, supabaseKey: String, redirectScheme: String, logger: AppLogging) {
        self.supabaseURLString = supabaseURL
        self.supabaseKey = supabaseKey
        self.redirectScheme = redirectScheme
        self.logger = logger
        #if canImport(Supabase)
        if let url = URL(string: supabaseURL), supabaseKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            self.client = SupabaseClient(supabaseURL: url, supabaseKey: supabaseKey)
        }
        #endif
    }

    func refreshSession() async {
        #if canImport(Supabase)
        guard let client else {
            markEvent("Supabase is not configured.")
            return
        }
        do {
            let session = try await client.auth.session
            snapshot = makeSnapshot(user: session.user, accessToken: session.accessToken, expiresAt: nil, provider: nil)
            if let profile = try? await fetchProfile() {
                snapshot.profile = profile
            }
            markEvent("Session refreshed.")
        } catch {
            snapshot = .signedOut
            markEvent("No active Supabase session: \(error.localizedDescription)")
        }
        #else
        markEvent("Supabase package is unavailable in this build.")
        #endif
    }

    func signUp(email: String, password: String) async throws -> AuthUser {
        try validateEmailPassword(email: email, password: password)
        #if canImport(Supabase)
        guard let client else { throw AuthClientError.missingSupabaseConfiguration }
        do {
            let response = try await client.auth.signUp(email: email, password: password)
            let user = makeUser(from: response.user)
            snapshot.user = user
            snapshot.lastEventMessage = "Signed up with email. Confirm email may still be required."
            markEvent(snapshot.lastEventMessage ?? "Signed up.")
            return user
        } catch {
            throw AuthClientError.transport(error.localizedDescription)
        }
        #else
        throw AuthClientError.unsupportedInCurrentBuild
        #endif
    }

    func signIn(email: String, password: String) async throws -> AuthUser {
        try validateEmailPassword(email: email, password: password)
        #if canImport(Supabase)
        guard let client else { throw AuthClientError.missingSupabaseConfiguration }
        do {
            let session = try await client.auth.signIn(email: email, password: password)
            snapshot = makeSnapshot(user: session.user, accessToken: session.accessToken, expiresAt: nil, provider: "email")
            if let profile = try? await fetchProfile() { snapshot.profile = profile }
            markEvent("Signed in with email.")
            return snapshot.user!
        } catch {
            throw AuthClientError.transport(error.localizedDescription)
        }
        #else
        throw AuthClientError.unsupportedInCurrentBuild
        #endif
    }

    func signInWithApple(container: AppContainer) async throws -> AuthUser {
        guard AuthLaunchPolicy.make(from: container.requireService(RemoteConfigServicing.self)).allowApple else { throw AuthClientError.disabledByPolicy }
        #if canImport(Supabase)
        guard let client else { throw AuthClientError.missingSupabaseConfiguration }
        let rawNonce = NonceGenerator.randomNonceString()
        let hashedNonce = NonceGenerator.sha256(rawNonce)
        let credential = try await AppleSignInCoordinator.signIn(nonce: hashedNonce)
        guard let tokenData = credential.identityToken, let idToken = String(data: tokenData, encoding: .utf8) else {
            throw AuthClientError.missingAppleIdentityToken
        }
        do {
            let session = try await client.auth.signInWithIdToken(
                credentials: OpenIDConnectCredentials(
                    provider: .apple,
                    idToken: idToken,
                    nonce: rawNonce
                )
            )
            if let fullName = credential.fullName?.formattedName, !fullName.isEmpty {
                try? await updateAppleNameMetadata(fullName: fullName, givenName: credential.fullName?.givenName, familyName: credential.fullName?.familyName)
            }
            snapshot = makeSnapshot(user: session.user, accessToken: session.accessToken, expiresAt: nil, provider: "apple")
            if let profile = try? await fetchProfile() { snapshot.profile = profile }
            markEvent("Signed in with Apple.")
            return snapshot.user!
        } catch {
            throw AuthClientError.transport(error.localizedDescription)
        }
        #else
        throw AuthClientError.unsupportedInCurrentBuild
        #endif
    }

    func signInAnonymously() async throws -> AuthUser {
        #if canImport(Supabase)
        guard let client else { throw AuthClientError.missingSupabaseConfiguration }
        do {
            let session = try await client.auth.signInAnonymously()
            snapshot = makeSnapshot(user: session.user, accessToken: session.accessToken, expiresAt: nil, provider: "anonymous")
            markEvent("Signed in anonymously.")
            return snapshot.user!
        } catch {
            throw AuthClientError.transport(error.localizedDescription)
        }
        #else
        throw AuthClientError.unsupportedInCurrentBuild
        #endif
    }

    func signOut() async throws {
        #if canImport(Supabase)
        guard let client else { throw AuthClientError.missingSupabaseConfiguration }
        try await client.auth.signOut()
        snapshot = .signedOut
        markEvent("Signed out.")
        #else
        throw AuthClientError.unsupportedInCurrentBuild
        #endif
    }

    func fetchProfile() async throws -> UserProfile? {
        #if canImport(Supabase)
        guard let client else { throw AuthClientError.missingSupabaseConfiguration }
        guard let user = snapshot.user else { return nil }
        let dto: SupabaseProfileDTO = try await client
            .from("profiles")
            .select()
            .eq("id", value: user.id)
            .single()
            .execute()
            .value
        let profile = dto.toDomain()
        snapshot.profile = profile
        return profile
        #else
        return nil
        #endif
    }

    func upsertProfile(_ profile: UserProfile) async throws {
        #if canImport(Supabase)
        guard let client else { throw AuthClientError.missingSupabaseConfiguration }
        let dto = SupabaseProfileDTO(profile: profile)
        try await client.from("profiles").upsert(dto).execute()
        snapshot.profile = profile
        markEvent("Profile synced.")
        #else
        throw AuthClientError.unsupportedInCurrentBuild
        #endif
    }

    func syncMembership(isPremium: Bool, entitlementID: String?) async throws {
        guard var profile = snapshot.profile ?? snapshot.user.map(UserProfile.empty(user:)) else { return }
        profile.isPremium = isPremium
        profile.entitlementID = entitlementID
        profile.updatedAt = Date()
        try await upsertProfile(profile)
        markEvent("Membership synced.")
    }

    func syncAIUsage(delta: Int) async throws {
        guard var profile = snapshot.profile ?? snapshot.user.map(UserProfile.empty(user:)) else { return }
        profile.aiUsedToday = max(0, profile.aiUsedToday + delta)
        profile.updatedAt = Date()
        try await upsertProfile(profile)
        markEvent("AI usage synced.")
    }

    func accessToken() async -> String? {
        #if canImport(Supabase)
        guard let client else { return nil }
        return try? await client.auth.session.accessToken
        #else
        return nil
        #endif
    }


    func handleMagicLinkCallback(url: URL) async throws {
        #if canImport(Supabase)
        guard client != nil else { throw AuthClientError.missingSupabaseConfiguration }
        // Supabase SDK callback APIs may change across releases. The starter intentionally keeps
        // this hook isolated. If your SDK exposes session exchange from callback URL, call it here,
        // then refresh the session. The fallback still records the event and attempts refresh.
        markEvent("Received magic-link callback: \(url.scheme ?? "unknown")://\(url.host ?? "")")
        await refreshSession()
        #else
        throw AuthClientError.unsupportedInCurrentBuild
        #endif
    }

    func requestAccountDeletion(reason: String?) async throws {
        #if canImport(Supabase)
        guard let client else { throw AuthClientError.missingSupabaseConfiguration }
        guard let user = snapshot.user else { throw AuthClientError.transport("You must be signed in to request account deletion.") }
        let request = PrivacyRequestDTO(user_id: user.id, request_type: "delete_account", reason: reason, status: "pending")
        try await client.from("privacy_requests").insert(request).execute()
        markEvent("Account deletion request submitted.")
        #else
        throw AuthClientError.unsupportedInCurrentBuild
        #endif
    }

    func requestDataExport() async throws {
        #if canImport(Supabase)
        guard let client else { throw AuthClientError.missingSupabaseConfiguration }
        guard let user = snapshot.user else { throw AuthClientError.transport("You must be signed in to request data export.") }
        let request = PrivacyRequestDTO(user_id: user.id, request_type: "data_export", reason: nil, status: "pending")
        try await client.from("privacy_requests").insert(request).execute()
        markEvent("Data export request submitted.")
        #else
        throw AuthClientError.unsupportedInCurrentBuild
        #endif
    }

    private func markEvent(_ message: String) {
        lastEventMessage = message
        snapshot.lastEventMessage = message
        logger.info("Auth: \(message)")
    }

    #if canImport(Supabase)
    private func makeUser(from user: User) -> AuthUser {
        AuthUser(
            id: user.id.uuidString,
            email: user.email,
            displayName: nil,
            avatarURL: nil,
            isAnonymous: false
        )
    }

    private func makeSnapshot(user: User, accessToken: String, expiresAt: Date?, provider: String?) -> AuthSessionSnapshot {
        AuthSessionSnapshot(
            user: makeUser(from: user),
            profile: nil,
            accessTokenPreview: tokenPreview(accessToken),
            expiresAt: expiresAt,
            provider: provider,
            lastEventMessage: lastEventMessage
        )
    }

    private func tokenPreview(_ token: String) -> String {
        guard token.count > 16 else { return token }
        return "\(token.prefix(8))…\(token.suffix(6))"
    }

    private func updateAppleNameMetadata(fullName: String, givenName: String?, familyName: String?) async throws {
        guard let client else { return }
        try await client.auth.update(
            user: UserAttributes(
                data: [
                    "full_name": .string(fullName),
                    "given_name": .string(givenName ?? ""),
                    "family_name": .string(familyName ?? "")
                ]
            )
        )
    }
    #endif
}



#if canImport(Supabase)
private struct PrivacyRequestDTO: Codable {
    let user_id: String
    let request_type: String
    let reason: String?
    let status: String
}
#endif

#if canImport(Supabase)
private struct SupabaseProfileDTO: Codable {
    let id: String
    let email: String?
    let display_name: String?
    let avatar_url: String?
    let entitlement_id: String?
    let is_premium: Bool
    let ai_daily_quota: Int
    let ai_used_today: Int
    let created_at: Date?
    let updated_at: Date?

    init(profile: UserProfile) {
        self.id = profile.id
        self.email = profile.email
        self.display_name = profile.displayName
        self.avatar_url = profile.avatarURL?.absoluteString
        self.entitlement_id = profile.entitlementID
        self.is_premium = profile.isPremium
        self.ai_daily_quota = profile.aiDailyQuota
        self.ai_used_today = profile.aiUsedToday
        self.created_at = profile.createdAt
        self.updated_at = profile.updatedAt
    }

    func toDomain() -> UserProfile {
        UserProfile(
            id: id,
            email: email,
            displayName: display_name,
            avatarURL: avatar_url.flatMap(URL.init(string:)),
            entitlementID: entitlement_id,
            isPremium: is_premium,
            aiDailyQuota: ai_daily_quota,
            aiUsedToday: ai_used_today,
            createdAt: created_at,
            updatedAt: updated_at
        )
    }
}
#endif

private enum NonceGenerator {
    static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        while remainingLength > 0 {
            var randoms = [UInt8](repeating: 0, count: 16)
            let status = SecRandomCopyBytes(kSecRandomDefault, randoms.count, &randoms)
            if status != errSecSuccess { fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(status)") }
            randoms.forEach { random in
                if remainingLength == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }

    static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
}

private final class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private static var activeCoordinator: AppleSignInCoordinator?
    private var continuation: CheckedContinuation<ASAuthorizationAppleIDCredential, Error>?

    static func signIn(nonce: String) async throws -> ASAuthorizationAppleIDCredential {
        let coordinator = AppleSignInCoordinator()
        activeCoordinator = coordinator
        return try await coordinator.perform(nonce: nonce)
    }

    private func perform(nonce: String) async throws -> ASAuthorizationAppleIDCredential {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = nonce
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            continuation?.resume(throwing: AuthClientError.missingAppleCredential)
            continuation = nil
            return
        }
        continuation?.resume(returning: credential)
        continuation = nil
        Self.activeCoordinator = nil
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let nsError = error as NSError
        if nsError.domain == ASAuthorizationError.errorDomain, nsError.code == ASAuthorizationError.canceled.rawValue {
            continuation?.resume(throwing: AuthClientError.signInCancelled)
        } else {
            continuation?.resume(throwing: AuthClientError.transport(error.localizedDescription))
        }
        continuation = nil
        Self.activeCoordinator = nil
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}

private extension PersonNameComponents {
    var formattedName: String {
        PersonNameComponentsFormatter().string(from: self).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
