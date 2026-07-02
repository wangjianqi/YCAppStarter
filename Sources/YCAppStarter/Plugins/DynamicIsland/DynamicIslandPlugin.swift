import Foundation

struct DynamicIslandPlugin: AppPlugin {
    let descriptor = PluginDescriptor(
        id: "yc.dynamicIsland",
        displayName: "Dynamic Island",
        version: .v29,
        feature: .dynamicIsland,
        category: .system,
        dependencies: [.liveActivity, .remoteConfig],
        optionalDependencies: [.pushNotifications],
        isRemovable: true,
        summary: "Adds Dynamic Island documentation, readiness diagnostics and debug entry points backed by the Live Activity widget extension."
    )

    func makeHomeItems(container: AppContainer) -> [PluginHomeItem] {
        [PluginHomeItem(id: "dynamic-island-debug", title: "Dynamic Island", subtitle: "Layout and policy readiness", systemImage: "iphone.gen3.radiowaves.left.and.right", route: .dynamicIslandDebug)]
    }

    func makeSettingsItems(container: AppContainer) -> [PluginSettingsItem] {
        [PluginSettingsItem(id: "settings-dynamic-island", title: "Dynamic Island", subtitle: "Check Live Activity island surfaces", systemImage: "iphone.gen3.radiowaves.left.and.right", route: .dynamicIslandDebug)]
    }

    func makeDebugItems(container: AppContainer) -> [PluginDebugItem] {
        let policy = LiveActivityPolicy.make(from: container.service(RemoteConfigServicing.self))
        return [
            PluginDebugItem(id: "dynamic-island-enabled", title: "Dynamic Island", value: policy.dynamicIslandEnabled ? "Enabled" : "Disabled", systemImage: "iphone.gen3.radiowaves.left.and.right")
        ]
    }
}
