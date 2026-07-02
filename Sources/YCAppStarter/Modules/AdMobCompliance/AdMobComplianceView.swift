import SwiftUI

struct AdMobComplianceView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        List {
            Section("Configuration") {
                LabeledContent("AdMob App ID", value: container.secrets.hasValue(for: .admobAppID) ? "Configured" : "Missing")
                LabeledContent("AdMob SDK Plugin", value: container.flags.isEnabled(.admob) ? "Enabled" : "Disabled")
                LabeledContent("UMP Plugin", value: container.flags.isEnabled(.umpConsent) ? "Enabled" : "Disabled")
                LabeledContent("Remote ads_enabled", value: container.service(RemoteConfigServicing.self)?.isAdsEnabled == true ? "Enabled" : "Disabled")
                LabeledContent("Review Safe Mode", value: container.service(RemoteConfigServicing.self)?.isReviewSafeModeEnabled == true ? "Enabled" : "Disabled")
                LabeledContent("UMP canRequestAds", value: container.service(AdConsentManaging.self)?.canRequestAds == true ? "true" : "false")
            }

            Section("Runtime Policy") {
                let policy = AdPolicy.make(container: container)
                LabeledContent("Can Load Ads", value: policy.canLoadAnyAd ? "Yes" : "No")
                LabeledContent("Banner", value: policy.canLoad(.banner) ? "Allowed" : "Blocked")
                LabeledContent("Interstitial", value: policy.canLoad(.interstitial) ? "Allowed" : "Blocked")
                LabeledContent("Rewarded", value: policy.canLoad(.rewarded) ? "Allowed" : "Blocked")
                NavigationLink(value: AppRoute.adDebug) {
                    Label("Open Ad Debug", systemImage: "rectangle.3.group")
                }
            }

            Section("Checklist") {
                complianceRow(
                    title: "App ID in Info.plist",
                    message: "Replace the bundled Google sample GADApplicationIdentifier with your real AdMob app ID before release."
                )
                complianceRow(
                    title: "UMP consent flow",
                    message: "V2.5 requests consent info on launch and only allows ad loading when UMP canRequestAds is true."
                )
                complianceRow(
                    title: "Remote Config kill switches",
                    message: "Use ads_enabled and placement-specific switches to disable ads without shipping a new build."
                )
                complianceRow(
                    title: "app-ads.txt",
                    message: "Publish app-ads.txt under the developer website root and wait for AdMob verification."
                )
                complianceRow(
                    title: "Test device IDs",
                    message: "Use Google test ad unit IDs and test device IDs during development. Replace all IDs before production."
                )
                complianceRow(
                    title: "Review notes",
                    message: "Explain ad placements, consent behavior and subscription/ad-free behavior if applicable."
                )
            }

            Section("Scripts") {
                Text("python3 Scripts/configure_admob.py --app-id ca-app-pub-xxx~yyy --banner ca-app-pub-xxx/aaa --interstitial ca-app-pub-xxx/bbb --rewarded ca-app-pub-xxx/ccc")
                    .font(.caption.monospaced())
                Text("python3 Scripts/check_app_ads_txt.py --domain example.com --publisher pub-0000000000000000")
                    .font(.caption.monospaced())
            }
        }
        .navigationTitle("AdMob Compliance")
    }

    private func complianceRow(title: String, message: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: "checklist")
                .font(.headline)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
