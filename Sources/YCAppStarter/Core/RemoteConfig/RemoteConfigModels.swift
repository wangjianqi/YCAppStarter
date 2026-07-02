import Foundation

struct RemoteConfigKey: RawRepresentable, Hashable, Identifiable, Codable, ExpressibleByStringLiteral {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    init(stringLiteral value: String) {
        self.rawValue = value
    }

    var id: String { rawValue }
}

enum RemoteConfigKeys {
    static let reviewSafeModeEnabled: RemoteConfigKey = "review_safe_mode_enabled"
    static let featureKillSwitchEnabled: RemoteConfigKey = "feature_kill_switch_enabled"
    static let paywallEnabled: RemoteConfigKey = "paywall_enabled"
    static let paywallVariant: RemoteConfigKey = "paywall_variant"
    static let adsEnabled: RemoteConfigKey = "ads_enabled"
    static let admobBannerEnabled: RemoteConfigKey = "admob_banner_enabled"
    static let admobInterstitialEnabled: RemoteConfigKey = "admob_interstitial_enabled"
    static let admobRewardedEnabled: RemoteConfigKey = "admob_rewarded_enabled"
    static let promotionBannerEnabled: RemoteConfigKey = "promotion_banner_enabled"
    static let promotionTitle: RemoteConfigKey = "promotion_title"
    static let promotionMessage: RemoteConfigKey = "promotion_message"
    static let minimumSupportedBuild: RemoteConfigKey = "minimum_supported_build"
    static let maintenanceMessage: RemoteConfigKey = "maintenance_message"
    static let aiEnabled: RemoteConfigKey = "ai_enabled"
    static let aiStreamingEnabled: RemoteConfigKey = "ai_streaming_enabled"
    static let aiVisionEnabled: RemoteConfigKey = "ai_vision_enabled"
    static let aiDefaultModel: RemoteConfigKey = "ai_default_model"
    static let aiDailyQuota: RemoteConfigKey = "ai_daily_quota"
    static let authEnabled: RemoteConfigKey = "auth_enabled"
    static let authRequireLoginForAI: RemoteConfigKey = "auth_require_login_for_ai"
    static let authAllowEmailPassword: RemoteConfigKey = "auth_allow_email_password"
    static let authAllowApple: RemoteConfigKey = "auth_allow_apple"
    static let profileSyncEnabled: RemoteConfigKey = "profile_sync_enabled"
    static let membershipSyncEnabled: RemoteConfigKey = "membership_sync_enabled"
    static let aiUsageSyncEnabled: RemoteConfigKey = "ai_usage_sync_enabled"

    static let pushEnabled: RemoteConfigKey = "push_enabled"
    static let pushMarketingEnabled: RemoteConfigKey = "push_marketing_enabled"
    static let pushTransactionalEnabled: RemoteConfigKey = "push_transactional_enabled"
    static let deepLinksEnabled: RemoteConfigKey = "deep_links_enabled"
    static let magicLinksEnabled: RemoteConfigKey = "magic_links_enabled"
    static let accountCenterEnabled: RemoteConfigKey = "account_center_enabled"
    static let accountDeletionEnabled: RemoteConfigKey = "account_deletion_enabled"
    static let dataExportEnabled: RemoteConfigKey = "data_export_enabled"

    static let widgetEnabled: RemoteConfigKey = "widget_enabled"
    static let widgetRefreshMinutes: RemoteConfigKey = "widget_refresh_minutes"
    static let liveActivityEnabled: RemoteConfigKey = "live_activity_enabled"
    static let dynamicIslandEnabled: RemoteConfigKey = "dynamic_island_enabled"
    static let liveActivityPushUpdatesEnabled: RemoteConfigKey = "live_activity_push_updates_enabled"

    static let productionReadinessEnabled: RemoteConfigKey = "production_readiness_enabled"
    static let ciValidationRequired: RemoteConfigKey = "ci_validation_required"
    static let storeKitTestEnabled: RemoteConfigKey = "storekit_test_enabled"
    static let eventCatalogEnforced: RemoteConfigKey = "event_catalog_enforced"
    static let releasePackagingEnabled: RemoteConfigKey = "release_packaging_enabled"
    static let minimumTestCoveragePercent: RemoteConfigKey = "minimum_test_coverage_percent"
    static let preflightBlockOnWarnings: RemoteConfigKey = "preflight_block_on_warnings"

