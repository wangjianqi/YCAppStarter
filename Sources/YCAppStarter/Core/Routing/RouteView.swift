import SwiftUI

struct RouteView: View {
    let route: AppRoute

    var body: some View {
        switch route {
        case .settings:
            SettingsView()
        case .paywall:
            PaywallView()
        case .debug:
            DebugPanelView()
        case .analyticsDebug:
            AnalyticsDebugView()
        case .purchaseDebug:
            PurchaseDebugView()
        case .appStoreLaunch:
            AppStoreLaunchView()
        case .metadataTemplates:
            MetadataTemplatesView()
        case .privacyAudit:
            PrivacyManifestAuditView()
        case .localizationAudit:
            LocalizationAuditView()
        case .adMobCompliance:
            AdMobComplianceView()
        case .adDebug:
            AdDebugView()
        case .remoteConfig:
            RemoteConfigView()
        case .reviewSafeMode:
            ReviewSafeModeView()
        case .aiDebug:
            AIDebugView()
        case .backendDebug:
            BackendDebugView()
        case .authDebug:
            AuthDebugView()
        case .userProfile:
            UserProfileView()
        case .pushDebug:
            PushDebugView()
        case .deepLinkDebug:
            DeepLinkDebugView()
        case .accountCenter:
            AccountCenterView()
        case .privacyRequests:
            PrivacyRequestsView()
        case .widgetDebug:
            WidgetDebugView()
        case .liveActivityDebug:
            LiveActivityDebugView()
        case .dynamicIslandDebug:
            DynamicIslandDebugView()
        case .productionReadiness:
            ProductionReadinessView()
        case .environmentDebug:
            EnvironmentDebugView()
        case .storeKitDebug:
            StoreKitDebugView()
        case .legal(let document):
            LegalWebView(document: document)
        case .pluginDetail(let pluginID):
            PluginDetailView(pluginID: pluginID)
        }
    }
}
