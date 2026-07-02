import Foundation
import UserNotifications

@MainActor
protocol LocalNotificationManaging {
    func requestAuthorization() async -> Bool
    func scheduleDemoNotification() async throws
}

@MainActor
final class LocalNotificationManager: LocalNotificationManaging {
    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    func scheduleDemoNotification() async throws {
        let content = UNMutableNotificationContent()
        content.title = "YCAppStarter"
        content.body = "Local notification plugin is working."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        try await UNUserNotificationCenter.current().add(request)
    }
}
