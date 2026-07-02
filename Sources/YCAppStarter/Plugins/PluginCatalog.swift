import Foundation

@MainActor
enum PluginCatalog {
    static func makeDefaultCatalog() -> [AnyAppPlugin] {
        [
            AnyAppPlugin(OnboardingPlugin()),
            AnyAppPlugin(AnalyticsPlugin()),
            AnyAppPlugin(FirebasePlugin()),
            AnyAppPlugin(PurchasePlugin()),
            AnyAppPlugin(RevenueCatPlugin()),
            AnyAppPlugin(LocalNotificationsPlugin()),
            AnyAppPlugin(AppStoreLaunchPlugin()),
            AnyAppPlugin(AdMobCompliancePlugin()),
            AnyAppPlugin(RemoteConfigPlugin()),
            AnyAppPlugin(UMPConsentPlugin()),
            AnyAppPlugin(AdMobPlugin()),
            AnyAppPlugin(BackendKitPlugin()),
            AnyAppPlugin(AIProxyPlugin()),
            AnyAppPlugin(SupabaseAuthPlugin()),
            AnyAppPlugin(DeepLinkPlugin()),
            AnyAppPlugin(PushPlugin()),
            AnyAppPlugin(AccountCenterPlugin()),
            AnyAppPlugin(WidgetKitPlugin()),
            AnyAppPlugin(LiveActivityPlugin()),
            AnyAppPlugin(DynamicIslandPlugin()),
            AnyAppPlugin(ProductionReadinessPlugin()),
            AnyAppPlugin(SettingsPlugin()),
            AnyAppPlugin(DebugPlugin()),
            AnyAppPlugin(DemoFeaturePlugin())
        ]
    }
}
