import Foundation

struct AdMobPlugin: AppPlugin {
    let descriptor = PluginDescriptor(
        id: "yc.ads.admob",
        displayName: "AdMob SDK",
        version: .v25,
        feature: .admob,
        category: .monetization,
        dependencies: [.remoteConfig, .umpConsent],
        optionalDependencies: [.analytics, .revenueCat, .adMobCompliance],
        requiredSecrets: [.admobAppID],
        requiredServices: [
            ServiceRequirement("YCAppStarter.RemoteConfigServicing"),
            ServiceRequirement("YCAppStarter.AdConsentManaging")
        ],
        isRemovable: true,
        summary: "Integrates Google Mobile Ads SDK with banner, interstitial and rewarded wrappers controlled by Remote Config, UMP and review safe mode."
    )

    func registerServices(in registry: ServiceRegistry, secrets: AppSecrets, logger: AppLogging) {
        registry.register(AdManaging.self, service: GoogleAdMobManager(secrets: secrets))
    }

    func configure(container: AppContainer) async {
        await container.service(AdManaging.self)?.configure(container: container)
    }

    func makeHomeItems(container: AppContainer) -> [PluginHomeItem] {
        [
            PluginHomeItem(
                id: "ad-debug",
                title: "Ad Debug",
                subtitle: "AdMob, UMP and placements",
                systemImage: "rectangle.3.group",
                route: .adDebug
            )
        ]
    }

    func makeSettingsItems(container: AppContainer) -> [PluginSettingsItem] {
        [
            PluginSettingsItem(
                id: "ad-debug-settings",
                title: "Ad Debug",
                subtitle: "Inspect AdMob policy, test IDs and UMP status",
                systemImage: "rectangle.3.group",
                route: .adDebug
            )
        ]
    }

    func makeDebugItems(container: AppContainer) -> [PluginDebugItem] {
        let manager = container.service(AdManaging.self)
        let policy = AdPolicy.make(container: container)
        return [
            PluginDebugItem(id: "admob-sdk-started", title: "AdMob SDK Started", value: manager?.isSDKStarted == true ? "true" : "false", systemImage: "play.circle"),
            PluginDebugItem(id: "admob-effective-policy", title: "Can Load Ads", value: policy.canLoadAnyAd ? "true" : "false", systemImage: "switch.2"),
            PluginDebugItem(id: "admob-last-event", title: "Last Ad Event", value: manager?.lastEventMessage ?? "None", systemImage: "text.bubble")
        ]
    }

    func makeHealthChecks(container: AppContainer) -> [PluginHealthCheckResult] {
        var checks = AppPluginDefaultHealth.defaultChecks(descriptor: descriptor, container: container)
        let manager = container.service(AdManaging.self)
        let consent = container.service(AdConsentManaging.self)
        let policy = AdPolicy.make(container: container)

        checks.append(
            PluginHealthCheckResult(
                id: "admob-service",
                title: "AdManaging service",
                status: manager == nil ? .missingService("AdManaging is not registered.") : .ready,
                recoverySuggestion: "Enable .admob and keep AdMobPlugin registered in PluginCatalog."
            )
        )

        checks.append(
            PluginHealthCheckResult(
                id: "ump-service-for-admob",
                title: "UMP consent service",
                status: consent == nil ? .missingDependency("AdConsentManaging is missing.") : .ready,
                recoverySuggestion: "Enable UMPConsentPlugin before AdMobPlugin."
            )
        )

        if container.secrets.admobAppID.contains("3940256099942544") {
            checks.append(
                PluginHealthCheckResult(
                    id: "admob-sample-app-id",
                    title: "Sample App ID",
                    status: .warning("The starter still uses Google's sample AdMob App ID."),
                    recoverySuggestion: "Replace GADApplicationIdentifier in Info.plist and AppSecrets.admobAppID before release."
                )
            )
        }

        if manager?.placements.contains(where: { $0.isUsingGoogleTestID }) == true {
            checks.append(
                PluginHealthCheckResult(
                    id: "admob-test-units",
                    title: "Test Ad Unit IDs",
                    status: .warning("One or more placements use Google test ad unit IDs."),
                    recoverySuggestion: "Keep test IDs for development; replace every ad unit ID before shipping."
                )
            )
        }

        if !policy.adsEnabled {
            checks.append(
                PluginHealthCheckResult(
                    id: "remote-ads-disabled",
                    title: "Remote ads_enabled",
                    status: .warning("Remote Config currently disables ads."),
                    recoverySuggestion: "Set ads_enabled=true and placement-specific switches when you are ready to test ads."
                )
            )
        }

        if policy.reviewSafeModeEnabled || policy.globalKillSwitchEnabled {
            checks.append(
                PluginHealthCheckResult(
                    id: "ad-policy-safe-mode",
                    title: "Safe mode policy",
                    status: .warning("Review Safe Mode or Global Kill Switch suppresses ad loading."),
                    recoverySuggestion: "This is expected for review-safe builds. Disable only after approval if appropriate."
                )
            )
        }

        return checks
    }
}
