import Foundation

struct DeepLinkPlugin: AppPlugin {
    let descriptor = PluginDescriptor(
        id: "yc.deepLinks",
        displayName: "Deep Links",
        version: .v28,
        feature: .deepLinks,
        category: .system,
        dependencies: [.remoteConfig],
        optionalDependencies: [.supabaseAuth, .pushNotifications],
        requiredServices: [ServiceRequirement("DeepLinkManaging"), ServiceRequirement("RemoteConfigServicing")],
        isRemovable: true,
        summary: "Adds custom-scheme/universal link routing and Supabase magic-link callback hooks."
    )

    func registerServices(in registry: ServiceRegistry, secrets: AppSecrets, logger: AppLogging) {
        registry.register(DeepLinkManaging.self, service: DeepLinkRouter(logger: logger))
    }

    func makeHomeItems(container: AppContainer) -> [PluginHomeItem] {
        [PluginHomeItem(id: "deep-link-debug", title: "Deep Links", subtitle: "Routes and callback tests", systemImage: "link", route: .deepLinkDebug)]
    }

    func makeSettingsItems(container: AppContainer) -> [PluginSettingsItem] {
        [PluginSettingsItem(id: "settings-deep-links", title: "Deep Links", subtitle: "Custom scheme and magic link routing", systemImage: "link", route: .deepLinkDebug)]
    }

    func makeDebugItems(container: AppContainer) -> [PluginDebugItem] {
        let router = container.service(DeepLinkManaging.self)
        let policy = container.service(RemoteConfigServicing.self).map(DeepLinkLaunchPolicy.make(from:))
        return [
            PluginDebugItem(id: "deeplink-service", title: "DeepLink Service", value: router == nil ? "Missing" : "Registered", systemImage: "link"),
            PluginDebugItem(id: "deeplink-enabled", title: "Deep Links Enabled", value: policy?.deepLinksEnabled == true ? "true" : "false", systemImage: "switch.2"),
            PluginDebugItem(id: "magiclink-enabled", title: "Magic Links Enabled", value: policy?.magicLinksEnabled == true ? "true" : "false", systemImage: "envelope.badge"),
            PluginDebugItem(id: "deeplink-last", title: "Last Deep Link", value: router?.lastResult?.message ?? "None", systemImage: "clock")
        ]
    }

    func makeHealthChecks(container: AppContainer) -> [PluginHealthCheckResult] {
        [
            PluginHealthCheckResult(id: "deeplink-service", title: "DeepLinkManaging service", status: container.services.contains(DeepLinkManaging.self) ? .ready : .missingService("DeepLinkManaging is not registered."), recoverySuggestion: "Keep DeepLinkPlugin registered in PluginCatalog."),
            PluginHealthCheckResult(id: "deeplink-url-scheme", title: "URL Scheme", status: container.secrets.supabaseRedirectScheme.isEmpty ? .missingConfiguration("supabaseRedirectScheme is empty.") : .ready, recoverySuggestion: "Run Scripts/configure_supabase.py --redirect-scheme yourscheme and configure Supabase redirect URLs.")
        ]
    }
}
