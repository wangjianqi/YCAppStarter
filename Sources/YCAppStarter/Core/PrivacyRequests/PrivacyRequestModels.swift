import Foundation

enum PrivacyRequestType: String, Codable, Hashable, CaseIterable, Identifiable {
    case dataExport = "data_export"
    case deleteAccount = "delete_account"

    var id: String { rawValue }
    var displayName: String { self == .dataExport ? "Data Export" : "Delete Account" }
}

enum PrivacyRequestStatus: String, Codable, Hashable, CaseIterable, Identifiable {
    case draft
    case pending
    case completed
    case rejected

    var id: String { rawValue }
}

struct PrivacyRequestSnapshot: Codable, Equatable, Hashable {
    var lastType: PrivacyRequestType?
    var lastStatus: PrivacyRequestStatus?
    var lastMessage: String?
    var updatedAt: Date?

    static let empty = PrivacyRequestSnapshot(lastType: nil, lastStatus: nil, lastMessage: nil, updatedAt: nil)
}

struct AccountCenterPolicy: Equatable, Hashable {
    let accountCenterEnabled: Bool
    let accountDeletionEnabled: Bool
    let dataExportEnabled: Bool

    @MainActor
    static func make(from remoteConfig: RemoteConfigServicing) -> AccountCenterPolicy {
        AccountCenterPolicy(
            accountCenterEnabled: !remoteConfig.isGlobalKillSwitchEnabled && remoteConfig.bool(RemoteConfigKeys.accountCenterEnabled, default: true),
            accountDeletionEnabled: !remoteConfig.isGlobalKillSwitchEnabled && remoteConfig.bool(RemoteConfigKeys.accountDeletionEnabled, default: true),
            dataExportEnabled: !remoteConfig.isGlobalKillSwitchEnabled && remoteConfig.bool(RemoteConfigKeys.dataExportEnabled, default: true)
        )
    }
}
