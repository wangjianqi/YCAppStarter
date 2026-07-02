import Foundation

struct DefaultProductionReadinessService: ProductionReadinessServicing {
    @MainActor
    func makeReport(container: AppContainer) -> ProductionReadinessReport {
        let environment = BuildEnvironmentReader.current
        var checks: [ProductionReadinessCheck] = []
        let isProduction = environment == .production

        checks.append(.init(
            id: "environment",
            title: "Build Environment",
            detail: environment.displayName,
            severity: isProduction ? .pass : .warning,
            recovery: "Use the Production configuration for App Store builds."
        ))

        checks.append(.init(
            id: "bundle-id",
            title: "Bundle Identifier",
            detail: container.config.bundleIdentifier,
            severity: container.config.bundleIdentifier == "com.yuechuanlabs.ycappstarter" ? .warning : .pass,
            recovery: "Run setup.sh or Scripts/setup_config.py init with the final bundle identifier."
        ))

        checks.append(.init(
            id: "url-scheme",
            title: "URL Scheme",
            detail: container.secrets.supabaseRedirectScheme,
            severity: container.secrets.supabaseRedirectScheme == "ycappstarter" ? .warning : .pass,
            recovery: "Use a product-specific URL scheme and register the same callback in Supabase."
        ))

        checks.append(.init(
            id: "revenuecat",
            title: "RevenueCat API Key",
            detail: container.secrets.revenueCatAPIKey.isEmpty ? "Missing" : "Configured",
            severity: container.secrets.revenueCatAPIKey.isEmpty ? (isProduction ? .blocking : .warning) : .pass,
            recovery: "Fill AppSecrets.revenueCatAPIKey and verify StoreKit products before release."
        ))

        checks.append(.init(
            id: "firebase",
            title: "Firebase plist",
            detail: container.secrets.hasValue(for: .firebaseGoogleServiceInfo) ? "Configured" : "Missing",
            severity: container.secrets.hasValue(for: .firebaseGoogleServiceInfo) ? .pass : (isProduction ? .blocking : .warning),
            recovery: "Add GoogleService-Info.plist to Resources and set hasFirebaseGoogleServiceInfo to true."
        ))

        checks.append(.init(
            id: "supabase",
            title: "Supabase Credentials",
            detail: container.secrets.supabaseURL.isEmpty || container.secrets.supabaseAnonKey.isEmpty ? "Missing" : "Configured",
            severity: container.secrets.supabaseURL.isEmpty || container.secrets.supabaseAnonKey.isEmpty ? (isProduction ? .blocking : .warning) : .pass,
            recovery: "Run Scripts/configure_supabase.py with the final Supabase URL and anon key."
        ))

        let usesSampleAdMob = container.secrets.admobAppID.contains("3940256099942544")
            || container.secrets.admobBannerAdUnitID.contains("3940256099942544")
            || container.secrets.admobInterstitialAdUnitID.contains("3940256099942544")
            || container.secrets.admobRewardedAdUnitID.contains("3940256099942544")
        checks.append(.init(
            id: "admob",
            title: "AdMob Identifiers",
            detail: usesSampleAdMob ? "Google sample IDs" : "Configured",
            severity: usesSampleAdMob ? (isProduction ? .blocking : .warning) : .pass,
            recovery: "Run Scripts/configure_admob.py and replace all Google sample identifiers before production release."
        ))

        checks.append(.init(
            id: "privacy",
            title: "Privacy Manifest",
            detail: "PrivacyInfo.xcprivacy is included in the starter resources.",
            severity: .pass,
            recovery: "Audit Required Reason API entries for each real app and SDK."
        ))

        let appGroup = container.secrets.appGroupIdentifier
        let usesDefaultAppGroup = appGroup == "group.com.yuechuanlabs.ycappstarter"
        checks.append(.init(
            id: "app-group",
            title: "App Group",
            detail: appGroup,
            severity: !appGroup.hasPrefix("group.") ? .blocking : (usesDefaultAppGroup ? .warning : .pass),
            recovery: "Run Scripts/setup_config.py init with the final App Group identifier."
        ))

        checks.append(.init(
            id: "apns",
            title: "APNs Environment",
            detail: container.secrets.apnsEnvironment,
            severity: isProduction && container.secrets.apnsEnvironment != "production" ? .blocking : .pass,
            recovery: "Use production aps-environment for App Store builds and development for Debug/Staging."
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
