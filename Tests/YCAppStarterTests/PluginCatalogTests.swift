import XCTest
@testable import YCAppStarter

@MainActor
final class PluginCatalogTests: XCTestCase {
    func testPluginIDsAreUnique() {
        let ids = PluginCatalog.makeDefaultCatalog().map { $0.descriptor.id }
        XCTAssertEqual(ids.count, Set(ids).count)
    }

    func testProductionPluginIsRegistered() {
        let ids = PluginCatalog.makeDefaultCatalog().map { $0.descriptor.id }
        XCTAssertTrue(ids.contains("yc.production.readiness"))
    }
}
