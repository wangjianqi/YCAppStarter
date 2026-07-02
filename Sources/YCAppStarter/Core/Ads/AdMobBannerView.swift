import SwiftUI
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

struct AdMobBannerView: View {
    @EnvironmentObject private var container: AppContainer
    let placementID: String

    var body: some View {
        let policy = AdPolicy.make(container: container)
        if policy.canLoad(.banner), let placement = container.service(AdManaging.self)?.placements.first(where: { $0.id == placementID }) {
#if canImport(GoogleMobileAds)
            GoogleBannerRepresentable(adUnitID: placement.adUnitID)
                .frame(height: 50)
#else
            bannerPlaceholder(message: "GoogleMobileAds package is not linked")
#endif
        } else {
            bannerPlaceholder(message: "Banner suppressed by policy")
        }
    }

    private func bannerPlaceholder(message: String) -> some View {
        Text(message)
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#if canImport(GoogleMobileAds)
private struct GoogleBannerRepresentable: UIViewRepresentable {
    let adUnitID: String

    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = RootViewControllerProvider.topMostViewController()
        bannerView.load(Request())
        return bannerView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        uiView.rootViewController = RootViewControllerProvider.topMostViewController()
    }
}
#endif
