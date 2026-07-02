import Foundation
#if canImport(FirebaseCore)
import FirebaseCore
#endif

struct FirebasePlugin: AppPlugin {
    let descriptor = PluginDescriptor(
        id: "yc.firebase",
        displayName: "Firebase",
        version: .v22,
        feature: .firebase,
        category: .growth,
        dependencies: [.analytics],
        optionalDependencies: [.crashlytics],
        requiredSecrets: [.firebaseGoogleServiceInfo],
        requiredServices: [
            ServiceRequirement("AnalyticsTracking"),
            ServiceRequirement("CrashReporting")
        ],
        summary: "Production analytics and crash reporting provider using Firebase Analytics and Crashlytics."
    )

    func registerServices(in registry: ServiceRegistry, secrets: AppSecrets, logger: AppLogging) {
        guard secrets.hasValue(for: .firebaseGoogleServiceInfo) else {
            logger.warning("FirebasePlugin is enabled but GoogleService-Info.plist is missing. Noop analytics/crash services will remain active.")
            return
        }

        registry.register(AnalyticsTracking.self, service: FirebaseAnalyticsTracker())
        registry.register(CrashReporting.self, service: FirebaseCrashReporter())
    }

    func configure(container: AppContainer) async {
        guard container.secrets.hasValue(for: .firebaseGoogleServiceInfo) else { return }

        #if canImport(FirebaseCore)
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        #endif

        container.service(AnalyticsTracking.self)?.configure()
        container.service(CrashReporting.self)?.configure()
        container.service(AnalyticsTracking.self)?.track(AnalyticsEvent("firebase_configured"))
    }

    func makeSettingsItems(container: AppContainer) -> [PluginSettingsItem] {
        [
            PluginSettingsItem(
                id: "settings-firebase-debug",
                title: "Firebase Debug",
                subtitle: "Analytics, Crashlytics and config status",
                systemImage: "flame",
                route: .analyticsDebug
            )
        ]
    }

    func makeDebugItems(container: AppContainer) -> [PluginDebugItem] {
        [
            PluginDebugItem(
                id: "firebase-plist",
                title: "GoogleService-Info.plist",
                value: container.secrets.hasValue(for: .firebaseGoogleServiceInfo) ? "Configured" : "Missing",
                systemImage: "doc.badge.gearshape"
            ),
            PluginDebugItem(
                id: "firebase-analytics",
                title: "Firebase Analytics",
                value: container.services.contains(AnalyticsTracking.self) ? "Registered" : "Missing",
                systemImage: "chart.bar"
            ),
            PluginDebugItem(
                id: "firebase-crashlytics",
                title: "Firebase Crashlytics",
                value: container.services.contains(CrashReporting.self) ? "Registered" : "Missing",
                systemImage: "bolt.heart"
            )
        ]
    }

    func makeHealthChecks(container: AppContainer) -> [PluginHealthCheckResult] {
        [
            PluginHealthCheckResult(
                id: "firebase-google-service-info",
                title: "GoogleService-Info.plist",
                status: container.secrets.hasValue(for: .firebaseGoogleServiceInfo) ? .ready : .missingConfiguration("GoogleService-Info.plist is not bundled."),
                recoverySuggestion: "Download GoogleService-Info.plist from Firebase Console and add it to Sources/YCAppStarter/Resources."
            ),
            PluginHealthCheckResult(
                id: "firebase-analytics-service",
                title: "AnalyticsTracking provider",
                status: container.services.contains(AnalyticsTracking.self) ? .ready : .missingService("AnalyticsTracking is not registered."),
                recoverySuggestion: "Keep AnalyticsPlugin enabled. FirebasePlugin overrides the fallback when configured."
            ),
            PluginHealthCheckResult(
                id: "firebase-crash-service",
                title: "CrashReporting provider",
                status: container.services.contains(CrashReporting.self) ? .ready : .missingService("CrashReporting is not registered."),
                recoverySuggestion: "Keep AnalyticsPlugin enabled and include FirebaseCrashlytics package."
            )
        ]
    }
}
