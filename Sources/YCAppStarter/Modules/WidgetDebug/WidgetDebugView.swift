import SwiftUI

struct WidgetDebugView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var snapshot: StarterWidgetSnapshot = .placeholder

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                header
                policyCard
                snapshotCard
                actionsCard
            }
            .padding(DesignTokens.Spacing.lg)
        }
        .navigationTitle("Widget Debug")
        .onAppear { refresh() }
    }

    private var header: some View {
        AppCard {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text("WidgetKit")
                    .font(.title.bold())
                Text("Writes a compact snapshot to the shared App Group. The widget extension reads this snapshot from UserDefaults and refreshes its timeline.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var policyCard: some View {
        let policy = WidgetKitPolicy.make(from: container.service(RemoteConfigServicing.self))
        return AppCard {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text("Remote Policy")
                    .font(.headline)
                LabeledContent("Widget Enabled", value: policy.widgetEnabled ? "Enabled" : "Disabled")
                LabeledContent("Refresh Interval", value: "\(policy.refreshMinutes) minutes")
                LabeledContent("App Group", value: container.secrets.appGroupIdentifier)
            }
        }
    }

    private var snapshotCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text("Current Snapshot")
                    .font(.headline)
                LabeledContent("Title", value: snapshot.title)
                LabeledContent("Message", value: snapshot.message)
                LabeledContent("Progress", value: "\(Int(snapshot.progress * 100))%")
                LabeledContent("Updated", value: snapshot.updatedAt.formatted(date: .abbreviated, time: .standard))
                LabeledContent("Deep Link", value: snapshot.deepLinkURLString)
            }
        }
    }

    private var actionsCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Text("Actions")
                    .font(.headline)
                PrimaryButton(title: "Save Sample Snapshot", systemImage: "square.and.arrow.down") {
                    guard let manager = container.service(WidgetManaging.self) else { return }
                    let sample = manager.makeSampleSnapshot()
                    manager.save(snapshot: sample)
                    manager.reloadAllTimelines()
                    snapshot = sample
                }
                SecondaryButton(title: "Reload Widget Timelines", systemImage: "arrow.clockwise") {
                    container.service(WidgetManaging.self)?.reloadAllTimelines()
                    refresh()
                }
            }
        }
    }

    private func refresh() {
        snapshot = container.service(WidgetManaging.self)?.currentSnapshot ?? .placeholder
    }
}
