import Foundation

@MainActor
protocol RemoteConfigServicing: AnyObject {
    var snapshot: RemoteConfigSnapshot { get }
    var isReviewSafeModeEnabled: Bool { get }
    var isGlobalKillSwitchEnabled: Bool { get }
    var isPaywallEnabled: Bool { get }
    var isAdsEnabled: Bool { get }
    var paywallVariant: String { get }

    func refresh() async
    func value(for key: RemoteConfigKey) -> RemoteConfigValue?
    func bool(_ key: RemoteConfigKey, default defaultValue: Bool) -> Bool
    func string(_ key: RemoteConfigKey, default defaultValue: String) -> String
    func int(_ key: RemoteConfigKey, default defaultValue: Int) -> Int
    func setLocalOverride(_ value: RemoteConfigValue?, for key: RemoteConfigKey)
}

extension RemoteConfigServicing {
    var isReviewSafeModeEnabled: Bool {
        bool(RemoteConfigKeys.reviewSafeModeEnabled, default: false)
    }

    var isGlobalKillSwitchEnabled: Bool {
        bool(RemoteConfigKeys.featureKillSwitchEnabled, default: false)
    }

    var isPaywallEnabled: Bool {
        guard !isReviewSafeModeEnabled, !isGlobalKillSwitchEnabled else { return false }
        return bool(RemoteConfigKeys.paywallEnabled, default: true)
    }

    var isAdsEnabled: Bool {
        guard !isReviewSafeModeEnabled, !isGlobalKillSwitchEnabled else { return false }
        return bool(RemoteConfigKeys.adsEnabled, default: false)
    }

    var paywallVariant: String {
        string(RemoteConfigKeys.paywallVariant, default: "minimal")
    }

    func bool(_ key: RemoteConfigKey, default defaultValue: Bool) -> Bool {
        value(for: key)?.boolValue ?? defaultValue
    }

    func string(_ key: RemoteConfigKey, default defaultValue: String) -> String {
        value(for: key)?.stringValue ?? defaultValue
    }

    func int(_ key: RemoteConfigKey, default defaultValue: Int) -> Int {
        value(for: key)?.intValue ?? defaultValue
    }
}