    static let launchCriticalKeys: [RemoteConfigKey] = [
        reviewSafeModeEnabled,
        featureKillSwitchEnabled,
        paywallEnabled,
        paywallVariant,
        adsEnabled,
        admobBannerEnabled,
        admobInterstitialEnabled,
        admobRewardedEnabled,
        promotionBannerEnabled,
        minimumSupportedBuild,
        aiEnabled,
        aiStreamingEnabled,
        aiVisionEnabled,
        aiDailyQuota,
        authEnabled,
        authRequireLoginForAI,
        authAllowEmailPassword,
        authAllowApple,
        profileSyncEnabled,
        membershipSyncEnabled,
        aiUsageSyncEnabled,
        pushEnabled,
        pushMarketingEnabled,
        pushTransactionalEnabled,
        deepLinksEnabled,
        magicLinksEnabled,
        accountCenterEnabled,
        accountDeletionEnabled,
        dataExportEnabled,
        widgetEnabled,
        widgetRefreshMinutes,
        liveActivityEnabled,
        dynamicIslandEnabled,
        liveActivityPushUpdatesEnabled,
        productionReadinessEnabled,
        ciValidationRequired,
        storeKitTestEnabled,
        eventCatalogEnforced,
        releasePackagingEnabled,
        minimumTestCoveragePercent,
        preflightBlockOnWarnings
    ]
}

enum RemoteConfigSource: String, Codable, Hashable {
    case bundledJSON
    case firebase
    case memory
    case fallback

    var displayName: String {
        switch self {
        case .bundledJSON: return "Bundled JSON"
        case .firebase: return "Firebase Remote Config"
        case .memory: return "Memory Override"
        case .fallback: return "Fallback"
        }
    }
}

struct RemoteConfigEntry: Identifiable, Hashable {
    let key: RemoteConfigKey
    let value: RemoteConfigValue
    let source: RemoteConfigSource
    let description: String

    var id: String { key.rawValue }
}

struct RemoteConfigSnapshot: Hashable {
    let values: [RemoteConfigKey: RemoteConfigValue]
    let source: RemoteConfigSource
    let fetchedAt: Date?
    let lastErrorMessage: String?

    static let empty = RemoteConfigSnapshot(values: [:], source: .fallback, fetchedAt: nil, lastErrorMessage: nil)

    var sortedEntries: [RemoteConfigEntry] {
        values.keys.sorted { $0.rawValue < $1.rawValue }.map { key in
            RemoteConfigEntry(
                key: key,
                value: values[key] ?? .string(""),
                source: source,
                description: RemoteConfigKeyMetadata.description(for: key)
            )
        }
    }
}

