import Foundation

struct RevenueCatConfig: Equatable, Sendable {
    let apiKey: String
    let entitlementID: String
    let offeringID: String?
    let debugLogsEnabled: Bool

    static func from(secrets: AppSecrets) -> RevenueCatConfig {
        RevenueCatConfig(
            apiKey: secrets.revenueCatAPIKey,
            entitlementID: secrets.revenueCatEntitlementID,
            offeringID: secrets.revenueCatOfferingID,
            debugLogsEnabled: true
        )
    }

    var isConfigured: Bool {
        apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }
}
