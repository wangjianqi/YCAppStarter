import SwiftUI

struct LiveActivityDebugView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var snapshots: [LiveActivitySnapshot] = []
    @State private var errorMessage: String?
    @State private var progress: Double = 0.35

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                header
                policyCard
                controlsCard
                activeActivitiesCard
            }
            .padding(DesignTokens.Spacing.lg)
        }
        .navigationTitle("Live Activity")
        .onAppear { refresh() }
    }

    private var header: some View {
        AppCard {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text("ActivityKit")
                    .font(.title.bold())
                Text("Start, update and end a sample Live Activity. The widget extension provides the Lock Screen and Dynamic Island UI.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var policyCard: some View {
        let policy = LiveActivityPolicy.make(from: container.service(RemoteConfigServicing.self))
        return AppCard {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text("Remote Policy")
                    .font(.headline)
                LabeledContent("Live Activity", value: policy.liveActivityEnabled ? "Enabled" : "Disabled")
                LabeledContent("Dynamic Island", value: policy.dynamicIslandEnabled ? "Enabled" : "Disabled")
                LabeledContent("Push Updates", value: policy.pushUpdatesEnabled ? "Enabled" : "Disabled")
                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
        }
    }

    private var controlsCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Text("Controls")
                    .font(.headline)
                PrimaryButton(title: "Start Sample Activity", systemImage: "play.circle") {
                    Task { await start(pushTypeToken: false) }
                }
                SecondaryButton(title: "Start With Push Token", systemImage: "bell.badge") {
                    Task { await start(pushTypeToken: true) }
                }
                VStack(alignment: .leading) {
                    Text("Progress: \(Int(progress * 100))%")
                    Slider(value: $progress, in: 0...1)
                }
                SecondaryButton(title: "Update Activities", systemImage: "arrow.triangle.2.circlepath") {
                    Task { await update() }
                }
                SecondaryButton(title: "End All Activities", systemImage: "xmark.circle") {
                    Task { await endAll() }
                }
            }
        }
    }

    private var activeActivitiesCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text("Active Activities")
                    .font(.headline)
                if snapshots.isEmpty {
                    Text("No active sample Live Activities.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(snapshots) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title).font(.subheadline.bold())
                            Text("\(item.status) · \(Int(item.progress * 100))% · \(item.updatedAt.formatted(date: .omitted, time: .standard))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Divider()
                    }
                }
            }
        }
    }

    private func start(pushTypeToken: Bool) async {
        do {
            try await container.service(LiveActivityManaging.self)?.startSampleActivity(pushTypeToken: pushTypeToken)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        refresh()
    }

    private func update() async {
        await container.service(LiveActivityManaging.self)?.updateSampleActivity(progress: progress)
        refresh()
    }

    private func endAll() async {
        await container.service(LiveActivityManaging.self)?.endAllActivities()
        refresh()
    }

    private func refresh() {
        snapshots = container.service(LiveActivityManaging.self)?.activeSnapshots ?? []
    }
}