enum RemoteConfigKeyMetadata {
    static func description(for key: RemoteConfigKey) -> String {
        switch key {
        case RemoteConfigKeys.reviewSafeModeEnabled:
            return "When true, disables risky launch surfaces such as ads, aggressive paywalls and experimental features."
        case RemoteConfigKeys.featureKillSwitchEnabled:
            return "Global emergency switch. When true, plugin-managed growth surfaces should be hidden."
        case RemoteConfigKeys.paywallEnabled:
            return "Controls whether paywall entry points are visible."
        case RemoteConfigKeys.paywallVariant:
            return "Paywall template variant: minimal, hero or comparison."
        case RemoteConfigKeys.adsEnabled:
            return "Controls whether ad placements may be displayed."
        case RemoteConfigKeys.admobBannerEnabled:
            return "Controls whether banner placements may be loaded. Runtime policy still suppresses banners in review safe mode, kill switch and premium ad-free states."
        case RemoteConfigKeys.admobInterstitialEnabled:
            return "Controls whether interstitial placements may be loaded at natural breaks."
        case RemoteConfigKeys.admobRewardedEnabled:
            return "Controls whether rewarded ads may be loaded and presented."
        case RemoteConfigKeys.promotionBannerEnabled:
            return "Controls the local promotion banner."
        case RemoteConfigKeys.promotionTitle:
            return "Promotion banner title."
        case RemoteConfigKeys.promotionMessage:
            return "Promotion banner subtitle or body copy."
        case RemoteConfigKeys.minimumSupportedBuild:
            return "Optional minimum build gate for future force-upgrade flows."
        case RemoteConfigKeys.maintenanceMessage:
            return "Optional maintenance or incident message."
        case RemoteConfigKeys.aiEnabled:
            return "Controls whether AI entry points are visible and requestable."
        case RemoteConfigKeys.aiStreamingEnabled:
            return "Controls streaming AI text responses."
        case RemoteConfigKeys.aiVisionEnabled:
            return "Controls image/vision analysis requests."
        case RemoteConfigKeys.aiDefaultModel:
            return "Default model name passed to the AI proxy."
        case RemoteConfigKeys.aiDailyQuota:
            return "Soft daily quota displayed in app and enforced by the sample backend."
        case RemoteConfigKeys.authEnabled:
            return "Controls whether auth entry points are visible and operational."
        case RemoteConfigKeys.authRequireLoginForAI:
            return "When true, AI calls should require a signed-in Supabase user session."
        case RemoteConfigKeys.authAllowEmailPassword:
            return "Controls email/password auth visibility."
        case RemoteConfigKeys.authAllowApple:
            return "Controls Sign in with Apple visibility."
        case RemoteConfigKeys.profileSyncEnabled:
            return "Controls user profile reads/writes to Supabase profiles table."
        case RemoteConfigKeys.membershipSyncEnabled:
            return "Controls syncing RevenueCat membership state into the profiles table."
        case RemoteConfigKeys.aiUsageSyncEnabled:
            return "Controls syncing AI usage counters into the profiles table."
        case RemoteConfigKeys.pushEnabled:
            return "Controls whether push registration and push entry points are enabled."
        case RemoteConfigKeys.pushMarketingEnabled:
            return "Controls non-critical marketing push opt-in surfaces."
        case RemoteConfigKeys.pushTransactionalEnabled:
            return "Controls transactional push surfaces such as account or purchase notifications."
        case RemoteConfigKeys.deepLinksEnabled:
            return "Controls whether incoming custom scheme and universal-link URLs are routed."
        case RemoteConfigKeys.magicLinksEnabled:
            return "Controls Supabase email magic link callback handling."
        case RemoteConfigKeys.accountCenterEnabled:
            return "Controls account center visibility."
        case RemoteConfigKeys.accountDeletionEnabled:
            return "Controls delete-account request surfaces."
        case RemoteConfigKeys.dataExportEnabled:
            return "Controls data export request surfaces."
        case RemoteConfigKeys.widgetEnabled:
            return "Controls widget data export to the shared App Group and widget entry points."
        case RemoteConfigKeys.widgetRefreshMinutes:
            return "Default widget timeline refresh interval in minutes."
        case RemoteConfigKeys.liveActivityEnabled:
            return "Controls whether Live Activity entry points may be started."
        case RemoteConfigKeys.dynamicIslandEnabled:
            return "Controls whether Dynamic Island-specific surfaces are presented."
        case RemoteConfigKeys.liveActivityPushUpdatesEnabled:
            return "Controls whether Live Activity push-token related surfaces are visible."
        case RemoteConfigKeys.productionReadinessEnabled:
            return "Controls whether production readiness surfaces are visible."
        case RemoteConfigKeys.ciValidationRequired:
            return "Controls whether CI validation is treated as a launch-critical requirement."
        case RemoteConfigKeys.storeKitTestEnabled:
            return "Controls whether StoreKit test tooling is visible in debug surfaces."
        case RemoteConfigKeys.eventCatalogEnforced:
            return "Controls whether analytics event catalog checks are enforced."
        case RemoteConfigKeys.releasePackagingEnabled:
            return "Controls whether release packaging surfaces are visible."
        case RemoteConfigKeys.minimumTestCoveragePercent:
            return "Minimum expected test coverage percentage for release readiness reporting."
        case RemoteConfigKeys.preflightBlockOnWarnings:
            return "When true, preflight warnings should block production release validation."
        default:
            return "Custom remote configuration key."
        }
    }
}
