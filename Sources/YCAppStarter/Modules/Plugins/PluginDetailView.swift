import SwiftUI

struct PluginDetailView: View {
    @EnvironmentObject private var container: AppContainer
    let pluginID: String

    private var activePlugin: AnyAppPlugin? {
        container.plugins.first { $0.descriptor.id == pluginID }
    }

    private var inactiveDescriptor: PluginDescriptor? {
        container.pluginRuntime.inactivePlugins.first { $0.id == pluginID }
    }

    private var report: PluginHealthReport? {
        container.pluginRuntime.healthReports(container: container).first { $0.pluginID == pluginID }
    }

    var body: some View {
        List {
            if let descriptor = activePlugin?.descriptor ?? inactiveDescriptor {
                Section("Plugin") {
                    LabeledContent("Name", value: descriptor.displayName)
                    LabeledContent("ID", value: descriptor.id)
                    LabeledContent("Version", value: descriptor.version.description)
                    LabeledContent("Category", value: descriptor.category.displayName)
                    LabeledContent("Feature", value: descriptor.feature.rawValue)
                    LabeledContent("Minimum iOS", value: descriptor.minimumIOSVersion)
                    LabeledContent("Removable", value: descriptor.isRemovable ? "Yes" : "No")
                    Text(descriptor.summary)
                        .foregroundStyle(.secondary)
                }

                Section("Dependencies") {
                    if descriptor.dependencies.isEmpty && descriptor.optionalDependencies.isEmpty {
                        Label("No dependencies", systemImage: "checkmark.circle")
                    } else {
                        ForEach(descriptor.dependencies, id: \.self) { feature in
                            LabeledContent(feature.displayName, value: container.flags.isEnabled(feature) ? "Enabled" : "Missing")
                        }
                        ForEach(descriptor.optionalDependencies, id: \.self) { feature in
                            LabeledContent("Optional: \(feature.displayName)", value: container.flags.isEnabled(feature) ? "Enabled" : "Disabled")
                        }
                    }
                }

                Section("Required Secrets") {
                    if descriptor.requiredSecrets.isEmpty {
                        Label("No required secrets", systemImage: "checkmark.circle")
                    } else {
                        ForEach(descriptor.requiredSecrets) { secret in
                            LabeledContent(secret.displayName, value: container.secrets.hasValue(for: secret) ? "Configured" : "Missing")
                        }
                    }
                }

                if let report {
                    Section("Health") {
                        Label(report.status.title, systemImage: report.worstSeverity.systemImage)
                        Text(report.status.message)
                            .foregroundStyle(.secondary)
                    }

                    Section("Checks") {
                        if report.checks.isEmpty {
                            Label("No plugin-specific checks", systemImage: "checkmark.circle")
                        } else {
                            ForEach(report.checks) { check in
                                VStack(alignment: .leading, spacing: 4) {
                                    Label(check.title, systemImage: check.status.severity.systemImage)
                                        .font(.headline)
                                    Text(check.status.message)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    if let recovery = check.recoverySuggestion {
                                        Text(recovery)
                                            .font(.caption2)
                                            .foregroundStyle(.tertiary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            } else {
                ContentUnavailableView("Plugin not found", systemImage: "puzzlepiece.extension", description: Text(pluginID))
            }
        }
        .navigationTitle("Plugin Detail")
    }
}
