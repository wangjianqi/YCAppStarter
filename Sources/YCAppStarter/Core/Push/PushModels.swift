import Foundation

enum PushAuthorizationState: String, Codable, Hashable, CaseIterable, Identifiable {
    case notDetermined
    case denied
    case authorized
    case provisional
    case ephemeral
    case unknown

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .notDetermined: return "Not Determined"
        case .denied: return "Denied"
        case .authorized: return "Authorized"
        case .provisional: return "Provisional"
        case .ephemeral: return "Ephemeral"
        case .unknown: return "Unknown"
        }
    }
}

struct PushTokenSnapshot: Codable, Equatable, Hashable {
    var authorizationState: PushAuthorizationState
    var apnsTokenPreview: String?
    var fcmTokenPreview: String?
    var lastRegistrationError: String?
    var lastMessageID: String?
    var lastOpenedDeepLink: URL?
    var updatedAt: Date?

    static let empty = PushTokenSnapshot(
        authorizationState: .unknown,
        apnsTokenPreview: nil,
        fcmTokenPreview: nil,
        lastRegistrationError: nil,
        lastMessageID: nil,
        lastOpenedDeepLink: nil,
        updatedAt: nil
    )
}

struct PushLaunchPolicy: Equatable, Hashable {
    let isPushEnabled: Bool
    let marketingPushEnabled: Bool
    let transactionalPushEnabled: Bool

    @MainActor
    static func make(from remoteConfig: RemoteConfigServicing) -> PushLaunchPolicy {
        PushLaunchPolicy(
            isPushEnabled: !remoteConfig.isReviewSafeModeEnabled && !remoteConfig.isGlobalKillSwitchEnabled && remoteConfig.bool(RemoteConfigKeys.pushEnabled, default: false),
            marketingPushEnabled: remoteConfig.bool(RemoteConfigKeys.pushMarketingEnabled, default: false),
            transactionalPushEnabled: remoteConfig.bool(RemoteConfigKeys.pushTransactionalEnabled, default: true)
        )
    }
}
