import Foundation

struct DefaultProductionReadinessService: ProductionReadinessServicing {
    func makeReport(container: AppContainer) -> ProductionReadinessReport {
        let environment = BuildEnvironmentReader.current
        var checks: [ProductionReadinessCheck] = []

        checks.append(.init(
            id: "environment",
            title: "Build Environment",
            detail: environment.displayName,
            severity: environment == .production ? .pass : .warning,
            recovery: "Use the Production configuration for App Store builds."
        ))

        checks.append(.init(
            id: "revenuecat",
            title: "RevenueCat API Key",
            detail: container.secrets.revenueCatAPIKey.isEmpty ? "Missing" : "Configured",
            severity: container.secrets.revenueCatAPIKey.isEmpty ? .warning : .pass,
            recovery: "Fill AppSecrets.revenueCatAPIKey and verify StoreKit products before release."
        ))

        checks.append(.init(
            id: "firebase",
            title: "Firebase plist",
            detail: container.secrets.hasFirebaseGoogleServiceInfo ? "Configured" : "Not detected by template flag",
            severity: container.secrets.hasFirebaseGoogleServiceInfo ? .pass : .warning,
            recovery: "Add GoogleService-Info.plist to Resources and set hasFirebaseGoogleServiceInfo to true."
        ))

        checks.append(.init(
            id: "privacy",
            title: "Privacy Manifest",
            detail: "PrivacyInfo.xcprivacy is included in the starter resources.",
            severity: .pass,
            recovery: "Audit Required Reason API entries for each real app and SDK."
        ))

        checks.append(.init(
            id: "app-group",
            title: "App Group",
            detail: container.secrets.appGroupIdentifier,
            severity: container.secrets.appGroupIdentifier.hasPrefix("group.") ? .pass : .blocking,
            recovery: "Run Scripts/configure_app_group.py with the final App Group identifier."
        ))

        let pluginSnapshot = container.pluginRuntime.snapshot(container: container)
        checks.append(.init(
            id: "plugins",
            title: "Plugin Health",
            detail: pluginSnapshot.hasBlockingIssues ? "Blocking plugin issues detected" : "No blocking plugin issues",
            severity: pluginSnapshot.hasBlockingIssues ? .blocking : .pass,
            recovery: "Open Debug > Plugin Health and resolve missing dependencies or services."
        ))

        return ProductionReadinessReport(checks: checks)
    }
}
