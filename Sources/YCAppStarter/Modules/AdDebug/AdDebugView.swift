import SwiftUI

struct AdDebugView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var lastResult: AdLoadResult?
    @State private var refreshID = UUID()

    var body: some View {
        List {
            policySection
            consentSection
            placementSection
            actionsSection
            bannerPreviewSection
            resultSection
        }
        .id(refreshID)
        .navigationTitle("Ad Debug")
    }

    private var policySection: some View {
        let policy = AdPolicy.make(container: container)
        return Section("Effective Policy") {
            LabeledContent("Can Load Any Ad", value: policy.canLoadAnyAd ? "Yes" : "No")
            LabeledContent("ads_enabled", value: policy.adsEnabled ? "true" : "false")
            LabeledContent("banner", value: policy.bannerEnabled ? "true" : "false")
            LabeledContent("interstitial", value: policy.interstitialEnabled ? "true" : "false")
            LabeledContent("rewarded", value: policy.rewardedEnabled ? "true" : "false")
            LabeledContent("Review Safe Mode", value: policy.reviewSafeModeEnabled ? "Enabled" : "Disabled")
            LabeledContent("Kill Switch", value: policy.globalKillSwitchEnabled ? "Enabled" : "Disabled")
            LabeledContent("Premium Ad-Free", value: policy.isPremiumUser ? "Yes" : "No")
        }
    }

    private var consentSection: some View {
        let consent = container.service(AdConsentManaging.self)
        return Section("UMP Consent") {
            LabeledContent("canRequestAds", value: consent?.canRequestAds == true ? "true" : "false")
            LabeledContent("Privacy Options", value: consent?.privacyOptionsRequired == true ? "Required" : "Not required")
            LabeledContent("Status", value: consent?.statusText ?? "Unavailable")
            if let error = consent?.lastErrorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Button {
                Task {
                    await consent?.requestConsentIfNeeded()
                    refreshID = UUID()
                }
            } label: {
                Label("Request Consent Update", systemImage: "arrow.clockwise")
            }
            Button {
                Task {
                    await consent?.presentPrivacyOptions()
                    refreshID = UUID()
                }
            } label: {
                Label("Present Privacy Options", systemImage: "hand.raised")
            }
            Button(role: .destructive) {
                consent?.resetForTesting()
                refreshID = UUID()
            } label: {
                Label("Reset Consent For Testing", systemImage: "trash")
            }
        }
    }

    private var placementSection: some View {
        let manager = container.service(AdManaging.self)
        return Section("Placements") {
            if let manager {
                LabeledContent("SDK Started", value: manager.isSDKStarted ? "Yes" : "No")
                if let message = manager.lastEventMessage {
                    LabeledContent("Last Event", value: message)
                }
                ForEach(manager.placements) { placement in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(placement.title)
                                .font(.headline)
                            Spacer()
                            Text(placement.kind.displayName)
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)
                        }
                        Text(placement.adUnitID)
                            .font(.caption.monospaced())
                            .foregroundStyle(placement.isUsingGoogleTestID ? .orange : .secondary)
                        Text(placement.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            } else {
                EmptyStateView(title: "Ad manager missing", message: "AdManaging is not registered. Check AdMobPlugin.", systemImage: "rectangle.slash")
            }
        }
    }

    private var actionsSection: some View {
        Section("Actions") {
            Button {
                Task {
                    await container.service(AdManaging.self)?.configure(container: container)
                    refreshID = UUID()
                }
            } label: {
                Label("Start Google Mobile Ads SDK", systemImage: "play.circle")
            }
            Button {
                Task {
                    await container.service(AdManaging.self)?.loadInterstitial(container: container)
                    refreshID = UUID()
                }
            } label: {
                Label("Load Interstitial", systemImage: "arrow.down.circle")
            }
            Button {
                Task {
                    lastResult = await container.service(AdManaging.self)?.showInterstitial(container: container)
                    refreshID = UUID()
                }
            } label: {
                Label("Show Interstitial", systemImage: "rectangle.portrait.and.arrow.right")
            }
            Button {
                Task {
                    await container.service(AdManaging.self)?.loadRewarded(container: container)
                    refreshID = UUID()
                }
            } label: {
                Label("Load Rewarded", systemImage: "gift")
            }
            Button {
                Task {
                    lastResult = await container.service(AdManaging.self)?.showRewarded(container: container)
                    refreshID = UUID()
                }
            } label: {
                Label("Show Rewarded", systemImage: "gift.fill")
            }
        }
    }

    private var bannerPreviewSection: some View {
        Section("Banner Preview") {
            AdMobBannerView(placementID: "banner.main")
                .environmentObject(container)
            Text("Banner is suppressed unless UMP allows requests, ads_enabled=true, admob_banner_enabled=true, Review Safe Mode is off and the user is not premium.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var resultSection: some View {
        if let lastResult {
            Section("Last Presentation Result") {
                LabeledContent("Placement", value: lastResult.placementID)
                LabeledContent("Presented", value: lastResult.didPresent ? "Yes" : "No")
                Text(lastResult.message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
