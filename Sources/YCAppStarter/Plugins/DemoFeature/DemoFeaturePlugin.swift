import Foundation

struct DemoFeaturePlugin: AppPlugin {
    let descriptor = PluginDescriptor(
        id: "yc.demoFeature",
        displayName: "Demo Feature",
        version: .v21,
        feature: .demoFeature,
        category: .sample,
        dependencies: [.settings],
        optionalDependencies: [.analytics],
        summary: "Example removable plugin. Use it as the template for V2.4 feature modules."
    )

    func makeHomeItems(container: AppContainer) -> [PluginHomeItem] {
        [
            PluginHomeItem(
                id: "demo-feature-card",
                title: "Demo Plugin",
                subtitle: "Open plugin descriptor detail",
                systemImage: "sparkles",
                route: .pluginDetail(descriptor.id)
            )
        ]
    }

    func makeSettingsItems(container: AppContainer) -> [PluginSettingsItem] {
        [
            PluginSettingsItem(
                id: "settings-demo-feature",
                title: "Demo Feature",
                subtitle: "Sample removable V2.4 plugin",
                systemImage: "sparkles",
                route: .pluginDetail(descriptor.id)
            )
        ]
    }

    func makeDebugItems(container: AppContainer) -> [PluginDebugItem] {
        [
            PluginDebugItem(id: "demo-feature", title: "Demo Feature", value: "Active", systemImage: "sparkles")
        ]
    }

    func makeHealthChecks(container: AppContainer) -> [PluginHealthCheckResult] {
        [
            PluginHealthCheckResult(
                id: "demo-removable",
                title: "Removable sample",
                status: descriptor.isRemovable ? .ready : .warning("DemoFeature should remain removable."),
                recoverySuggestion: "Keep sample plugins removable so production apps can delete them cleanly."
            )
        ]
    }
}
