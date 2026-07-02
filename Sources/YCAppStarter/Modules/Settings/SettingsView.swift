import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        List {
            Section("App") {
                LabeledContent("Name", value: container.config.displayName)
                LabeledContent("Bundle ID", value: container.config.bundleIdentifier)
                LabeledContent("Starter", value: "2.8.0")
            }

            Section("Plugin Items") {
                ForEach(container.pluginRuntime.settingsItems(container: container)) { item in
                    Button {
                        if let route = item.route {
                            container.router.push(route)
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: item.systemImage)
                                .frame(width: 28)
                            VStack(alignment: .leading) {
                                Text(item.title)
                                    .foregroundStyle(.primary)
                                Text(item.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            Section("Developer") {
                Button {
                    container.router.push(.debug)
                } label: {
                    Label("Debug Panel", systemImage: "ladybug")
                }
            }
        }
        .navigationTitle("Settings")
    }
}
