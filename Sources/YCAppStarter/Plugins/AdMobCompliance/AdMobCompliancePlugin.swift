import Foundation

struct AdMobCompliancePlugin: AppPlugin {
    let descriptor = PluginDescriptor(
        id: "yc.admob.compliance",
        displayName: "AdMob Compliance",
        version: .v25,
        feature: .adMobCompliance,
        category: .monetization,
        optionalDependencies: [.admob, .umpConsent, .analytics],
        requiredSecrets: [.admobAppID],
        isRemovable: true,
        summary: "Adds a release checklist for AdMob App ID, UMP consent flow, app-ads.txt and ad review readiness. V2.5 can link to the real AdMob/UMP debug flow."
    )

    func makeHomeItems(container: AppContainer) -> [PluginHomeItem] {
        [
            PluginHomeItem(
                id: "admob-compliance",
                title: "AdMob Compliance",
                subtitle: "UMP, app-ads.txt and ad readiness",
                systemImage: "megaphone",
                route: .adMobCompliance
            )
        ]
    }

    func makeSettingsItems(container: AppContainer) -> [PluginSettingsItem] {
        [
            PluginSettingsItem(
                id: "admob-compliance-settings",
                title: "AdMob Compliance",
                subtitle: "Check ads, consent and app-ads.txt before release",
                systemImage: "megaphone",
                route: .adMobCompliance
            )
        ]
    }

    func makeDebugItems(container: AppContainer) -> [PluginDebugItem] {
        [
            PluginDebugItem(
                id: "admob-app-id",
                title: "AdMob App ID",
                value: container.secrets.hasValue(for: .admobAppID) ? "Configured" : "Missing",
                systemImage: "megaphone"
            )
        ]
    }

    func makeHealthChecks(container: AppContainer) -> [PluginHealthCheckResult] {
        [
            PluginHealthCheckResult(
                id: "admob-app-id",
                title: "AdMob App ID",
                status: container.secrets.hasValue(for: .admobAppID) ? .ready : .warning("AdMob App ID is not configured."),
                recoverySuggestion: "Fill admobAppID in AppSecrets.swift if this app displays Google ads."
            ),
            PluginHealthCheckResult(
                id: "ump-flow",
                title: "UMP consent flow",
                status: .warning("UMPConsentPlugin is integrated; verify canRequestAds at runtime before loading ads."),
                recoverySuggestion: "Open Ad Debug and confirm requestConsentInfoUpdate runs on app launch."
            )
        ]
    }
}
