import Foundation

struct AIProxyPlugin: AppPlugin {
    let descriptor = PluginDescriptor(
        id: "yc.ai.proxy",
        displayName: "AI Proxy",
        version: .v26,
        feature: .aiProxy,
        category: .growth,
        dependencies: [.remoteConfig, .backendKit],
        optionalDependencies: [.analytics, .firebase],
        requiredSecrets: [],
        requiredServices: [
            ServiceRequirement("YCAppStarter.AIClient"),
            ServiceRequirement("YCAppStarter.RemoteConfigServicing")
        ],
        isRemovable: true,
        summary: "Adds a client-side AI abstraction backed by a Cloudflare Workers/Hono proxy for text, streaming and vision requests."
    )

    func registerServices(in registry: ServiceRegistry, secrets: AppSecrets, logger: AppLogging) {
        registry.register(AIClient.self, service: AIProxyClient(baseURLString: secrets.openAIProxyBaseURL, clientToken: secrets.aiProxyClientToken, logger: logger))
    }

    func makeHomeItems(container: AppContainer) -> [PluginHomeItem] {
        [PluginHomeItem(id: "ai-debug", title: "AI Proxy", subtitle: "Text, streaming, vision and quota", systemImage: "sparkles", route: .aiDebug)]
    }

    func makeSettingsItems(container: AppContainer) -> [PluginSettingsItem] {
        [PluginSettingsItem(id: "ai-settings", title: "AI Proxy", subtitle: "Inspect AI policy, quota and backend health", systemImage: "sparkles", route: .aiDebug)]
    }

    func makeDebugItems(container: AppContainer) -> [PluginDebugItem] {
        let ai = container.service(AIClient.self)
        let policy = container.service(RemoteConfigServicing.self).map { AILaunchPolicy.make(from: $0) }
        return [
            PluginDebugItem(id: "ai-policy-enabled", title: "AI Enabled", value: policy?.isEnabled == true ? "true" : "false", systemImage: "switch.2"),
            PluginDebugItem(id: "ai-default-model", title: "AI Default Model", value: policy?.defaultModel ?? "Missing", systemImage: "brain"),
            PluginDebugItem(id: "ai-base-url", title: "AI Proxy URL", value: ai?.baseURL?.absoluteString ?? "Missing", systemImage: "link"),
            PluginDebugItem(id: "ai-last-event", title: "AI Last Event", value: ai?.lastEventMessage ?? "None", systemImage: "text.bubble")
        ]
    }

    func makeHealthChecks(container: AppContainer) -> [PluginHealthCheckResult] {
        var checks = AppPluginDefaultHealth.defaultChecks(descriptor: descriptor, container: container)
        let ai = container.service(AIClient.self)
        let remoteConfig = container.service(RemoteConfigServicing.self)
        let policy = remoteConfig.map { AILaunchPolicy.make(from: $0) }

        checks.append(PluginHealthCheckResult(
            id: "ai-client-service",
            title: "AIClient service",
            status: ai == nil ? .missingService("AIClient is not registered.") : .ready,
            recoverySuggestion: "Keep AIProxyPlugin registered in PluginCatalog."
        ))
        checks.append(PluginHealthCheckResult(
            id: "ai-policy",
            title: "AI Launch Policy",
            status: policy?.isEnabled == true ? .ready : .warning("AI is currently disabled by Remote Config, Review Safe Mode or Kill Switch."),
            recoverySuggestion: "Set ai_enabled=true and ensure review_safe_mode_enabled=false when AI should be visible."
        ))
        checks.append(PluginHealthCheckResult(
            id: "ai-client-token",
            title: "Client Token",
            status: container.secrets.aiProxyClientToken.isEmpty ? .warning("AI proxy client token is empty. The sample backend can run without it, but production should require it.") : .ready,
            recoverySuggestion: "Set AppSecrets.aiProxyClientToken and AI_PROXY_CLIENT_TOKEN in the Worker secret/env file."
        ))
        return checks
    }
}
