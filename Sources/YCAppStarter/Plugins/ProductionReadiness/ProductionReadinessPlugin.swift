import Foundation

struct ProductionReadinessPlugin: AppPlugin {
    let descriptor = PluginDescriptor(
        id: "yc.production.readiness",
        displayName: "Production Hardening",
        version: .v30,
        feature: .productionReadiness,
        category: .quality,
        dependencies: [.debugPanel, .appStoreLaunch],
        optionalDependencies: [.revenueCat, .firebase, .admob, .remoteConfig, .supabaseAuth, .widgetKit],
        requiredServices: [ServiceRequirement("ProductionReadinessServicing")],
        isRemovable: true,
        summary: "Adds production readiness checks, build environment surfaces, StoreKit test references, CI validation and release packaging guidance."
    )

    func registerServices(in registry: ServiceRegistry, secrets: AppSecrets, logger: AppLogging) {
        registry.registerIfAbsent(ProductionReadinessServicing.self, service: DefaultProductionReadinessService())
    }

    func makeHomeItems(container: AppContainer) -> [PluginHomeItem] {
        [
            PluginHomeItem(id: "production-readiness", title: "Production", subtitle: "Release gates and hardening checks", systemImage: "checkmark.shield", route: .productionReadiness)
        ]
    }

    func makeSettingsItems(container: AppContainer) -> [PluginSettingsItem] {
        [
            PluginSettingsItem(id: "production-readiness-settings", title: "Production Readiness", subtitle: "Check environment, StoreKit, CI and release gates", systemImage: "checkmark.shield", route: .productionReadiness),
            PluginSettingsItem(id: "environment-debug-settings", title: "Environment Debug", subtitle: "Inspect current build environment", systemImage: "switch.2", route: .environmentDebug),
            PluginSettingsItem(id: "storekit-debug-settings", title: "StoreKit Test", subtitle: "Review local StoreKit test configuration", systemImage: "creditcard.trianglebadge.exclamationmark", route: .storeKitDebug)
        ]
    }

    func makeDebugItems(container: AppContainer) -> [PluginDebugItem] {
        let report = container.service(ProductionReadinessServicing.self)?.makeReport(container: container)
        return [
            PluginDebugItem(id: "production-score", title: "Production Score", value: "\(report?.score ?? 0)%", systemImage: "gauge.with.dots.needle.bottom.50percent"),
            PluginDebugItem(id: "production-blockers", title: "Production Blockers", value: "\(report?.blockingCount ?? 0)", systemImage: "xmark.octagon"),
            PluginDebugItem(id: "build-environment", title: "Build Environment", value: BuildEnvironmentReader.current.displayName, systemImage: "switch.2")
        ]
    }

    func makeHealthChecks(container: AppContainer) -> [PluginHealthCheckResult] {
        [
            PluginHealthCheckResult(id: "production-service", title: "ProductionReadinessServicing", status: container.services.contains(ProductionReadinessServicing.self) ? .ready : .missingService("ProductionReadinessServicing is not registered."), recoverySuggestion: "Keep ProductionReadinessPlugin registered."),
            PluginHealthCheckResult(id: "storekit-file", title: "StoreKit test file", status: Bundle.main.url(forResource: "YCAppStarter", withExtension: "storekit") == nil ? .warning("StoreKit file is provided at repository level and may not be bundled in the app target.") : .ready, recoverySuggestion: "Reference StoreKit/YCAppStarter.storekit in the scheme for local purchase testing.")
        ]
    }
}
