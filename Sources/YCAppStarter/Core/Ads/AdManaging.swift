import SwiftUI

@MainActor
protocol AdManaging {
    var isSDKStarted: Bool { get }
    var lastEventMessage: String? { get }
    var placements: [AdPlacement] { get }

    func configure(container: AppContainer) async
    func loadInterstitial(container: AppContainer) async
    func showInterstitial(container: AppContainer) async -> AdLoadResult
    func loadRewarded(container: AppContainer) async
    func showRewarded(container: AppContainer) async -> AdLoadResult
}

@MainActor
final class NoopAdManager: ObservableObject, AdManaging {
    @Published private(set) var isSDKStarted: Bool = false
    @Published private(set) var lastEventMessage: String? = "No-op ad manager"
    let placements: [AdPlacement]

    init(secrets: AppSecrets = .default) {
        self.placements = [
            AdPlacement(id: "banner.main", kind: .banner, adUnitID: secrets.admobBannerAdUnitID, title: "Main Banner", description: "Default banner placement."),
            AdPlacement(id: "interstitial.default", kind: .interstitial, adUnitID: secrets.admobInterstitialAdUnitID, title: "Default Interstitial", description: "Default interstitial placement."),
            AdPlacement(id: "rewarded.default", kind: .rewarded, adUnitID: secrets.admobRewardedAdUnitID, title: "Default Rewarded", description: "Default rewarded placement.")
        ]
    }

    func configure(container: AppContainer) async {
        lastEventMessage = "AdMobPlugin is disabled or GoogleMobileAds is unavailable."
    }

    func loadInterstitial(container: AppContainer) async {
        lastEventMessage = "Interstitial load skipped in no-op mode."
    }

    func showInterstitial(container: AppContainer) async -> AdLoadResult {
        AdLoadResult(placementID: "interstitial.default", didPresent: false, message: "No-op mode")
    }

    func loadRewarded(container: AppContainer) async {
        lastEventMessage = "Rewarded load skipped in no-op mode."
    }

    func showRewarded(container: AppContainer) async -> AdLoadResult {
        AdLoadResult(placementID: "rewarded.default", didPresent: false, message: "No-op mode")
    }
}
