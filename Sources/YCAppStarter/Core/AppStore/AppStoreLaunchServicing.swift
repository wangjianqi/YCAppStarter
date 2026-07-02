import Foundation

@MainActor
protocol AppStoreLaunchServicing {
    func makeReadinessReport(container: AppContainer) -> AppStoreReadinessReport
    func metadataTemplates() -> [MetadataTemplate]
    func privacyManifestAudit(container: AppContainer) -> [PrivacyManifestAuditResult]
    func localizationAudit(container: AppContainer) -> [LocalizationAuditResult]
}

@MainActor
struct DefaultAppStoreLaunchService: AppStoreLaunchServicing {
    func makeReadinessReport(container: AppContainer) -> AppStoreReadinessReport {
        var items: [AppStoreChecklistItem] = []
        let config = container.config
        let secrets = container.secrets

        items.append(AppStoreChecklistItem(
            id: "identity-display-name",
            title: "App display name",
            detail: config.displayName,
            status: config.displayName == "YCAppStarter" ? .warning : .passed,
            recoverySuggestion: "Run setup.sh and set the real App Store display name before submitting.",
            category: .identity
        ))

        items.append(AppStoreChecklistItem(
            id: "identity-bundle-id",
            title: "Bundle identifier",
            detail: config.bundleIdentifier,
            status: config.bundleIdentifier.contains("ycappstarter") ? .warning : .passed,
            recoverySuggestion: "Replace PRODUCT_BUNDLE_IDENTIFIER and AppConfig.bundleIdentifier with the final App Store bundle ID.",
            category: .identity
        ))

        items.append(AppStoreChecklistItem(
            id: "legal-privacy-url",
            title: "Privacy policy URL",
            detail: config.legalLinks.privacyPolicyURL.absoluteString,
            status: config.legalLinks.privacyPolicyURL.absoluteString.contains("example") ? .warning : .passed,
            recoverySuggestion: "Use a real privacy policy URL in AppConfig. Apple requires a privacy policy link in App Store metadata and inside the app.",
            category: .legal
        ))

        items.append(AppStoreChecklistItem(
            id: "legal-eula-url",
            title: "Terms / EULA link",
            detail: config.legalLinks.eulaURL.absoluteString,
            status: .manual,
            recoverySuggestion: "Confirm whether the Apple standard EULA is enough or your app needs custom terms.",
            category: .legal
        ))

        items.append(AppStoreChecklistItem(
            id: "monetization-revenuecat",
            title: "RevenueCat API key",
            detail: secrets.hasValue(for: .revenueCatAPIKey) ? "Configured" : "Missing",
            status: secrets.hasValue(for: .revenueCatAPIKey) ? .passed : .warning,
            recoverySuggestion: "Fill revenueCatAPIKey in AppSecrets.swift if the app uses subscriptions or lifetime purchase.",
            category: .monetization
        ))


        items.append(AppStoreChecklistItem(
            id: "auth-supabase-config",
            title: "Supabase Auth",
            detail: secrets.hasValue(for: .supabaseURL) && secrets.hasValue(for: .supabaseAnonKey) ? "Configured" : "Missing URL or key",
            status: container.flags.isEnabled(.supabaseAuth) ? ((secrets.hasValue(for: .supabaseURL) && secrets.hasValue(for: .supabaseAnonKey)) ? .passed : .warning) : .manual,
            recoverySuggestion: "If login is enabled, run Scripts/configure_supabase.py and verify the Apple provider, URL scheme and profiles RLS schema.",
            category: .review
        ))

        items.append(AppStoreChecklistItem(
            id: "analytics-firebase",
            title: "Firebase configuration",
            detail: secrets.hasValue(for: .firebaseGoogleServiceInfo) ? "GoogleService-Info.plist found" : "Missing plist",
            status: secrets.hasValue(for: .firebaseGoogleServiceInfo) ? .passed : .warning,
            recoverySuggestion: "Add Sources/YCAppStarter/Resources/GoogleService-Info.plist if Firebase Analytics or Crashlytics is enabled.",
            category: .analytics
        ))

        items.append(AppStoreChecklistItem(
            id: "privacy-manifest-file",
            title: "PrivacyInfo.xcprivacy",
            detail: privacyManifestExists() ? "Found" : "Missing",
            status: privacyManifestExists() ? .passed : .failed,
            recoverySuggestion: "Keep Resources/PrivacyInfo.xcprivacy in the target and update it when adding required-reason API usage or data collection.",
            category: .privacy
        ))

        items.append(AppStoreChecklistItem(
            id: "remote-config-defaults",
            title: "Remote Config defaults",
            detail: remoteConfigDefaultsExists() ? "Found" : "Missing",
            status: remoteConfigDefaultsExists() ? .passed : .failed,
            recoverySuggestion: "Keep Resources/RemoteConfigDefaults.json in the target so Review Safe Mode and Kill Switch have offline defaults.",
            category: .review
        ))

        if let remoteConfig = container.service(RemoteConfigServicing.self) {
            items.append(AppStoreChecklistItem(
                id: "review-safe-mode",
                title: "Review Safe Mode",
                detail: remoteConfig.isReviewSafeModeEnabled ? "Enabled" : "Disabled",
                status: remoteConfig.isReviewSafeModeEnabled ? .passed : .manual,
                recoverySuggestion: "Consider enabling review_safe_mode_enabled before App Review if ads, aggressive paywalls or experiments are active.",
                category: .review
            ))
        }

        items.append(AppStoreChecklistItem(
            id: "privacy-app-store-details",
            title: "App Privacy answers",
            detail: "Manual App Store Connect check",
            status: .manual,
            recoverySuggestion: "Complete Metadata/privacy_answers.md and keep it aligned with SDKs, analytics, ads and backend behavior.",
            category: .privacy
        ))

        items.append(AppStoreChecklistItem(
            id: "localization-xcstrings",
            title: "String catalog",
            detail: localizableCatalogExists() ? "Localizable.xcstrings found" : "Missing",
            status: localizableCatalogExists() ? .passed : .warning,
            recoverySuggestion: "Run Scripts/check_localization.py before release and add languages intentionally.",
            category: .localization
        ))

        items.append(AppStoreChecklistItem(
            id: "ads-admob-app-id",
            title: "AdMob App ID",
            detail: secrets.hasValue(for: .admobAppID) ? "Configured" : "Missing",
            status: container.flags.isEnabled(.admob) || container.flags.isEnabled(.adMobCompliance) ? (secrets.hasValue(for: .admobAppID) ? .passed : .warning) : .manual,
            recoverySuggestion: "If the app shows Google ads, add the real AdMob App ID, UMP flow and app-ads.txt verification.",
            category: .ads
        ))

        items.append(AppStoreChecklistItem(
            id: "review-notes-template",
            title: "Review notes template",
            detail: "Metadata/review_notes.md",
            status: metadataFileExists("review_notes.md") ? .passed : .warning,
            recoverySuggestion: "Complete the review notes before submitting builds that include subscriptions, login, camera, PiP, ads, AI or background modes.",
            category: .review
        ))

        return AppStoreReadinessReport(items: items)
    }

