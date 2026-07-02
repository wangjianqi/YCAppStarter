import Foundation

enum DeepLinkSource: String, Codable, Hashable, CaseIterable, Identifiable {
    case customScheme
    case universalLink
    case pushNotification
    case unknown

    var id: String { rawValue }
}

struct DeepLinkResult: Codable, Equatable, Hashable, Identifiable {
    let id: UUID
    let url: URL
    let source: DeepLinkSource
    let routeID: String?
    let action: String
    let handledAt: Date
    let message: String

    init(url: URL, source: DeepLinkSource, routeID: String?, action: String, message: String) {
        self.id = UUID()
        self.url = url
        self.source = source
        self.routeID = routeID
        self.action = action
        self.handledAt = Date()
        self.message = message
    }
}

struct DeepLinkLaunchPolicy: Equatable, Hashable {
    let deepLinksEnabled: Bool
    let magicLinksEnabled: Bool

    @MainActor
    static func make(from remoteConfig: RemoteConfigServicing) -> DeepLinkLaunchPolicy {
        DeepLinkLaunchPolicy(
            deepLinksEnabled: !remoteConfig.isGlobalKillSwitchEnabled && remoteConfig.bool(RemoteConfigKeys.deepLinksEnabled, default: true),
            magicLinksEnabled: !remoteConfig.isReviewSafeModeEnabled && !remoteConfig.isGlobalKillSwitchEnabled && remoteConfig.bool(RemoteConfigKeys.magicLinksEnabled, default: true)
        )
    }
}
