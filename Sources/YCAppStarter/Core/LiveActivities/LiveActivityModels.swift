import Foundation

struct LiveActivityPolicy: Hashable {
    let liveActivityEnabled: Bool
    let dynamicIslandEnabled: Bool
    let pushUpdatesEnabled: Bool

    static func make(from remoteConfig: RemoteConfigServicing?) -> LiveActivityPolicy {
        guard let remoteConfig else {
            return LiveActivityPolicy(liveActivityEnabled: false, dynamicIslandEnabled: false, pushUpdatesEnabled: false)
        }
        let launchPolicy = WidgetLaunchPolicy.make(from: remoteConfig)
        return LiveActivityPolicy(
            liveActivityEnabled: launchPolicy.liveActivityEnabled,
            dynamicIslandEnabled: launchPolicy.dynamicIslandEnabled,
            pushUpdatesEnabled: launchPolicy.liveActivityPushUpdatesEnabled
        )
    }
}

struct LiveActivitySnapshot: Identifiable, Hashable {
    let id: String
    let title: String
    let status: String
    let progress: Double
    let updatedAt: Date
}
