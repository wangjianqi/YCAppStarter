import SwiftUI

struct RemoteConfigView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var refreshID = UUID()

    var body: some View {
        List {
            if let remoteConfig = container.service(RemoteConfigServicing.self) {
                let policy = LaunchPolicy.make(from: remoteConfig)

                Section("Launch Policy") {
                    LabeledContent("Source", value: remoteConfig.snapshot.source.displayName)
                    LabeledContent("Review Safe Mode", value: policy.reviewSafeModeEnabled ? "Enabled" : "Disabled")
                    LabeledContent("Global Kill Switch", value: policy.globalKillSwitchEnabled ? "Enabled" : "Disabled")
                    LabeledContent("Paywall", value: policy.paywallEnabled ? "Enabled" : "Disabled")
                    LabeledContent("Paywall Variant", value: policy.paywallVariant)
                    LabeledContent("Ads", value: policy.adsEnabled ? "Enabled" : "Disabled")
                    LabeledContent("Promotion", value: policy.promotion.isEnabled ? "Enabled" : "Disabled")
                }

                if let error = remoteConfig.snapshot.lastErrorMessage {
                    Section("Last Error") {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Critical Keys") {
                    ForEach(remoteConfig.snapshot.sortedEntries) { entry in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(entry.key.rawValue)
                                    .font(.subheadline.weight(.semibold))
                                Spacer()
                                Text(entry.value.stringValue)
                                    .font(.caption.monospaced())
                                    .foregroundStyle(.secondary)
                            }
                            Text(entry.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("Local Test Overrides") {
                    ToggleOverrideRow(
                        title: "Review Safe Mode",
                        key: RemoteConfigKeys.reviewSafeModeEnabled,
                        remoteConfig: remoteConfig,
                        refreshID: $refreshID
                    )
                    ToggleOverrideRow(
                        title: "Global Kill Switch",
                        key: RemoteConfigKeys.featureKillSwitchEnabled,
                        remoteConfig: remoteConfig,
                        refreshID: $refreshID
                    )
                    ToggleOverrideRow(
                        title: "Ads Enabled",
                        key: RemoteConfigKeys.adsEnabled,
                        remoteConfig: remoteConfig,
                        refreshID: $refreshID
                    )
                }

                Section("Actions") {
                    Button {
                        Task {
                            await remoteConfig.refresh()
                            refreshID = UUID()
                        }
                    } label: {
                        Label("Refresh Remote Config", systemImage: "arrow.clockwise")
                    }

                    NavigationLink(value: AppRoute.reviewSafeMode) {
                        Label("Open Review Safe Mode Audit", systemImage: "shield.lefthalf.filled")
                    }
                }
            } else {
                Section {
                    EmptyStateView(
                        title: "Remote Config is unavailable",
                        message: "RemoteConfigServicing is not registered. Check PluginCatalog and FeatureFlags.",
                        systemImage: "switch.2"
                    )
                }
            }
        }
        .id(refreshID)
        .navigationTitle("Remote Config")
    }
}

private struct ToggleOverrideRow: View {
    let title: String
    let key: RemoteConfigKey
    let remoteConfig: RemoteConfigServicing
    @Binding var refreshID: UUID

    private var currentValue: Bool {
        remoteConfig.bool(key, default: false)
    }

    var body: some View {
        Toggle(title, isOn: Binding(
            get: { currentValue },
            set: { newValue in
                remoteConfig.setLocalOverride(.bool(newValue), for: key)
                refreshID = UUID()
            }
        ))
    }
}
