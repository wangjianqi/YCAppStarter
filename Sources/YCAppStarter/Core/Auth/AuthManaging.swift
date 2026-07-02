import Foundation

@MainActor
protocol AuthManaging: AnyObject {
    var snapshot: AuthSessionSnapshot { get }
    var isConfigured: Bool { get }
    var lastEventMessage: String? { get }

    func refreshSession() async
    func signUp(email: String, password: String) async throws -> AuthUser
    func signIn(email: String, password: String) async throws -> AuthUser
    func signInWithApple(container: AppContainer) async throws -> AuthUser
    func signInAnonymously() async throws -> AuthUser
    func signOut() async throws
    func fetchProfile() async throws -> UserProfile?
    func upsertProfile(_ profile: UserProfile) async throws
    func syncMembership(isPremium: Bool, entitlementID: String?) async throws
    func syncAIUsage(delta: Int) async throws
    func accessToken() async -> String?

    // V2.8 Account Center + Privacy Requests.
    func handleMagicLinkCallback(url: URL) async throws
    func requestAccountDeletion(reason: String?) async throws
    func requestDataExport() async throws
}

extension AuthManaging {
    func validateEmailPassword(email: String, password: String) throws {
        guard email.contains("@") && email.contains(".") else { throw AuthClientError.invalidEmail }
        guard password.count >= 8 else { throw AuthClientError.weakPassword }
    }
}
