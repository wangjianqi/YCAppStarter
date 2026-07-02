import Foundation

struct NoopAnalyticsTracker: AnalyticsTracking {
    func configure() {}
    func track(_ event: AnalyticsEvent) {}
    func setUserID(_ userID: String?) {}
}
