import Foundation
import UIKit
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

@MainActor
final class GoogleAdMobManager: NSObject, ObservableObject, AdManaging {
    @Published private(set) var isSDKStarted: Bool = false
    @Published private(set) var lastEventMessage: String?

    let placements: [AdPlacement]

#if canImport(GoogleMobileAds)
    private var interstitialAd: InterstitialAd?
    private var rewardedAd: RewardedAd?
#endif

    init(secrets: AppSecrets) {
        self.placements = [
            AdPlacement(id: "banner.main", kind: .banner, adUnitID: secrets.admobBannerAdUnitID, title: "Main Banner", description: "Primary in-app banner placement."),
            AdPlacement(id: "interstitial.default", kind: .interstitial, adUnitID: secrets.admobInterstitialAdUnitID, title: "Default Interstitial", description: "Full-screen placement for natural breaks."),
            AdPlacement(id: "rewarded.default", kind: .rewarded, adUnitID: secrets.admobRewardedAdUnitID, title: "Default Rewarded", description: "Rewarded placement for opt-in rewards.")
        ]
        super.init()
    }

    func configure(container: AppContainer) async {
        let policy = AdPolicy.make(container: container)
        guard policy.canLoadAnyAd else {
            lastEventMessage = "AdMob SDK start skipped by policy."
            return
        }
#if canImport(GoogleMobileAds)
        MobileAds.shared.start()
        isSDKStarted = true
        lastEventMessage = "Google Mobile Ads SDK started."
#else
        isSDKStarted = false
        lastEventMessage = "GoogleMobileAds package is not linked."
#endif
    }

    func loadInterstitial(container: AppContainer) async {
        let policy = AdPolicy.make(container: container)
        guard policy.canLoad(.interstitial) else {
            lastEventMessage = "Interstitial load blocked by ad policy."
            return
        }
        guard let placement = placements.first(where: { $0.kind == .interstitial }) else {
            lastEventMessage = "Interstitial placement is missing."
            return
        }
#if canImport(GoogleMobileAds)
        do {
            interstitialAd = try await InterstitialAd.load(with: placement.adUnitID, request: Request())
            interstitialAd?.fullScreenContentDelegate = self
            lastEventMessage = "Interstitial loaded: \(placement.id)"
        } catch {
            lastEventMessage = "Interstitial load failed: \(error.localizedDescription)"
        }
#else
        lastEventMessage = "GoogleMobileAds package is not linked."
#endif
    }

    func showInterstitial(container: AppContainer) async -> AdLoadResult {
        let policy = AdPolicy.make(container: container)
        guard policy.canLoad(.interstitial) else {
            return AdLoadResult(placementID: "interstitial.default", didPresent: false, message: "Blocked by ad policy")
        }
#if canImport(GoogleMobileAds)
        guard let interstitialAd else {
            return AdLoadResult(placementID: "interstitial.default", didPresent: false, message: "Interstitial is not loaded")
        }
        guard let root = RootViewControllerProvider.topMostViewController() else {
            return AdLoadResult(placementID: "interstitial.default", didPresent: false, message: "Missing root view controller")
        }
        interstitialAd.present(from: root)
        self.interstitialAd = nil
        lastEventMessage = "Interstitial presented."
        return AdLoadResult(placementID: "interstitial.default", didPresent: true, message: "Presented")
#else
        return AdLoadResult(placementID: "interstitial.default", didPresent: false, message: "GoogleMobileAds package is not linked")
#endif
    }

    func loadRewarded(container: AppContainer) async {
        let policy = AdPolicy.make(container: container)
        guard policy.canLoad(.rewarded) else {
            lastEventMessage = "Rewarded load blocked by ad policy."
            return
        }
        guard let placement = placements.first(where: { $0.kind == .rewarded }) else {
            lastEventMessage = "Rewarded placement is missing."
            return
        }
#if canImport(GoogleMobileAds)
        do {
            rewardedAd = try await RewardedAd.load(with: placement.adUnitID, request: Request())
            rewardedAd?.fullScreenContentDelegate = self
            lastEventMessage = "Rewarded loaded: \(placement.id)"
        } catch {
            lastEventMessage = "Rewarded load failed: \(error.localizedDescription)"
        }
#else
        lastEventMessage = "GoogleMobileAds package is not linked."
#endif
    }

    func showRewarded(container: AppContainer) async -> AdLoadResult {
        let policy = AdPolicy.make(container: container)
        guard policy.canLoad(.rewarded) else {
            return AdLoadResult(placementID: "rewarded.default", didPresent: false, message: "Blocked by ad policy")
        }
#if canImport(GoogleMobileAds)
        guard let rewardedAd else {
            return AdLoadResult(placementID: "rewarded.default", didPresent: false, message: "Rewarded ad is not loaded")
        }
        guard let root = RootViewControllerProvider.topMostViewController() else {
            return AdLoadResult(placementID: "rewarded.default", didPresent: false, message: "Missing root view controller")
        }
        var rewardMessage = "Presented"
        rewardedAd.present(from: root) { [weak self] in
            let reward = rewardedAd.adReward
            rewardMessage = "Reward earned: \(reward.amount) \(reward.type)"
            Task { @MainActor in
                self?.lastEventMessage = rewardMessage
            }
        }
        self.rewardedAd = nil
        return AdLoadResult(placementID: "rewarded.default", didPresent: true, message: rewardMessage)
#else
        return AdLoadResult(placementID: "rewarded.default", didPresent: false, message: "GoogleMobileAds package is not linked")
#endif
    }
}

#if canImport(GoogleMobileAds)
extension GoogleAdMobManager: FullScreenContentDelegate {
    nonisolated func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        Task { @MainActor in self.lastEventMessage = "Full-screen ad recorded an impression." }
    }

    nonisolated func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        Task { @MainActor in self.lastEventMessage = "Full-screen ad dismissed." }
    }

    nonisolated func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        Task { @MainActor in self.lastEventMessage = "Full-screen presentation failed: \(error.localizedDescription)" }
    }
}
#endif
