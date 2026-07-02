import Foundation

struct WidgetKitPolicy: Hashable {
    let widgetEnabled: Bool
    let refreshMinutes: Int

    static func make(from remoteConfig: RemoteConfigServicing?) -> WidgetKitPolicy {
        guard let remoteConfig else { return WidgetKitPolicy(widgetEnabled: false, refreshMinutes: 60) }
        let launchPolicy = WidgetLaunchPolicy.make(from: remoteConfig)
        return WidgetKitPolicy(widgetEnabled: launchPolicy.widgetEnabled, refreshMinutes: launchPolicy.widgetRefreshMinutes)
    }
}
