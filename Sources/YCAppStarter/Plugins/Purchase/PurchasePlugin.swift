import Foundation

struct PurchasePlugin: AppPlugin {
    let descriptor = PluginDescriptor(
        id: "yc.purchase",
        displayName: "Purchase Core",
        version: .v1,
        feature: .paywall,
        category: .monetization,
        optionalDependencies: [.analytics, .revenueCat],
        summary: "Registers the purchase abstraction. It falls back to NoopPurchaseManager until a production provider, such as RevenueCat, overrides it."
    )

    func registerServices(in registry: ServiceRegistry, secrets: AppSecrets, logger: AppLogging) {
        registry.registerIfAbsent(PurchaseManaging.self, service: NoopPurchaseManager())
    }

    func configure(container: AppContainer) async {
        // Provider plugins, such as RevenueCatPlugin, own production SDK configuration.
        // The core purchase plugin only guarantees that a fallback service exists.
    }

    func makeHomeItems(container: AppContainer) -> [PluginHomeItem] {
        [
            PluginHomeItem(
                id: "paywall-card",
                title: "Paywall",
                subtitle: "Open the active purchase/paywall flow",
                systemImage: "crown.fill",
                route: .paywall
            )
        ]
    }

    func makeSettingsItems(container: AppContainer) -> [PluginSettingsItem] {
        [
            PluginSettingsItem(
                id: "settings-paywall",
                title: "Upgrade",
                subtitle: "Open paywall",
                systemImage: "crown",
                route: .paywall
            ),
            PluginSettingsItem(
                id: "settings-purchase-debug",
                title: "Purchase Debug",
                subtitle: "Products, entitlement and provider status",
                systemImage: "creditcard.and.123",
                route: .purchaseDebug
            )
        ]
    }

    func makeDebugItems(container: AppContainer) -> [PluginDebugItem] {
        let purchase = container.service(PurchaseManaging.self)
        return [
            PluginDebugItem(
                id: "purchase-service",
                title: "Purchase Service",
                value: purchase == nil ? "Missing" : "Registered",
                systemImage: "creditcard"
            ),
            PluginDebugItem(
                id: "purchase-entitlement",
                title: "Premium",
                value: purchase?.entitlement.isPremium == true ? "Yes" : "No",
                systemImage: "checkmark.seal"
            ),
            PluginDebugItem(
                id: "purchase-products",
                title: "Products",
                value: "\(purchase?.products.count ?? 0)",
                systemImage: "cart"
            )
        ]
    }

    func makeHealthChecks(container: AppContainer) -> [PluginHealthCheckResult] {
        var checks: [PluginHealthCheckResult] = [
            PluginHealthCheckResult(
                id: "purchase-service-registered",
                title: "PurchaseManaging service",
                status: container.services.contains(PurchaseManaging.self) ? .ready : .missingService("PurchaseManaging is not registered."),
                recoverySuggestion: "Check PurchasePlugin.registerServices or enable RevenueCatPlugin."
            )
        ]

        if container.flags.isEnabled(.revenueCat) && container.secrets.hasValue(for: .revenueCatAPIKey) {
            checks.append(
                PluginHealthCheckResult(
                    id: "purchase-provider-revenuecat",
                    title: "Production provider",
                    status: .ready,
                    recoverySuggestion: nil
                )
            )
        } else {
            checks.append(
                PluginHealthCheckResult(
                    id: "purchase-provider-noop",
                    title: "Production provider",
                    status: .warning("NoopPurchaseManager is active. This is acceptable for template development, but not for production monetization."),
                    recoverySuggestion: "Fill revenueCatAPIKey in AppSecrets.swift and keep .revenueCat enabled."
                )
            )
        }

        return checks
    }
}
