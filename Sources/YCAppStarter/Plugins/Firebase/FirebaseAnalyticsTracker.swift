import Foundation
#if canImport(FirebaseAnalytics)
import FirebaseAnalytics
#endif

struct FirebaseAnalyticsTracker: AnalyticsTracking {
    func configure() {}

    func track(_ event: AnalyticsEvent) {
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent(event.name, parameters: event.parameters.mapValues { $0 as Any })
        #endif
    }

    func setUserID(_ userID: String?) {
        #if canImport(FirebaseAnalytics)
        Analytics.setUserID(userID)
        #endif
    }
}
