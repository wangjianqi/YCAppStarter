import SwiftUI

struct ReviewSafeModeView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        List {
            if let remoteConfig = container.service(RemoteConfigServicing.self) {
                let policy = LaunchPolicy.make(from: remoteConfig)

                Section("Status") {
                    Label(
                        policy.reviewSafeModeEnabled ? "Review Safe Mode is enabled" : "Review Safe Mode is disabled",
                        systemImage: policy.reviewSafeModeEnabled ? "shield.lefthalf.filled" : "shield"
                    )
                    LabeledContent("Paywall Effective State", value: policy.paywallEnabled ? "Enabled" : "Suppressed")
                    LabeledContent("Ads Effective State", value: policy.adsEnabled ? "Enabled" : "Suppressed")
                    LabeledContent("Promotion Effective State", value: policy.promotion.isEnabled ? "Enabled" : "Suppressed")
                }

                Section("Recommended App Review Rules") {
                    ReviewRuleRow(
                        title: "No surprise monetization",
                        message: "Disable aggressive paywalls, interstitial ads and campaign banners during review if they can obscure core functionality.",
                        isPassing: !policy.paywallEnabled && !policy.adsEnabled
                    )
                    ReviewRuleRow(
                        title: "Keep legal pages reachable",
                        message: "Privacy Policy, Terms and EULA must remain available even when review mode is enabled.",
                        isPassing: !container.config.legalLinks.privacyPolicyURL.absoluteString.isEmpty
                    )
                    ReviewRuleRow(
                        title: "No network hard failure",
                        message: "The app must have a safe local fallback when Firebase Remote Config cannot be reached.",
                        isPassing: remoteConfig.snapshot.source == .bundledJSON || remoteConfig.snapshot.source == .firebase
                    )
                    ReviewRuleRow(
                        title: "Ads are remotely suppressible",
                        message: "Ad surfaces should obey ads_enabled and review_safe_mode_enabled.",
                        isPassing: !policy.adsEnabled || !policy.reviewSafeModeEnabled
                    )
                }

                Section("Operations") {
                    Text("Before submitting to App Review, set review_safe_mode_enabled=true in Firebase Remote Config or local defaults. After approval, turn it off remotely without shipping a new binary.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } else {
                Section {
                    EmptyStateView(
                        title: "Review Safe Mode is unavailable",
                        message: "Remote Config is not registered.",
                        systemImage: "shield.slash"
                    )
                }
            }
        }
        .navigationTitle("Review Safe Mode")
    }
}

private struct ReviewRuleRow: View {
    let title: String
    let message: String
    let isPassing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: isPassing ? "checkmark.seal" : "exclamationmark.triangle")
                .font(.headline)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
