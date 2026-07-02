import XCTest

final class ProductionReadinessStaticTests: XCTestCase {
    func testProjectUsesV31Version() throws {
        let text = try fixture("project.yml")
        XCTAssertTrue(text.contains("MARKETING_VERSION: 3.1.0"))
        XCTAssertTrue(text.contains("CURRENT_PROJECT_VERSION: 310"))
    }

    func testProjectWiresEnvironmentConfigFiles() throws {
        let text = try fixture("project.yml")
        XCTAssertTrue(text.contains("Config/Environments/Development.xcconfig"))
        XCTAssertTrue(text.contains("Config/Environments/Staging.xcconfig"))
        XCTAssertTrue(text.contains("Config/Environments/Production.xcconfig"))
    }

    func testInfoPlistHasBuildSettingKeys() throws {
        let text = try fixture("Sources/YCAppStarter/Info.plist")
        XCTAssertTrue(text.contains("YC_STARTER_ENVIRONMENT"))
        XCTAssertTrue(text.contains("YC_STARTER_APP_GROUP_IDENTIFIER"))
        XCTAssertTrue(text.contains("YC_STARTER_URL_SCHEME"))
    }

    private func fixture(_ relativePath: String) throws -> String {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return try String(contentsOf: root.appendingPathComponent(relativePath), encoding: .utf8)
    }
}
