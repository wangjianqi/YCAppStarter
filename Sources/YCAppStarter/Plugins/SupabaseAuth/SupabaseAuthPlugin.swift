import Foundation

struct SupabaseAuthPlugin: AppPlugin {
    let descriptor = PluginDescriptor(
        id: "yc.supabase.auth",
        displayName: "Supabase Auth",
        version: .v27,
        feature: .supabaseAuth,
        category: .core,
        dependencies: [.remoteConfig],
        optionalDependencies: [.backendKit, .revenueCat, .aiProxy],
        requiredSecrets: [.supabaseURL, .supabaseAnonKey],
        requiredServices: [
            ServiceRequirement("YCAppStarter.AuthManaging"),
            ServiceRequirement("YCAppStarter.RemoteConfigServicing")
        ],
        isRemovable: true,
        summary: "Adds Supabase email/password, anonymous and native Sign in with Apple auth with profile, membership and AI usage sync hooks."
    )

    func registerServices(in registry: ServiceRegistry, secrets: AppSecrets, logger: AppLogging) {
        registry.register(
            AuthManaging.self,
            service: SupabaseAuthManager(
                supabaseURL: secrets.supabaseURL,
                supabaseKey: secrets.supabaseAnonKey,
                redirectScheme: secrets.supabaseRedirectScheme,
                logger: logger
            )
        )
    }

    func configure(container: AppContainer) async {
        await container.service(AuthManaging.self)?.refreshSession()
    }

    func makeHomeItems(container: AppContainer) -> [PluginHomeItem] {
        [
            PluginHomeItem(id: "auth-debug", title: "Auth", subtitle: "Supabase session and login checks", systemImage: "person.crop.circle.badge.checkmark", route: .authDebug),
            PluginHomeItem(id: "user-profile", title: "Profile", subtitle: "Profile, membership and AI usage", systemImage: "person.text.rectangle", route: .userProfile)
        ]
    }

    func makeSettingsItems(container: AppContainer) -> [PluginSettingsItem] {
        [
            PluginSettingsItem(id: "auth-settings", title: "Supabase Auth", subtitle: "Inspect session and test login flows", systemImage: "person.badge.key", route: .authDebug),
            PluginSettingsItem(id: "profile-settings", title: "User Profile", subtitle: "View profile sync state", systemImage: "person.text.rectangle", route: .userProfile)
        ]
    }

    func makeDebugItems(container: AppContainer) -> [PluginDebugItem] {
        let auth = container.service(AuthManaging.self)
        let snapshot = auth?.snapshot
        return [
            PluginDebugItem(id: "auth-configured", title: "Supabase Configured", value: auth?.isConfigured == true ? "true" : "false", systemImage: "checkmark.seal"),
            PluginDebugItem(id: "auth-signed-in", title: "Signed In", value: snapshot?.isSignedIn == true ? "true" : "false", systemImage: "person.crop.circle"),
            PluginDebugItem(id: "auth-user", title: "User", value: snapshot?.user?.email ?? snapshot?.user?.shortID ?? "None", systemImage: "person"),
            PluginDebugItem(id: "auth-last-event", title: "Auth Last Event", value: auth?.lastEventMessage ?? "None", systemImage: "text.bubble")
        ]
    }

    func makeHealthChecks(container: AppContainer) -> [PluginHealthCheckResult] {
        var checks = AppPluginDefaultHealth.defaultChecks(descriptor: descriptor, container: container)
        let auth = container.service(AuthManaging.self)
        let policy = container.service(RemoteConfigServicing.self).map { AuthLaunchPolicy.make(from: $0) }
        checks.append(PluginHealthCheckResult(
            id: "auth-service",
            title: "AuthManaging service",
            status: auth == nil ? .missingService("AuthManaging is not registered.") : .ready,
            recoverySuggestion: "Keep SupabaseAuthPlugin registered in PluginCatalog."
        ))
        checks.append(PluginHealthCheckResult(
            id: "supabase-config",
            title: "Supabase Project Config",
            status: auth?.isConfigured == true ? .ready : .missingConfiguration("Supabase URL or publishable/anon key is empty."),
            recoverySuggestion: "Run Scripts/configure_supabase.py --url https://xxx.supabase.co --anon-key sb_publishable_xxx."
        ))
        checks.append(PluginHealthCheckResult(
            id: "auth-policy",
            title: "Auth Launch Policy",
            status: policy?.isAuthEnabled == true ? .ready : .warning("Auth is disabled by Remote Config, Review Safe Mode or Kill Switch."),
            recoverySuggestion: "Set auth_enabled=true and ensure review_safe_mode_enabled=false when auth should be visible."
        ))
        return checks
    }
}
