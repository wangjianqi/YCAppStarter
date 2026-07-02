import Foundation

@MainActor
protocol PrivacyRequestManaging: AnyObject {
    var snapshot: PrivacyRequestSnapshot { get }
    func requestDataExport(auth: AuthManaging) async throws
    func requestAccountDeletion(auth: AuthManaging, reason: String?) async throws
}

@MainActor
final class PrivacyRequestManager: PrivacyRequestManaging, ObservableObject {
    @Published private(set) var snapshot: PrivacyRequestSnapshot = .empty
    private let logger: AppLogging

    init(logger: AppLogging) {
        self.logger = logger
    }

    func requestDataExport(auth: AuthManaging) async throws {
        try await auth.requestDataExport()
        snapshot = PrivacyRequestSnapshot(lastType: .dataExport, lastStatus: .pending, lastMessage: "Data export request submitted.", updatedAt: Date())
        logger.info("Privacy request submitted: data_export")
    }

    func requestAccountDeletion(auth: AuthManaging, reason: String?) async throws {
        try await auth.requestAccountDeletion(reason: reason)
        snapshot = PrivacyRequestSnapshot(lastType: .deleteAccount, lastStatus: .pending, lastMessage: "Account deletion request submitted.", updatedAt: Date())
        logger.warning("Privacy request submitted: delete_account")
    }
}
