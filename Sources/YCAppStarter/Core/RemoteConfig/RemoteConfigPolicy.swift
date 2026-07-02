import Foundation

struct LaunchPolicy: Hashable {
    let reviewSafeModeEnabled: Bool
    let globalKillSwitchEnabled: Bool
    let paywallEnabled: Bool
    let adsEnabled: Bool
    let paywallVariant: String
    let bannerAdsEnabled: Bool
    let interstitialAdsEnabled: Bool
    let rewardedAdsEnabled: Bool
    let promotion: PromotionConfig
    let ai: AILaunchPolicy
    let widget: WidgetLaunchPolicy

    static func make(from remoteConfig: RemoteConfigServicing) -> LaunchPolicy {
        LaunchPolicy(
            reviewSafeModeEnabled: remoteConfig.isReviewSafeModeEnabled,
            globalKillSwitchEnabled: remoteConfig.isGlobalKillSwitchEnabled,
            paywallEnabled: remoteConfig.isPaywallEnabled,
            adsEnabled: remoteConfig.isAdsEnabled,
            paywallVariant: remoteConfig.paywallVariant,
            bannerAdsEnabled: remoteConfig.bool(RemoteConfigKeys.admobBannerEnabled, default: false),
            interstitialAdsEnabled: remoteConfig.bool(RemoteConfigKeys.admobInterstitialEnabled, default: false),
            rewardedAdsEnabled: remoteConfig.bool(RemoteConfigKeys.admobRewardedEnabled, default: false),
            promotion: PromotionConfig.make(from: remoteConfig),
            ai: AILaunchPolicy.make(from: remoteConfig),
            widget: WidgetLaunchPolicy.make(from: remoteConfig)
        )
    }
}

struct PromotionConfig: Hashable {
    let isEnabled: Bool
    let title: String
    let message: String

    static func make(from remoteConfig: RemoteConfigServicing) -> PromotionConfig {
        let enabled = remoteConfig.bool(RemoteConfigKeys.promotionBannerEnabled, default: false)
        return PromotionConfig(
            isEnabled: enabled && !remoteConfig.isReviewSafeModeEnabled && !remoteConfig.isGlobalKillSwitchEnabled,
            title: remoteConfig.string(RemoteConfigKeys.promotionTitle, default: ""),
            message: remoteConfig.string(RemoteConfigKeys.promotionMessage, default: "")
        )
    }
}


struct AILaunchPolicy: Hashable {
    let isEnabled: Bool
    let streamingEnabled: Bool
    let visionEnabled: Bool
    let defaultModel: String
    let dailyQuota: Int

    static func make(from remoteConfig: RemoteConfigServicing) -> AILaunchPolicy {
        let baseEnabled = remoteConfig.bool(RemoteConfigKeys.aiEnabled, default: false)
        let safeToRun = !remoteConfig.isReviewSafeModeEnabled && !remoteConfig.isGlobalKillSwitchEnabled
        return AILaunchPolicy(
            isEnabled: baseEnabled && safeToRun,
            streamingEnabled: remoteConfig.bool(RemoteConfigKeys.aiStreamingEnabled, default: false) && safeToRun,
            visionEnabled: remoteConfig.bool(RemoteConfigKeys.aiVisionEnabled, default: false) && safeToRun,
            defaultModel: remoteConfig.string(RemoteConfigKeys.aiDefaultModel, default: "gpt-5.5-mini"),
            dailyQuota: remoteConfig.int(RemoteConfigKeys.aiDailyQuota, default: 25)
        )
    }
}


struct WidgetLaunchPolicy: Hashable {
    let widgetEnabled: Bool
    let widgetRefreshMinutes: Int
    let liveActivityEnabled: Bool
    let dynamicIslandEnabled: Bool
    let liveActivityPushUpdatesEnabled: Bool

    static func make(from remoteConfig: RemoteConfigServicing) -> WidgetLaunchPolicy {
        let safeToRun = !remoteConfig.isReviewSafeModeEnabled && !remoteConfig.isGlobalKillSwitchEnabled
        return WidgetLaunchPolicy(
            widgetEnabled: remoteConfig.bool(RemoteConfigKeys.widgetEnabled, default: true) && safeToRun,
            widgetRefreshMinutes: max(15, remoteConfig.int(RemoteConfigKeys.widgetRefreshMinutes, default: 60)),
            liveActivityEnabled: remoteConfig.bool(RemoteConfigKeys.liveActivityEnabled, default: false) && safeToRun,
            dynamicIslandEnabled: remoteConfig.bool(RemoteConfigKeys.dynamicIslandEnabled, default: false) && safeToRun,
            liveActivityPushUpdatesEnabled: remoteConfig.bool(RemoteConfigKeys.liveActivityPushUpdatesEnabled, default: false) && safeToRun
        )
    }
}
