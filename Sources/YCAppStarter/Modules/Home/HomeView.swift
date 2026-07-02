import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        NavigationStack(path: $container.router.path) {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                    header
                    pluginGrid
                    pluginDiagnostics
                }
                .padding(DesignTokens.Spacing.lg)
            }
            .navigationTitle(container.config.displayName)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        container.router.push(.settings)
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                RouteView(route: route)
            }
        }
    }

    private var header: some View {
        AppCard {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text("YCAppStarter V3.1")
                    .font(.largeTitle.bold())
                Text("Production-ready plugin-first SwiftUI starter with commercial SDK adapters, App Store launch tooling, remote operations, AdMob/UMP monetization, AI proxy backend kit, Supabase auth/profile sync, push, deep links, account center flows, widgets, Live Activities, Dynamic Island and production hardening gates.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                Text("Active plugins: \(container.plugins.count)")
                    .font(.footnote.monospaced())
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var pluginGrid: some View {
        let items = container.pluginRuntime.homeItems(container: container)
        return VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text("Plugin Surfaces")
                .font(.headline)

            if items.isEmpty {
                EmptyStateView(title: "No plugin surfaces", message: "Register a plugin home item to show it here.", systemImage: "shippingbox")
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                    ForEach(items) { item in
                        Button {
                            if let route = item.route {
                                container.router.push(route)
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                                Image(systemName: item.systemImage)
                                    .font(.title2)
                                Text(item.title)
                                    .font(.headline)
                                Text(item.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var pluginDiagnostics: some View {
        if !container.pluginRuntime.diagnostics.isEmpty {
            AppCard {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text("Plugin Diagnostics")
                        .font(.headline)
                    ForEach(container.pluginRuntime.diagnostics) { diagnostic in
                        Label(diagnostic.message, systemImage: "exclamationmark.triangle")
                            .font(.footnote)
                    }
                }
            }
        }
    }
}
