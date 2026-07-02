import SwiftUI

struct DebugPanelView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        List {
            Section("Runtime Health") {
                let snapshot = container.pluginRuntime.snapshot(container: container)
                LabeledContent("Overall", value: snapshot.hasBlockingIssues ? "Needs attention" : "Ready")
                LabeledContent("Active Plugins", value: "\(snapshot.activePluginCount)")
                LabeledContent("Inactive Plugins", value: "\(snapshot.inactivePluginCount)")
                LabeledContent("Diagnostics", value: "\(snapshot.diagnosticCount)")
            }

            Section("Plugin Health") {
                ForEach(container.pluginRuntime.healthReports(container: container)) { report in
                    NavigationLink(value: AppRoute.pluginDetail(report.pluginID)) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Label(report.pluginName, systemImage: report.worstSeverity.systemImage)
                                    .font(.headline)
                                Spacer()
                                Text(report.worstSeverity.displayName)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                            Text(report.status.message)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(report.category.displayName) · v\(report.version.description)")
                                .font(.caption2.monospaced())
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            Section("Enabled Features") {
                ForEach(container.flags.enabled) { feature in
                    Label(feature.displayName, systemImage: "checkmark.circle")
                }
            }

            Section("Diagnostics") {
                if container.pluginRuntime.diagnostics.isEmpty {
                    Label("No graph diagnostics", systemImage: "checkmark.seal")
                } else {
                    ForEach(container.pluginRuntime.diagnostics) { diagnostic in
                        VStack(alignment: .leading, spacing: 4) {
                            Label(diagnostic.level.displayName, systemImage: diagnostic.level.systemImage)
                                .font(.headline)
                            Text(diagnostic.message)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(diagnostic.pluginID)
                                .font(.caption.monospaced())
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            Section("Debug Items") {
                ForEach(container.pluginRuntime.debugItems(container: container)) { item in
                    LabeledContent {
                        Text(item.value)
                    } label: {
                        Label(item.title, systemImage: item.systemImage)
                    }
                }
            }

            Section("Services") {
                ForEach(container.services.registeredServiceKeys, id: \.self) { key in
                    Text(key)
                        .font(.caption.monospaced())
                }
            }
        }
        .navigationTitle("Debug")
    }
}
