import Foundation

struct WidgetKitPlugin: AppPlugin {
    let descriptor = PluginDescriptor(
        id: "yc.widgetKit",
        displayName: "WidgetKit",
        version: .v29,
        feature: .widget,
        category: .system,
        dependencies: [.remoteConfig],
        optionalDependencies: [.deepLinks],
        requiredSecrets: [.appGroupIdentifier],
        requiredServices: [ServiceRequirement("WidgetManaging")],
        isRemovable: true,
        summary: "Adds a WidgetKit extension, shared App Group state store and widget debug surface."
    )

    func registerServices(in registry: ServiceRegistry, secrets: AppSecrets, logger: AppLogging) {
        registry.register(WidgetManaging.self, service: AppGroupWidgetStore(appGroupIdentifier: secrets.appGroupIdentifier, logger: logger))
    }

    func configure(container: AppContainer) async {
        guard let widget = container.service(WidgetManaging.self) else { return }
        widget.save(snapshot: widget.currentSnapshot)
    }

    func makeHomeItems(container: AppContainer) -> [PluginHomeItem] {
        [PluginHomeItem(id: "widget-debug", title: "Widgets", subtitle: "Shared App Group snapshot", systemImage: "rectangle.grid.2x2", route: .widgetDebug)]
    }

    func makeSettingsItems(container: AppContainer) -> [PluginSettingsItem] {
        [PluginSettingsItem(id: "settings-widget-debug", title: "Widget Debug", subtitle: "Update shared widget state and reload timelines", systemImage: "rectangle.grid.2x2", route: .widgetDebug)]
    }

    func makeDebugItems(container: AppContainer) -> [PluginDebugItem] {
        let policy = WidgetKitPolicy.make(from: container.service(RemoteConfigServicing.self))
        return [
            PluginDebugItem(id: "widget-enabled", title: "Widget Enabled", value: policy.widgetEnabled ? "Enabled" : "Disabled", systemImage: "rectangle.grid.2x2"),
            PluginDebugItem(id: "widget-refresh", title: "Widget Refresh", value: "\(policy.refreshMinutes)m", systemImage: "clock.arrow.circlepath")
        ]
    }

    func makeHealthChecks(container: AppContainer) -> [PluginHealthCheckResult] {
        var checks = AppPluginDefaultHealth.defaultChecks(descriptor: descriptor, container: container)
        checks.append(PluginHealthCheckResult(id: "widget-service", title: "WidgetManaging service", status: container.services.contains(WidgetManaging.self) ? .ready : .missingService("WidgetManaging is not registered."), recoverySuggestion: "Keep WidgetKitPlugin registered."))
        checks.append(PluginHealthCheckResult(id: "widget-app-group", title: "App Group", status: container.secrets.appGroupIdentifier.hasPrefix("group.") ? .ready : .missingConfiguration("App Group identifier must start with group."), recoverySuggestion: "Run Scripts/configure_app_group.py --app-group group.<team>.<app>."))
        return checks
    }
}
