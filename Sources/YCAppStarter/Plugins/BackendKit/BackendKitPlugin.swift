import Foundation

struct BackendKitPlugin: AppPlugin {
    let descriptor = PluginDescriptor(
        id: "yc.backend-kit",
        displayName: "Backend Kit",
        version: .v26,
        feature: .backendKit,
        category: .core,
        dependencies: [.remoteConfig],
        optionalDependencies: [.firebase, .aiProxy],
        requiredSecrets: [],
        requiredServices: [ServiceRequirement("YCAppStarter.BackendClient")],
        isRemovable: true,
        summary: "Provides a thin URLSession backend client and Cloudflare Workers/Hono backend template integration points."
    )

    func registerServices(in registry: ServiceRegistry, secrets: AppSecrets, logger: AppLogging) {
        let baseURL = secrets.backendBaseURL.isEmpty ? secrets.openAIProxyBaseURL : secrets.backendBaseURL
        registry.register(BackendClient.self, service: HTTPBackendClient(baseURLString: baseURL, clientToken: secrets.aiProxyClientToken, logger: logger))
    }

    func makeHomeItems(container: AppContainer) -> [PluginHomeItem] {
        [PluginHomeItem(id: "backend-debug", title: "Backend", subtitle: "Health and endpoint checks", systemImage: "server.rack", route: .backendDebug)]
    }

    func makeSettingsItems(container: AppContainer) -> [PluginSettingsItem] {
        [PluginSettingsItem(id: "backend-settings", title: "Backend Kit", subtitle: "Inspect proxy backend health", systemImage: "server.rack", route: .backendDebug)]
    }

    func makeDebugItems(container: AppContainer) -> [PluginDebugItem] {
        let backend = container.service(BackendClient.self)
        return [
            PluginDebugItem(id: "backend-base-url", title: "Backend Base URL", value: backend?.baseURL?.absoluteString ?? "Missing", systemImage: "link"),
            PluginDebugItem(id: "backend-last-event", title: "Backend Last Event", value: backend?.lastEventMessage ?? "None", systemImage: "text.bubble")
        ]
    }

    func makeHealthChecks(container: AppContainer) -> [PluginHealthCheckResult] {
        var checks = AppPluginDefaultHealth.defaultChecks(descriptor: descriptor, container: container)
        let hasService = container.services.contains(BackendClient.self)
        checks.append(PluginHealthCheckResult(
            id: "backend-client-service",
            title: "BackendClient service",
            status: hasService ? .ready : .missingService("BackendClient is not registered."),
            recoverySuggestion: "Keep BackendKitPlugin registered before AIProxyPlugin."
        ))
        if container.secrets.backendBaseURL.isEmpty && container.secrets.openAIProxyBaseURL.isEmpty {
            checks.append(PluginHealthCheckResult(
                id: "backend-base-url-empty",
                title: "Backend URL",
                status: .warning("Backend URL is empty. Backend health checks and AI proxy calls will be unavailable."),
                recoverySuggestion: "Run Scripts/configure_ai_proxy.py --base-url https://your-worker.your-subdomain.workers.dev."
            ))
        }
        return checks
    }
}
