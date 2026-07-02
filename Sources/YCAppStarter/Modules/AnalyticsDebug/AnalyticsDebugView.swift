import SwiftUI

struct AnalyticsDebugView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var lastAction = "No test event sent"

    var body: some View {
        List {
            Section("Provider") {
                LabeledContent("AnalyticsTracking", value: container.services.contains(AnalyticsTracking.self) ? "Registered" : "Missing")
                LabeledContent("CrashReporting", value: container.services.contains(CrashReporting.self) ? "Registered" : "Missing")
                LabeledContent("Firebase Config", value: container.secrets.hasValue(for: .firebaseGoogleServiceInfo) ? "Configured" : "Missing")
            }

            Section("Actions") {
                Button {
                    container.service(AnalyticsTracking.self)?.track(AnalyticsEvent("debug_test_event", parameters: ["source": "analytics_debug"]))
                    lastAction = "Sent debug_test_event"
                } label: {
                    Label("Send Test Analytics Event", systemImage: "paperplane")
                }

                Button(role: .destructive) {
                    let error = NSError(domain: "YCAppStarterDebug", code: 220, userInfo: [NSLocalizedDescriptionKey: "Manual non-fatal test error"])
                    container.service(CrashReporting.self)?.record(error: error, userInfo: ["source": "analytics_debug"])
                    lastAction = "Recorded non-fatal test error"
                } label: {
                    Label("Record Non-Fatal Test Error", systemImage: "exclamationmark.triangle")
                }

                Text(lastAction)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Notes") {
                Text("Firebase Analytics events may not appear instantly. Use Firebase DebugView when validating event flow on device.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Analytics Debug")
    }
}
