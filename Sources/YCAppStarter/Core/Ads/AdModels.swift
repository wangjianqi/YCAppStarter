import Foundation

enum AdPlacementKind: String, CaseIterable, Identifiable, Hashable {
    case banner
    case interstitial
    case rewarded

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .banner: return "Banner"
        case .interstitial: return "Interstitial"
        case .rewarded: return "Rewarded"
        }
    }
}

struct AdPlacement: Identifiable, Hashable, Sendable {
    let id: String
    let kind: AdPlacementKind
    let adUnitID: String
    let title: String
    let description: String

    var isUsingGoogleTestID: Bool {
        adUnitID.contains("3940256099942544")
    }
}

struct AdPolicy: Hashable {
    let adsEnabled: Bool
    let bannerEnabled: Bool
    let interstitialEnabled: Bool
    let rewardedEnabled: Bool
    let reviewSafeModeEnabled: Bool
    let globalKillSwitchEnabled: Bool
    let isPremiumUser: Bool
    let consentCanRequestAds: Bool

    var canLoadAnyAd: Bool {
        adsEnabled && !reviewSafeModeEnabled && !globalKillSwitchEnabled && !isPremiumUser && consentCanRequestAds
    }

    func canLoad(_ kind: AdPlacementKind) -> Bool {
        guard canLoadAnyAd else { return false }
        switch kind {
        case .banner: return bannerEnabled
        case .interstitial: return interstitialEnabled
        case .rewarded: return rewardedEnabled
        }
    }

    static func make(container: AppContainer) -> AdPolicy {
        let remoteConfig = container.service(RemoteConfigServicing.self)
        let purchase = container.service(PurchaseManaging.self)
        let consent = container.service(AdConsentManaging.self)
        return AdPolicy(
            adsEnabled: remoteConfig?.isAdsEnabled ?? false,
            bannerEnabled: remoteConfig?.bool(RemoteConfigKeys.admobBannerEnabled, default: false) ?? false,
            interstitialEnabled: remoteConfig?.bool(RemoteConfigKeys.admobInterstitialEnabled, default: false) ?? false,
            rewardedEnabled: remoteConfig?.bool(RemoteConfigKeys.admobRewardedEnabled, default: false) ?? false,
            reviewSafeModeEnabled: remoteConfig?.isReviewSafeModeEnabled ?? false,
            globalKillSwitchEnabled: remoteConfig?.isGlobalKillSwitchEnabled ?? false,
            isPremiumUser: purchase?.entitlement.isPremium ?? false,
            consentCanRequestAds: consent?.canRequestAds ?? false
        )
    }
}

struct AdLoadResult: Hashable {
    let placementID: String
    let didPresent: Bool
    let message: String
}

enum AdError: LocalizedError, Hashable {
    case notConfigured
    case disabledByPolicy(String)
    case consentRequired
    case missingRootViewController
    case notLoaded(String)
    case sdkError(String)

    var errorDescription: String? {
        switch self {
        case .notConfigured: return "AdMob is not configured."
        case .disabledByPolicy(let reason): return "Ads are disabled by policy: \(reason)"
        case .consentRequired: return "Consent has not allowed ad requests yet."
        case .missingRootViewController: return "Unable to find a root view controller for ad presentation."
        case .notLoaded(let placement): return "Ad is not loaded for placement: \(placement)."
        case .sdkError(let message): return message
        }
    }
}
