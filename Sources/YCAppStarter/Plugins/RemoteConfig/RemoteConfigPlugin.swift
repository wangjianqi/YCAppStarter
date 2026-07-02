import Foundation

struct RemoteConfigPlugin: AppPlugin {
    let descriptor = PluginDescriptor(
        id: "yc.remote-config",
        displayName: "Remote Config",
        version: .v24,
        feature: .remoteConfig,
        category: .growth,
        dependencies: [.settings],
        optionalDependencies: [.firebase, .paywall, .adMobCompliance],
        requiredServices: [ServiceRequirement("RemoteConfigServicing")],
        isRemovable: true,
        summary: "Provides local JSON fallback, Firebase Remote Config adapter, review-safe mode, kill switch and runtime launch policy controls."
    )

    func registerServices(in registry: ServiceRegistry, secrets: AppSecrets, logger: AppLogging) {
        let fallback = LocalJSONRemoteConfigService(logger: logger)
        registry.registerIfAbsent(RemoteConfigServicing.self, service: fallback)
    }

    func configure(container: AppContainer) async {
        if container.secrets.hasValue(for: .firebaseGoogleServiceInfo) {
            let fallback = LocalJSONRemoteConfigService(logger: container.logger)
            let firebaseService = FirebaseRemoteConfigService(fallback: fallback, logger: container.logger)
            container.services.register(RemoteConfigServicing.self, service: firebaseService)
            await firebaseService.refresh()
            return
        }

        guard let remoteConfig = container.service(RemoteConfigServicing.self) else { return }
        await remoteConfig.refresh()
    }

    func makeHomeItems(container: AppContainer) -> [PluginHomeItem] {
        [
            PluginHomeItem(
                id: "remote-config",
                title: "Remote Config",
                subtitle: "Review mode, kill switch, paywall and ads control",
                systemImage: "switch.2",
                route: .remoteConfig
            )
        ]
    }

    func makeSettingsItems(container: AppContainer) -> [PluginSettingsItem] {
        [
            PluginSettingsItem(
                id: "remote-config-settings",
                title: "Remote Config",
                subtitle: "Inspect launch policy and runtime switches",
                systemImage: "switch.2",
                route: .remoteConfig
            ),
            PluginSettingsItem(
                id: "review-safe-mode-settings",
                title: "Review Safe Mode",
                subtitle: "Check audit-safe runtime switches before App Review",
                systemImage: "shield.lefthalf.filled",
                route: .reviewSafeMode
            )
        ]
    }

    func makeDebugItems(container: AppContainer) -> [PluginDebugItem] {
        guard let remoteConfig = container.service(RemoteConfigServicing.self) else {
            return [PluginDebugItem(id: "remote-config-service", title: "Remote Config", value: "Missing", systemImage: "xmark.octagon")]
        }

        let policy = LaunchPolicy.make(from: remoteConfig)
        return [
            PluginDebugItem(id: "remote-config-source", title: "Remote Config Source", value: remoteConfig.snapshot.source.displayName, systemImage: "switch.2"),
            PluginDebugItem(id: "review-safe-mode", title: "Review Safe Mode", value: policy.reviewSafeModeEnabled ? "Enabled" : "Disabled", systemImage: "shield"),
            PluginDebugItem(id: "kill-switch", title: "Kill Switch", value: policy.globalKillSwitchEnabled ? "Enabled" : "Disabled", systemImage: "bolt.slash"),
            PluginDebugItem(id: "paywall-variant", title: "Paywall Variant", value: policy.paywallVariant, systemImage: "rectangle.stack"),
            PluginDebugItem(id: "ads-enabled", title: "Ads Enabled", value: policy.adsEnabled ? "Yes" : "No", systemImage: "megaphone")
        ]
    }

    func makeHealthChecks(container: AppContainer) -> [PluginHealthCheckResult] {
        let hasService = container.services.contains(RemoteConfigServicing.self)
        let remoteConfig = container.service(RemoteConfigServicing.self)
        let hasBundledDefaults = Bundle.main.url(forResource: "RemoteConfigDefaults", withExtension: "json") != nil
        let snapshot = remoteConfig?.snapshot

        return [
            PluginHealthCheckResult(
                id: "service-remote-config",
                title: "RemoteConfigServicing",
                status: hasService ? .ready : .missingService("RemoteConfigServicing is not registered."),
                recoverySuggestion: "Ensure RemoteConfigPlugin.registerServices is called by PluginRuntimeFactory."
            ),
            PluginHealthCheckResult(
                id: "remote-config-defaults",
                title: "RemoteConfigDefaults.json",
                status: hasBundledDefaults ? .ready : .missingConfiguration("RemoteConfigDefaults.json is missing from bundled resources."),
                recoverySuggestion: "Restore Sources/YCAppStarter/Resources/RemoteConfigDefaults.json."
            ),
            PluginHealthCheckResult(
                id: "remote-config-source",
                title: "Runtime source",
                status: snapshot?.source == .firebase ? .ready : .warning("Using bundled JSON fallback instead of Firebase Remote Config."),
                recoverySuggestion: "Add GoogleService-Info.plist and enable Firebase Remote Config when remote operation is needed."
            ),
            PluginHealthCheckResult(
                id: "review-safe-mode",
                title: "Review Safe Mode",
                status: remoteConfig?.isReviewSafeModeEnabled == true ? .warning("Review Safe Mode is enabled. Paywalls, ads and experiments should be suppressed.") : .ready,
                recoverySuggestion: "Disable review_safe_mode_enabled after App Review if normal monetization should resume."
            )
        ]
    }
}
