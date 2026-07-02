import Foundation

struct DebugPlugin: AppPlugin {
    let descriptor = PluginDescriptor(
        id: "yc.debug",
        displayName: "Debug Panel",
        version: .v1,
        feature: .debugPanel,
        category: .developer,
        summary: "Aggregates runtime plugin diagnostics and service registrations."
    )

    func makeHomeItems(container: AppContainer) -> [PluginHomeItem] {
        [
            PluginHomeItem(
                id: "debug-card",
                title: "Debug Panel",
                subtitle: "Inspect flags, plugins and services",
                systemImage: "ladybug.fill",
                route: .debug
            )
        ]
    }

    func makeDebugItems(container: AppContainer) -> [PluginDebugItem] {
        [
            PluginDebugItem(id: "active-plugin-count", title: "Active Plugins", value: "\(container.plugins.count)", systemImage: "puzzlepiece.extension"),
            PluginDebugItem(id: "service-count", title: "Registered Services", value: "\(container.services.registeredServiceKeys.count)", systemImage: "server.rack")
        ]
    }
}
