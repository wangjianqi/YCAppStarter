import XCTest
@testable import YCAppStarter

final class FeatureFlagsTests: XCTestCase {
    func testProductionReadinessFeatureIsEnabledByDefault() {
        XCTAssertTrue(FeatureFlags.default.isEnabled(.productionReadiness))
    }

    func testV30FeatureIntroducedVersion() {
        XCTAssertEqual(AppFeature.productionReadiness.introducedIn, .v30)
    }
}
