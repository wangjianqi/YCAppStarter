import SwiftUI

struct AccountCenterView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        List {
            Section("Session") {
                if let auth = container.service(AuthManaging.self) {
                    LabeledContent("Configured", value: auth.isConfigured ? "true" : "false")
                    LabeledContent("Signed In", value: auth.snapshot.isSignedIn ? "true" : "false")
                    LabeledContent("User", value: auth.snapshot.user?.email ?? auth.snapshot.user?.shortID ?? "None")
                    LabeledContent("Provider", value: auth.snapshot.provider ?? "None")
                    LabeledContent("Last Event", value: auth.lastEventMessage ?? "None")
                } else {
                    Text("AuthManaging is not registered.")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Profile") {
                Button("Open Profile") { container.router.push(.userProfile) }
                Button("Refresh Session") { Task { await container.service(AuthManaging.self)?.refreshSession() } }
            }

            Section("Privacy") {
                Button("Data Export / Delete Account") { container.router.push(.privacyRequests) }
            }

            Section("Deep Links") {
                Button("Open Deep Link Debug") { container.router.push(.deepLinkDebug) }
            }
        }
        .navigationTitle("Account Center")
    }
}