    func metadataTemplates() -> [MetadataTemplate] {
        [
            MetadataTemplate(id: "app-name", title: "App Name", filename: "app_name.md", summary: "Naming, subtitle and naming constraints.", path: "Metadata/app_name.md"),
            MetadataTemplate(id: "subtitle", title: "Subtitle", filename: "subtitle.md", summary: "Short App Store subtitle candidates.", path: "Metadata/subtitle.md"),
            MetadataTemplate(id: "keywords", title: "Keywords", filename: "keywords.md", summary: "ASO keyword bank and final keyword string.", path: "Metadata/keywords.md"),
            MetadataTemplate(id: "description", title: "Description", filename: "description.md", summary: "Long description template.", path: "Metadata/description.md"),
            MetadataTemplate(id: "whats-new", title: "What's New", filename: "whats_new.md", summary: "Release notes template.", path: "Metadata/whats_new.md"),
            MetadataTemplate(id: "review-notes", title: "Review Notes", filename: "review_notes.md", summary: "App Review notes for restricted features.", path: "Metadata/review_notes.md"),
            MetadataTemplate(id: "privacy-answers", title: "Privacy Answers", filename: "privacy_answers.md", summary: "App Privacy labels preparation.", path: "Metadata/privacy_answers.md"),
            MetadataTemplate(id: "screenshot-copy", title: "Screenshot Copy", filename: "screenshot_copy.md", summary: "Screenshot title/subtitle copy bank.", path: "Metadata/screenshot_copy.md")
        ]
    }

