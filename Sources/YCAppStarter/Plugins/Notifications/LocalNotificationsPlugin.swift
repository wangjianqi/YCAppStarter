import Foundation

struct LocalNotificationsPlugin: AppPlugin {
    let descriptor = PluginDescriptor(
        id: "yc.localNotifications",
        displayName: "Local Notifications",
        version: .v1,
        feature: .localNotifications,
        category: .system,
        summary: "Registers local notification helper."
    )

    func registerServices(in registry: ServiceRegistry, secrets: AppSecrets, logger: AppLogging) {
        registry.register(LocalNotificationManaging.self, service: LocalNotificationManager())
    }

    func makeSettingsItems(container: AppContainer) -> [PluginSettingsItem] {
        [
            PluginSettingsItem(
                id: "settings-notifications",
                title: "Notifications",
                subtitle: "Local notification helper is registered",
                systemImage: "bell",
                route: nil
            )
        ]
    }

    func makeDebugItems(container: AppContainer) -> [PluginDebugItem] {
        [
            PluginDebugItem(
                id: "notifications-service",
                title: "Local Notifications",
                value: container.services.contains(LocalNotificationManaging.self) ? "Registered" : "Missing",
                systemImage: "bell.badge"
            )
        ]
    }

    func makeHealthChecks(container: AppContainer) -> [PluginHealthCheckResult] {
        [
            PluginHealthCheckResult(
                id: "local-notification-service-registered",
                title: "LocalNotificationManaging service",
                status: container.services.contains(LocalNotificationManaging.self) ? .ready : .missingService("LocalNotificationManaging is not registered."),
                recoverySuggestion: "Check LocalNotificationsPlugin.registerServices."
            )
        ]
    }
}
