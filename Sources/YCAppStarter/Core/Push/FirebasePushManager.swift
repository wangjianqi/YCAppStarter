import Foundation
import UserNotifications
import UIKit
#if canImport(FirebaseMessaging)
import FirebaseMessaging
#endif

@MainActor
final class FirebasePushManager: NSObject, PushManaging, ObservableObject {
    @Published private(set) var snapshot: PushTokenSnapshot = .empty

    private let logger: AppLogging
    private let secrets: AppSecrets

    var isConfigured: Bool {
        secrets.hasValue(for: .firebaseGoogleServiceInfo)
    }

    init(secrets: AppSecrets, logger: AppLogging) {
        self.secrets = secrets
        self.logger = logger
        super.init()
    }

    func configure(container: AppContainer) async {
        UNUserNotificationCenter.current().delegate = self
        await refreshAuthorizationStatus()
        #if canImport(FirebaseMessaging)
        Messaging.messaging().delegate = self
        #endif
        logger.info("Push manager configured.")
    }

    func refreshAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        snapshot.authorizationState = map(settings.authorizationStatus)
        snapshot.updatedAt = Date()
    }

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound, .provisional])
            await refreshAuthorizationStatus()
            if granted { registerForRemoteNotifications() }
            return granted
        } catch {
            snapshot.lastRegistrationError = error.localizedDescription
            snapshot.updatedAt = Date()
            logger.error("Push authorization failed: \(error.localizedDescription)")
            return false
        }
    }

    func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
        logger.info("Requested APNs remote notification registration.")
    }

    func refreshFCMToken() async {
        #if canImport(FirebaseMessaging)
        do {
            let token = try await Messaging.messaging().token()
            snapshot.fcmTokenPreview = Self.preview(token)
            snapshot.updatedAt = Date()
            logger.info("FCM token refreshed.")
        } catch {
            snapshot.lastRegistrationError = error.localizedDescription
            snapshot.updatedAt = Date()
            logger.warning("FCM token refresh failed: \(error.localizedDescription)")
        }
        #else
        snapshot.lastRegistrationError = "FirebaseMessaging package is not available."
        snapshot.updatedAt = Date()
        #endif
    }

    func clearBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func recordOpenedDeepLink(_ url: URL) {
        snapshot.lastOpenedDeepLink = url
        snapshot.updatedAt = Date()
    }

    private func map(_ status: UNAuthorizationStatus) -> PushAuthorizationState {
        switch status {
        case .notDetermined: return .notDetermined
        case .denied: return .denied
        case .authorized: return .authorized
        case .provisional: return .provisional
        case .ephemeral: return .ephemeral
        @unknown default: return .unknown
        }
    }

    private static func preview(_ token: String) -> String {
        guard token.count > 18 else { return token }
        return "\(token.prefix(10))…\(token.suffix(6))"
    }
}

extension FirebasePushManager: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        await MainActor.run {
            self.snapshot.lastMessageID = response.notification.request.identifier
            self.snapshot.updatedAt = Date()
        }
    }
}

#if canImport(FirebaseMessaging)
extension FirebasePushManager: MessagingDelegate {
    nonisolated func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken else { return }
        Task { @MainActor in
            self.snapshot.fcmTokenPreview = Self.preview(fcmToken)
            self.snapshot.updatedAt = Date()
            self.logger.info("FCM registration token updated.")
        }
    }
}
#endif