    func privacyManifestAudit(container: AppContainer) -> [PrivacyManifestAuditResult] {
        [
            PrivacyManifestAuditResult(
                id: "manifest-exists",
                title: "Manifest file exists",
                status: privacyManifestExists() ? .passed : .failed,
                message: privacyManifestExists() ? "Resources/PrivacyInfo.xcprivacy is present." : "PrivacyInfo.xcprivacy is missing.",
                recoverySuggestion: "Restore Sources/YCAppStarter/Resources/PrivacyInfo.xcprivacy."
            ),
            PrivacyManifestAuditResult(
                id: "manifest-required-reason",
                title: "Required Reason APIs",
                status: .manual,
                message: "Review file timestamp, disk space, UserDefaults and other required-reason API usage before every release.",
                recoverySuggestion: "Update NSPrivacyAccessedAPITypes in PrivacyInfo.xcprivacy and Docs/PrivacyManifest.md when adding SDKs or file/cache utilities."
            ),
            PrivacyManifestAuditResult(
                id: "manifest-third-party-sdk",
                title: "Third-party SDK manifests",
                status: .manual,
                message: "Check SDK privacy manifests for RevenueCat, Firebase, AdMob and future SDKs.",
                recoverySuggestion: "Keep SDK versions current and verify merged privacy reports in Xcode archive validation."
            )
        ]
    }

    func localizationAudit(container: AppContainer) -> [LocalizationAuditResult] {
        [
            LocalizationAuditResult(
                id: "string-catalog",
                title: "String catalog exists",
                status: localizableCatalogExists() ? .passed : .warning,
                message: localizableCatalogExists() ? "Localizable.xcstrings exists." : "Localizable.xcstrings was not found.",
                recoverySuggestion: "Keep user-facing strings in Localizable.xcstrings and run Scripts/check_localization.py."
            ),
            LocalizationAuditResult(
                id: "language-scope",
                title: "Language scope",
                status: .manual,
                message: "Confirm the first release language list intentionally. Avoid adding languages you cannot maintain.",
                recoverySuggestion: "Recommended first wave: English, Chinese Simplified, Japanese, Korean, German, French, Spanish."
            ),
            LocalizationAuditResult(
                id: "screenshots-localized",
                title: "Localized screenshot copy",
                status: .manual,
                message: "Screenshot text should match App Store locale and in-app terminology.",
                recoverySuggestion: "Use Metadata/screenshot_copy.md as the single source of screenshot copy."
            )
        ]
    }

    private func privacyManifestExists() -> Bool {
        Bundle.main.path(forResource: "PrivacyInfo", ofType: "xcprivacy") != nil
    }

    private func localizableCatalogExists() -> Bool {
        Bundle.main.path(forResource: "Localizable", ofType: "xcstrings") != nil
    }

    private func remoteConfigDefaultsExists() -> Bool {
        Bundle.main.path(forResource: "RemoteConfigDefaults", ofType: "json") != nil
    }

    private func metadataFileExists(_ filename: String) -> Bool {
        FileManager.default.fileExists(atPath: "Metadata/\(filename)")
    }
}
