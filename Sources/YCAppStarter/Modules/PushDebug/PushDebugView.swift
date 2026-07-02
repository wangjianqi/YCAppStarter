import SwiftUI

struct PushDebugView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var isWorking = false

    var body: some View {
        List {
            Section("Policy") {
                if let remote = container.service(RemoteConfigServicing.self) {
                    let policy = PushLaunchPolicy.make(from: remote)
                    LabeledContent("Push Enabled", value: policy.isPushEnabled ? "true" : "false")
                    LabeledContent("Marketing", value: policy.marketingPushEnabled ? "true" : "false")
                    LabeledContent("Transactional", value: policy.transactionalPushEnabled ? "true" : "false")
                }
            }

            Section("Token State") {
                if let push = container.service(PushManaging.self) {
                    LabeledContent("Configured", value: push.isConfigured ? "true" : "false")
                    LabeledContent("Authorization", value: push.snapshot.authorizationState.displayName)
                    LabeledContent("FCM Token", value: push.snapshot.fcmTokenPreview ?? "None")
                    LabeledContent("APNs Token", value: push.snapshot.apnsTokenPreview ?? "Handled by AppDelegate")
                    LabeledContent("Last Error", value: push.snapshot.lastRegistrationError ?? "None")
                    LabeledContent("Last Message", value: push.snapshot.lastMessageID ?? "None")
                } else {
                    Text("PushManaging is not registered.")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Actions") {
                Button("Request Authorization") { Task { await requestAuthorization() } }
                Button("Register Remote Notifications") { container.service(PushManaging.self)?.registerForRemoteNotifications() }
                Button("Refresh FCM Token") { Task { await container.service(PushManaging.self)?.refreshFCMToken() } }
                Button("Clear Badge") { container.service(PushManaging.self)?.clearBadge() }
            }
        }
        .navigationTitle("Push Debug")
        .disabled(isWorking)
    }

    private func requestAuthorization() async {
        isWorking = true
        _ = await container.service(PushManaging.self)?.requestAuthorization()
        isWorking = false
    }
}
