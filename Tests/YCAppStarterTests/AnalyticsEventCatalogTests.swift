import XCTest
@testable import YCAppStarter

final class AnalyticsEventCatalogTests: XCTestCase {
    func testKnownEventIsAllowed() {
        XCTAssertTrue(AnalyticsEventCatalog.isAllowed(.appLaunch))
    }

    func testUnknownEventIsRejected() {
        XCTAssertFalse(AnalyticsEventCatalog.isAllowed(AnalyticsEvent("random_event")))
    }
}
