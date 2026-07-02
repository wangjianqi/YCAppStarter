import Foundation

struct UMPConsentPlugin: AppPlugin {
    let descriptor = PluginDescriptor(
        id: "yc.ads.umpConsent",
        displayName: "UMP Consent",
        version: .v25,
        feature: .umpConsent,
        category: .monetization,
        dependencies: [.remoteConfig],
        optionalDependencies: [.firebase],
        requiredSecrets: [.admobAppID],
        requiredServices: [ServiceRequirement("YCAppStarter.RemoteConfigServicing")],
        isRemovable: true,
        summary: "Wraps Google's User Messaging Platform consent flow and exposes canRequestAds to AdMobPlugin."
    )

    func registerServices(in registry: ServiceRegistry, secrets: AppSecrets, logger: AppLogging) {
        registry.register(AdConsentManaging.self, service: GoogleUMPConsentManager(testDeviceIdentifiers: secrets.admobTestDeviceIdentifiers))
    }

    func configure(container: AppContainer) async {
        guard container.flags.isEnabled(.umpConsent) else { return }
        await container.service(AdConsentManaging.self)?.requestConsentIfNeeded()
    }

    func makeSettingsItems(container: AppContainer) -> [PluginSettingsItem] {
        guard container.service(AdConsentManaging.self)?.privacyOptionsRequired == true else { return [] }
        return [
            PluginSettingsItem(
                id: "ump-privacy-options",
                title: "Privacy Options",
                subtitle: "Open Google UMP privacy choices",
                systemImage: "hand.raised",
                route: .adDebug
            )
        ]
    }

    func makeDebugItems(container: AppContainer) -> [PluginDebugItem] {
        let consent = container.service(AdConsentManaging.self)
        return [
            PluginDebugItem(id: "ump-can-request-ads", title: "UMP canRequestAds", value: consent?.canRequestAds == true ? "true" : "false", systemImage: "hand.raised"),
            PluginDebugItem(id: "ump-status", title: "UMP Status", value: consent?.statusText ?? "Unavailable", systemImage: "checklist")
        ]
    }

    func makeHealthChecks(container: AppContainer) -> [PluginHealthCheckResult] {
        var checks = AppPluginDefaultHealth.defaultChecks(descriptor: descriptor, container: container)
        let consent = container.service(AdConsentManaging.self)
        checks.append(
            PluginHealthCheckResult(
                id: "ump-service",
                title: "AdConsentManaging service",
                status: consent == nil ? .missingService("AdConsentManaging is not registered.") : .ready,
                recoverySuggestion: "Enable .umpConsent and keep UMPConsentPlugin registered before AdMobPlugin."
            )
        )
        if let consent, !consent.canRequestAds {
            checks.append(
                PluginHealthCheckResult(
                    id: "ump-can-request-ads-runtime",
                    title: "Consent can request ads",
                    status: .warning("UMP has not allowed ad requests yet. This is normal before the consent flow completes."),
                    recoverySuggestion: "Run the app, wait for requestConsentInfoUpdate, then open Ad Debug."
                )
            )
        }
        return checks
    }
}
