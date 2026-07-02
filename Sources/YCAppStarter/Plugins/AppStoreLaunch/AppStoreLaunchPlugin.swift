import Foundation

struct AppStoreLaunchPlugin: AppPlugin {
    let descriptor = PluginDescriptor(
        id: "yc.appstore.launch",
        displayName: "App Store Launch Kit",
        version: .v23,
        feature: .appStoreLaunch,
        category: .developer,
        dependencies: [.settings],
        optionalDependencies: [.revenueCat, .firebase, .admob],
        requiredServices: [ServiceRequirement("AppStoreLaunchServicing")],
        isRemovable: true,
        summary: "Provides App Store readiness checks, metadata templates, privacy manifest audit and release preparation surfaces."
    )

    func registerServices(in registry: ServiceRegistry, secrets: AppSecrets, logger: AppLogging) {
        registry.registerIfAbsent(AppStoreLaunchServicing.self, service: DefaultAppStoreLaunchService())
    }

    func makeHomeItems(container: AppContainer) -> [PluginHomeItem] {
        [
            PluginHomeItem(
                id: "app-store-launch",
                title: "App Store Launch",
                subtitle: "Checklist, privacy, metadata and localization",
                systemImage: "checklist.checked",
                route: .appStoreLaunch
            )
        ]
    }

    func makeSettingsItems(container: AppContainer) -> [PluginSettingsItem] {
        [
            PluginSettingsItem(
                id: "app-store-launch-settings",
                title: "App Store Launch Kit",
                subtitle: "Open release readiness checklist",
                systemImage: "checklist.checked",
                route: .appStoreLaunch
            ),
            PluginSettingsItem(
                id: "metadata-templates-settings",
                title: "Metadata Templates",
                subtitle: "App Store copy and review note templates",
                systemImage: "doc.richtext",
                route: .metadataTemplates
            )
        ]
    }

    func makeDebugItems(container: AppContainer) -> [PluginDebugItem] {
        guard let service = container.service(AppStoreLaunchServicing.self) else {
            return [PluginDebugItem(id: "launch-service", title: "Launch service", value: "Missing", systemImage: "xmark.octagon")]
        }
        let report = service.makeReadinessReport(container: container)
        return [
            PluginDebugItem(id: "launch-score", title: "Launch readiness", value: "\(report.score)%", systemImage: "gauge.with.dots.needle.bottom.50percent"),
            PluginDebugItem(id: "launch-blockers", title: "Launch blockers", value: "\(report.failedCount)", systemImage: "exclamationmark.triangle")
        ]
    }

    func makeHealthChecks(container: AppContainer) -> [PluginHealthCheckResult] {
        let hasService = container.services.contains(AppStoreLaunchServicing.self)
        return [
            PluginHealthCheckResult(
                id: "service-appstore-launch",
                title: "AppStoreLaunchServicing",
                status: hasService ? .ready : .missingService("AppStoreLaunchServicing is not registered."),
                recoverySuggestion: "Ensure AppStoreLaunchPlugin.registerServices is called by PluginRuntimeFactory."
            ),
            PluginHealthCheckResult(
                id: "privacy-manifest",
                title: "PrivacyInfo.xcprivacy",
                status: Bundle.main.path(forResource: "PrivacyInfo", ofType: "xcprivacy") == nil ? .warning("PrivacyInfo.xcprivacy was not found in the app bundle at runtime.") : .ready,
                recoverySuggestion: "Keep Sources/YCAppStarter/Resources/PrivacyInfo.xcprivacy included in the Xcode target."
            )
        ]
    }
}
