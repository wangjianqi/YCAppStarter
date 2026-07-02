import Foundation

struct RevenueCatPlugin: AppPlugin {
    let descriptor = PluginDescriptor(
        id: "yc.revenuecat",
        displayName: "RevenueCat",
        version: .v22,
        feature: .revenueCat,
        category: .monetization,
        dependencies: [.paywall],
        optionalDependencies: [.analytics],
        requiredSecrets: [.revenueCatAPIKey],
        requiredServices: [ServiceRequirement("PurchaseManaging")],
        summary: "Production purchase provider using RevenueCat offerings, purchases, restore and entitlement state."
    )

    func registerServices(in registry: ServiceRegistry, secrets: AppSecrets, logger: AppLogging) {
        let config = RevenueCatConfig.from(secrets: secrets)
        guard config.isConfigured else {
            logger.warning("RevenueCatPlugin is enabled but revenueCatAPIKey is empty. NoopPurchaseManager will remain active.")
            return
        }

        registry.register(PurchaseManaging.self, service: RevenueCatPurchaseManager(config: config, logger: logger))
    }

    func configure(container: AppContainer) async {
        await container.service(PurchaseManaging.self)?.configure()
        container.service(AnalyticsTracking.self)?.track(AnalyticsEvent("revenuecat_configure_attempt"))
    }

    func makeSettingsItems(container: AppContainer) -> [PluginSettingsItem] {
        [
            PluginSettingsItem(
                id: "settings-revenuecat-debug",
                title: "RevenueCat Debug",
                subtitle: "Offerings, products and entitlement state",
                systemImage: "crown.circle",
                route: .purchaseDebug
            )
        ]
    }

    func makeDebugItems(container: AppContainer) -> [PluginDebugItem] {
        let purchase = container.service(PurchaseManaging.self)
        return [
            PluginDebugItem(
                id: "revenuecat-key",
                title: "RevenueCat API Key",
                value: container.secrets.hasValue(for: .revenueCatAPIKey) ? "Configured" : "Missing",
                systemImage: "key"
            ),
            PluginDebugItem(
                id: "revenuecat-entitlement",
                title: "Entitlement ID",
                value: container.secrets.revenueCatEntitlementID,
                systemImage: "checkmark.seal"
            ),
            PluginDebugItem(
                id: "revenuecat-products",
                title: "RevenueCat Products",
                value: "\(purchase?.products.count ?? 0)",
                systemImage: "shippingbox"
            )
        ]
    }

    func makeHealthChecks(container: AppContainer) -> [PluginHealthCheckResult] {
        [
            PluginHealthCheckResult(
                id: "revenuecat-api-key",
                title: "RevenueCat public API key",
                status: container.secrets.hasValue(for: .revenueCatAPIKey) ? .ready : .missingConfiguration("RevenueCat API key is empty."),
                recoverySuggestion: "Fill AppSecrets.revenueCatAPIKey with the iOS public SDK key from RevenueCat Project Settings > API keys."
            ),
            PluginHealthCheckResult(
                id: "revenuecat-service",
                title: "PurchaseManaging provider",
                status: container.services.contains(PurchaseManaging.self) ? .ready : .missingService("PurchaseManaging is not registered."),
                recoverySuggestion: "Keep PurchasePlugin enabled. RevenueCatPlugin overrides the fallback when configured."
            ),
            PluginHealthCheckResult(
                id: "revenuecat-entitlement-id",
                title: "Entitlement ID",
                status: container.secrets.revenueCatEntitlementID.isEmpty ? .missingConfiguration("RevenueCat entitlement ID is empty.") : .ready,
                recoverySuggestion: "Set AppSecrets.revenueCatEntitlementID to the entitlement identifier configured in RevenueCat. Default is premium."
            )
        ]
    }
}
