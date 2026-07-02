import Foundation

@MainActor
struct PluginRuntime {
    let activePlugins: [AnyAppPlugin]
    let inactivePlugins: [PluginDescriptor]
    let diagnostics: [PluginDiagnostic]

    func configure(container: AppContainer) async {
        for plugin in activePlugins {
            await plugin.configure(container: container)
        }
    }

    func homeItems(container: AppContainer) -> [PluginHomeItem] {
        activePlugins.flatMap { $0.makeHomeItems(container: container) }
    }

    func settingsItems(container: AppContainer) -> [PluginSettingsItem] {
        activePlugins.flatMap { $0.makeSettingsItems(container: container) }
    }

    func debugItems(container: AppContainer) -> [PluginDebugItem] {
        activePlugins.flatMap { $0.makeDebugItems(container: container) }
    }

    func healthReports(container: AppContainer) -> [PluginHealthReport] {
        let activeReports = activePlugins.map { $0.makeHealthReport(container: container) }
        let inactiveReports = inactivePlugins.map { descriptor in
            PluginHealthReport(
                pluginID: descriptor.id,
                pluginName: descriptor.displayName,
                category: descriptor.category,
                version: descriptor.version,
                status: .disabled("Feature flag is disabled or a dependency is not enabled."),
                checks: []
            )
        }
        return activeReports + inactiveReports
    }

    func snapshot(container: AppContainer) -> PluginRuntimeSnapshot {
        PluginRuntimeSnapshot(
            activePluginCount: activePlugins.count,
            inactivePluginCount: inactivePlugins.count,
            diagnosticCount: diagnostics.count,
            registeredServices: container.services.registeredServiceKeys,
            reports: healthReports(container: container)
        )
    }
}
