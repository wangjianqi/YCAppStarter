import Foundation

enum AppFeature: String, CaseIterable, Identifiable, Hashable {
    case onboarding
    case paywall
    case analytics
    case crashlytics
    case revenueCat
    case firebase
    case localNotifications
    case remotePush
    case settings
    case debugPanel
    case demoFeature

    // V2 reserved features. They are intentionally disabled by default unless promoted by a later release.
    case aiAssistant
    case supabaseAuth
    case liveActivity
    case widget
    case scannerOCR
    case runtimeLocalization
    case admob
    case umpConsent
    case adDebug
    case remoteConfig

    // V2.6 AI + Backend Kit.
    case aiProxy
    case backendKit
    case aiDebug

    // V2.7 Supabase Auth + User Profile Kit.
    case authDebug
    case userProfile

    // V2.8 Push + Deep Link + Account Center.
    case pushNotifications
    case firebaseMessaging
    case pushDebug
    case deepLinks
    case deepLinkDebug
    case accountCenter
    case privacyRequests

    // V2.9 Widget + Live Activity + Dynamic Island Kit.
    case widgetKit
    case widgetDebug
    case liveActivityDebug
    case dynamicIsland

    // V3.0 Production Hardening Kit.
    case productionReadiness
    case environmentDebug
    case storeKitDebug
    case ciValidation
    case eventCatalog
    case releasePackaging

    // V2.4 Remote Operations.
    case reviewSafeMode
    case featureKillSwitch

    // V2.3 App Store Launch Kit.
    case appStoreLaunch
    case privacyManifestAudit
    case metadataTemplates
    case localizationAudit
    case adMobCompliance

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .onboarding: return "Onboarding"
        case .paywall: return "Paywall"
        case .analytics: return "Analytics"
        case .crashlytics: return "Crashlytics"
        case .revenueCat: return "RevenueCat"
        case .firebase: return "Firebase"
        case .localNotifications: return "Local Notifications"
        case .remotePush: return "Remote Push"
        case .settings: return "Settings"
        case .debugPanel: return "Debug Panel"
        case .demoFeature: return "Demo Feature"
        case .aiAssistant: return "AI Assistant"
        case .supabaseAuth: return "Supabase Auth"
        case .liveActivity: return "Live Activity"
        case .widget: return "Widget"
        case .scannerOCR: return "Scanner OCR"
        case .runtimeLocalization: return "Runtime Localization"
        case .admob: return "AdMob SDK"
        case .umpConsent: return "UMP Consent"
        case .adDebug: return "Ad Debug"
        case .remoteConfig: return "Remote Config"
        case .aiProxy: return "AI Proxy"
        case .backendKit: return "Backend Kit"
        case .aiDebug: return "AI Debug"
        case .authDebug: return "Auth Debug"
        case .userProfile: return "User Profile"
        case .pushNotifications: return "Push Notifications"
        case .firebaseMessaging: return "Firebase Messaging"
        case .pushDebug: return "Push Debug"
        case .deepLinks: return "Deep Links"
        case .deepLinkDebug: return "Deep Link Debug"
        case .accountCenter: return "Account Center"
        case .privacyRequests: return "Privacy Requests"
        case .widgetKit: return "WidgetKit"
        case .widgetDebug: return "Widget Debug"
        case .liveActivityDebug: return "Live Activity Debug"
        case .dynamicIsland: return "Dynamic Island"
        case .productionReadiness: return "Production Readiness"
        case .environmentDebug: return "Environment Debug"
        case .storeKitDebug: return "StoreKit Debug"
        case .ciValidation: return "CI Validation"
        case .eventCatalog: return "Event Catalog"
        case .releasePackaging: return "Release Packaging"
        case .reviewSafeMode: return "Review Safe Mode"
        case .featureKillSwitch: return "Feature Kill Switch"
        case .appStoreLaunch: return "App Store Launch"
        case .privacyManifestAudit: return "Privacy Manifest Audit"
        case .metadataTemplates: return "Metadata Templates"
        case .localizationAudit: return "Localization Audit"
        case .adMobCompliance: return "AdMob Compliance"
        }
    }

    var introducedIn: StarterVersion {
        switch self {
        case .onboarding, .paywall, .analytics, .crashlytics, .localNotifications, .remotePush, .settings, .debugPanel:
            return .v1
        case .demoFeature, .aiAssistant, .liveActivity, .widget, .scannerOCR, .runtimeLocalization:
            return .v2
        case .revenueCat, .firebase:
            return .v22
        case .admob, .umpConsent, .adDebug:
            return .v25
        case .appStoreLaunch, .privacyManifestAudit, .metadataTemplates, .localizationAudit, .adMobCompliance:
            return .v23
        case .remoteConfig, .reviewSafeMode, .featureKillSwitch:
            return .v24
        case .aiProxy, .backendKit, .aiDebug:
            return .v26
        case .supabaseAuth, .authDebug, .userProfile:
            return .v27
        case .pushNotifications, .firebaseMessaging, .pushDebug, .deepLinks, .deepLinkDebug, .accountCenter, .privacyRequests:
            return .v28
        case .widgetKit, .widgetDebug, .liveActivityDebug, .dynamicIsland:
            return .v29
        case .productionReadiness, .environmentDebug, .storeKitDebug, .ciValidation, .eventCatalog, .releasePackaging:
            return .v30
        }
    }
}

struct FeatureFlags: Equatable {
    private let enabledFeatures: Set<AppFeature>

    static let `default` = FeatureFlags(enabledFeatures: [
        .onboarding,
        .paywall,
        .analytics,
        .crashlytics,
        .revenueCat,
        .firebase,
        .localNotifications,
        .settings,
        .debugPanel,
        .demoFeature,
        .appStoreLaunch,
        .privacyManifestAudit,
        .metadataTemplates,
        .localizationAudit,
        .adMobCompliance,
        .admob,
        .umpConsent,
        .adDebug,
        .remoteConfig,
        .reviewSafeMode,
        .featureKillSwitch,
        .backendKit,
        .aiProxy,
        .aiDebug,
        .supabaseAuth,
        .authDebug,
        .userProfile,
        .pushNotifications,
        .firebaseMessaging,
        .pushDebug,
        .deepLinks,
        .deepLinkDebug,
        .accountCenter,
        .privacyRequests,
        .widget,
        .widgetKit,
        .widgetDebug,
        .liveActivity,
        .liveActivityDebug,
        .dynamicIsland,
        .productionReadiness,
        .environmentDebug,
        .storeKitDebug,
        .ciValidation,
        .eventCatalog,
        .releasePackaging
    ])

    init(enabledFeatures: Set<AppFeature>) {
        self.enabledFeatures = enabledFeatures
    }

    func isEnabled(_ feature: AppFeature) -> Bool {
        enabledFeatures.contains(feature)
    }

    var enabled: [AppFeature] {
        AppFeature.allCases.filter { enabledFeatures.contains($0) }
    }

    var disabled: [AppFeature] {
        AppFeature.allCases.filter { !enabledFeatures.contains($0) }
    }
}
