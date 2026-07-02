import Foundation

@MainActor
protocol PushManaging: AnyObject {
    var snapshot: PushTokenSnapshot { get }
    var isConfigured: Bool { get }

    func configure(container: AppContainer) async
    func refreshAuthorizationStatus() async
    func requestAuthorization() async -> Bool
    func registerForRemoteNotifications()
    func refreshFCMToken() async
    func clearBadge()
    func recordOpenedDeepLink(_ url: URL)
}
