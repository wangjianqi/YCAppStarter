import Foundation

struct AuthUser: Identifiable, Codable, Equatable, Hashable {
    let id: String
    var email: String?
    var displayName: String?
    var avatarURL: URL?
    var isAnonymous: Bool

    var shortID: String { String(id.prefix(8)) }
}

struct UserProfile: Identifiable, Codable, Equatable, Hashable {
    let id: String
    var email: String?
    var displayName: String?
    var avatarURL: URL?
    var entitlementID: String?
    var isPremium: Bool
    var aiDailyQuota: Int
    var aiUsedToday: Int
    var createdAt: Date?
    var updatedAt: Date?

    static func empty(user: AuthUser) -> UserProfile {
        UserProfile(
            id: user.id,
            email: user.email,
            displayName: user.displayName,
            avatarURL: user.avatarURL,
            entitlementID: nil,
            isPremium: false,
            aiDailyQuota: 0,
            aiUsedToday: 0,
            createdAt: nil,
            updatedAt: nil
        )
    }
}

struct AuthSessionSnapshot: Codable, Equatable, Hashable {
    var user: AuthUser?
    var profile: UserProfile?
    var accessTokenPreview: String?
    var expiresAt: Date?
    var provider: String?
    var lastEventMessage: String?

    var isSignedIn: Bool { user != nil }

    static let signedOut = AuthSessionSnapshot(user: nil, profile: nil, accessTokenPreview: nil, expiresAt: nil, provider: nil, lastEventMessage: nil)
}

struct AuthLaunchPolicy: Equatable, Hashable {
    let isAuthEnabled: Bool
    let requireLoginForAI: Bool
    let allowEmailPassword: Bool
    let allowApple: Bool
    let profileSyncEnabled: Bool
    let membershipSyncEnabled: Bool
    let aiUsageSyncEnabled: Bool

    @MainActor
    static func make(from remoteConfig: RemoteConfigServicing) -> AuthLaunchPolicy {
        AuthLaunchPolicy(
            isAuthEnabled: !remoteConfig.isReviewSafeModeEnabled && !remoteConfig.isGlobalKillSwitchEnabled && remoteConfig.bool(RemoteConfigKeys.authEnabled, default: true),
            requireLoginForAI: remoteConfig.bool(RemoteConfigKeys.authRequireLoginForAI, default: false),
            allowEmailPassword: remoteConfig.bool(RemoteConfigKeys.authAllowEmailPassword, default: true),
            allowApple: remoteConfig.bool(RemoteConfigKeys.authAllowApple, default: true),
            profileSyncEnabled: remoteConfig.bool(RemoteConfigKeys.profileSyncEnabled, default: true),
            membershipSyncEnabled: remoteConfig.bool(RemoteConfigKeys.membershipSyncEnabled, default: true),
            aiUsageSyncEnabled: remoteConfig.bool(RemoteConfigKeys.aiUsageSyncEnabled, default: true)
        )
    }
}

enum AuthProviderKind: String, Codable, CaseIterable, Identifiable {
    case email
    case apple
    case anonymous

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .email: return "Email"
        case .apple: return "Apple"
        case .anonymous: return "Anonymous"
        }
    }
}

enum AuthClientError: LocalizedError, Equatable {
    case disabledByPolicy
    case missingSupabaseConfiguration
    case invalidEmail
    case weakPassword
    case missingAppleCredential
    case missingAppleIdentityToken
    case signInCancelled
    case unsupportedInCurrentBuild
    case transport(String)

    var errorDescription: String? {
        switch self {
        case .disabledByPolicy: return "Authentication is disabled by launch policy."
        case .missingSupabaseConfiguration: return "Supabase URL or publishable/anon key is missing."
        case .invalidEmail: return "Email is invalid."
        case .weakPassword: return "Password must be at least 8 characters."
        case .missingAppleCredential: return "Apple credential is missing."
        case .missingAppleIdentityToken: return "Apple identity token is missing."
        case .signInCancelled: return "Sign in was cancelled."
        case .unsupportedInCurrentBuild: return "This auth operation is unavailable in the current build."
        case .transport(let message): return message
        }
    }
}
