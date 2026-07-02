import Foundation

enum AppRoute: Hashable, Identifiable {
    case settings
    case paywall
    case debug
    case analyticsDebug
    case purchaseDebug
    case appStoreLaunch
    case metadataTemplates
    case privacyAudit
    case localizationAudit
    case adMobCompliance
    case adDebug
    case remoteConfig
    case reviewSafeMode
    case aiDebug
    case backendDebug
    case authDebug
    case userProfile
    case pushDebug
    case deepLinkDebug
    case accountCenter
    case privacyRequests
    case widgetDebug
    case liveActivityDebug
    case dynamicIslandDebug
    case productionReadiness
    case environmentDebug
    case storeKitDebug
    case legal(LegalDocument)
    case pluginDetail(String)

    var id: String {
        switch self {
        case .settings: return "settings"
        case .paywall: return "paywall"
        case .debug: return "debug"
        case .analyticsDebug: return "analytics-debug"
        case .purchaseDebug: return "purchase-debug"
        case .appStoreLaunch: return "app-store-launch"
        case .metadataTemplates: return "metadata-templates"
        case .privacyAudit: return "privacy-audit"
        case .localizationAudit: return "localization-audit"
        case .adMobCompliance: return "admob-compliance"
        case .adDebug: return "ad-debug"
        case .remoteConfig: return "remote-config"
        case .reviewSafeMode: return "review-safe-mode"
        case .aiDebug: return "ai-debug"
        case .backendDebug: return "backend-debug"
        case .authDebug: return "auth-debug"
        case .userProfile: return "user-profile"
        case .pushDebug: return "push-debug"
        case .deepLinkDebug: return "deep-link-debug"
        case .accountCenter: return "account-center"
        case .privacyRequests: return "privacy-requests"
        case .widgetDebug: return "widget-debug"
        case .liveActivityDebug: return "live-activity-debug"
        case .dynamicIslandDebug: return "dynamic-island-debug"
        case .productionReadiness: return "production-readiness"
        case .environmentDebug: return "environment-debug"
        case .storeKitDebug: return "storekit-debug"
        case .legal(let document): return "legal-\(document.rawValue)"
        case .pluginDetail(let id): return "plugin-\(id)"
        }
    }
}
