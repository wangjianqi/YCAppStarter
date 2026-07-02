import Foundation

struct AnalyticsPlugin: AppPlugin {
    let descriptor = PluginDescriptor(
        id: "yc.analytics",
        displayName: "Analytics Core",
        version: .v1,
        feature: .analytics,
        category: .growth,
        optionalDependencies: [.firebase],
        summary: "Registers the analytics abstraction. It falls back to NoopAnalyticsTracker until FirebasePlugin overrides it."
    )

    func registerServices(in registry: ServiceRegistry, secrets: AppSecrets, logger: AppLogging) {
        registry.registerIfAbsent(AnalyticsTracking.self, service: NoopAnalyticsTracker())
        registry.registerIfAbsent(CrashReporting.self, service: NoopCrashReporter())
    }

    func configure(container: AppContainer) async {
        // Provider plugins, such as FirebasePlugin, own production SDK configuration.
        // The core analytics plugin only guarantees that fallback services exist.
    }

    func makeSettingsItems(container: AppContainer) -> [PluginSettingsItem] {
        [
            PluginSettingsItem(
                id: "settings-analytics-debug",
                title: "Analytics Debug",
                subtitle: "Tracker, Crashlytics and test events",
                systemImage: "chart.line.uptrend.xyaxis",
                route: .analyticsDebug
            )
        ]
    }

    func makeDebugItems(container: AppContainer) -> [PluginDebugItem] {
        [
            PluginDebugItem(
                id: "analytics-service",
                title: "Analytics Service",
                value: container.services.contains(AnalyticsTracking.self) ? "Registered" : "Missing",
                systemImage: "chart.line.uptrend.xyaxis"
            ),
            PluginDebugItem(
                id: "crash-service",
                title: "Crash Reporter",
                value: container.services.contains(CrashReporting.self) ? "Registered" : "Missing",
                systemImage: "bolt.heart"
            )
        ]
    }

    func makeHealthChecks(container: AppContainer) -> [PluginHealthCheckResult] {
        [
            PluginHealthCheckResult(
                id: "analytics-service-registered",
                title: "AnalyticsTracking service",
                status: container.services.contains(AnalyticsTracking.self) ? .ready : .missingService("AnalyticsTracking is not registered."),
                recoverySuggestion: "Check AnalyticsPlugin.registerServices or enable FirebasePlugin."
            ),
            PluginHealthCheckResult(
                id: "crash-service-registered",
                title: "CrashReporting service",
                status: container.services.contains(CrashReporting.self) ? .ready : .missingService("CrashReporting is not registered."),
                recoverySuggestion: "Check AnalyticsPlugin.registerServices or enable FirebasePlugin."
            )
        ]
    }
}
