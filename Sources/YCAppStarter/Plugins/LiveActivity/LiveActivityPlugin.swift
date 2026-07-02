import Foundation

struct LiveActivityPlugin: AppPlugin {
    let descriptor = PluginDescriptor(
        id: "yc.liveActivity",
        displayName: "Live Activity",
        version: .v29,
        feature: .liveActivity,
        category: .system,
        dependencies: [.remoteConfig, .widget],
        optionalDependencies: [.pushNotifications, .deepLinks],
        requiredServices: [ServiceRequirement("LiveActivityManaging")],
        isRemovable: true,
        summary: "Adds ActivityKit sample lifecycle management, Live Activity debug controls and push-token update hooks."
    )

    func registerServices(in registry: ServiceRegistry, secrets: AppSecrets, logger: AppLogging) {
        registry.register(LiveActivityManaging.self, service: StarterLiveActivityManager(logger: logger))
    }

    func makeHomeItems(container: AppContainer) -> [PluginHomeItem] {
        [PluginHomeItem(id: "live-activity-debug", title: "Live Activity", subtitle: "Start, update and end sample activity", systemImage: "clock.badge", route: .liveActivityDebug)]
    }

    func makeSettingsItems(container: AppContainer) -> [PluginSettingsItem] {
        [PluginSettingsItem(id: "settings-live-activity", title: "Live Activity Debug", subtitle: "ActivityKit lifecycle and push-update readiness", systemImage: "clock.badge", route: .liveActivityDebug)]
    }

    func makeDebugItems(container: AppContainer) -> [PluginDebugItem] {
        let policy = LiveActivityPolicy.make(from: container.service(RemoteConfigServicing.self))
        return [
            PluginDebugItem(id: "live-activity-enabled", title: "Live Activity", value: policy.liveActivityEnabled ? "Enabled" : "Disabled", systemImage: "clock.badge"),
            PluginDebugItem(id: "live-activity-push", title: "Push Updates", value: policy.pushUpdatesEnabled ? "Enabled" : "Disabled", systemImage: "bell.badge")
        ]
    }

    func makeHealthChecks(container: AppContainer) -> [PluginHealthCheckResult] {
        var checks = AppPluginDefaultHealth.defaultChecks(descriptor: descriptor, container: container)
        checks.append(PluginHealthCheckResult(id: "live-activity-service", title: "LiveActivityManaging service", status: container.services.contains(LiveActivityManaging.self) ? .ready : .missingService("LiveActivityManaging is not registered."), recoverySuggestion: "Keep LiveActivityPlugin registered."))
        return checks
    }
}
