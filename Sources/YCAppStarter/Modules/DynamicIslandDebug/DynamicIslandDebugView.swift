import SwiftUI

struct DynamicIslandDebugView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                AppCard {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                        Text("Dynamic Island")
                            .font(.title.bold())
                        Text("Dynamic Island rendering is provided by the Live Activity widget extension. This page keeps the operational checklist in the main app.")
                            .foregroundStyle(.secondary)
                    }
                }
                policyCard
                checklistCard
            }
            .padding(DesignTokens.Spacing.lg)
        }
        .navigationTitle("Dynamic Island")
    }

    private var policyCard: some View {
        let policy = LiveActivityPolicy.make(from: container.service(RemoteConfigServicing.self))
        return AppCard {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text("Remote Policy")
                    .font(.headline)
                LabeledContent("Live Activity", value: policy.liveActivityEnabled ? "Enabled" : "Disabled")
                LabeledContent("Dynamic Island", value: policy.dynamicIslandEnabled ? "Enabled" : "Disabled")
                LabeledContent("Review Safe Mode", value: container.service(RemoteConfigServicing.self)?.isReviewSafeModeEnabled == true ? "On" : "Off")
                LabeledContent("Kill Switch", value: container.service(RemoteConfigServicing.self)?.isGlobalKillSwitchEnabled == true ? "On" : "Off")
            }
        }
    }

    private var checklistCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text("Readiness Checklist")
                    .font(.headline)
                Label("Widget extension target exists and contains ActivityConfiguration", systemImage: "checkmark.circle")
                Label("NSSupportsLiveActivities is true in the app Info.plist", systemImage: "checkmark.circle")
                Label("App Group is shared between app and widget extension", systemImage: "checkmark.circle")
                Label("Push updates require server-side Live Activity push token handling", systemImage: "exclamationmark.triangle")
            }
            .font(.footnote)
        }
    }
}
