import Foundation

enum AnalyticsEventCatalog {
    static let allowedEventNames: Set<String> = [
        "app_launch",
        "onboarding_started",
        "onboarding_completed",
        "paywall_shown",
        "purchase_started",
        "purchase_completed",
        "purchase_restored",
        "ad_impression",
        "ai_request_started",
        "ai_request_completed",
        "account_delete_requested",
        "data_export_requested",
        "widget_snapshot_updated",
        "live_activity_started",
        "deep_link_opened"
    ]

    static func isAllowed(_ event: AnalyticsEvent) -> Bool {
        allowedEventNames.contains(event.name)
    }
}

extension AnalyticsEvent {
    static let appLaunch = AnalyticsEvent("app_launch")
    static let onboardingStarted = AnalyticsEvent("onboarding_started")
    static let onboardingCompleted = AnalyticsEvent("onboarding_completed")
    static func paywallShown(source: String) -> AnalyticsEvent { AnalyticsEvent("paywall_shown", parameters: ["source": source]) }
    static func deepLinkOpened(route: String) -> AnalyticsEvent { AnalyticsEvent("deep_link_opened", parameters: ["route": route]) }
}
