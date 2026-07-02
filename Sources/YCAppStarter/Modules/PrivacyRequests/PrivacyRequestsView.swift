import SwiftUI

struct PrivacyRequestsView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var deletionReason = ""
    @State private var statusMessage: String?
    @State private var isWorking = false

    var body: some View {
        List {
            Section("Policy") {
                if let remote = container.service(RemoteConfigServicing.self) {
                    let policy = AccountCenterPolicy.make(from: remote)
                    LabeledContent("Account Center", value: policy.accountCenterEnabled ? "Enabled" : "Disabled")
                    LabeledContent("Data Export", value: policy.dataExportEnabled ? "Enabled" : "Disabled")
                    LabeledContent("Delete Account", value: policy.accountDeletionEnabled ? "Enabled" : "Disabled")
                }
            }

            Section("Data Export") {
                Text("Creates a pending privacy request row in Supabase. Your production backend or admin workflow should process the export.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Button("Request Data Export") { Task { await requestExport() } }
            }

            Section("Delete Account") {
                Text("This starter submits a deletion request instead of deleting the auth user directly from the client. Use a trusted backend/admin workflow to complete deletion.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                TextField("Reason, optional", text: $deletionReason, axis: .vertical)
                Button(role: .destructive) { Task { await requestDeletion() } } label: {
                    Text("Request Account Deletion")
                }
            }

            if let statusMessage {
                Section("Status") {
                    Text(statusMessage)
                }
            }
        }
        .navigationTitle("Privacy Requests")
        .disabled(isWorking)
    }

    private func requestExport() async {
        guard let auth = container.service(AuthManaging.self), let privacy = container.service(PrivacyRequestManaging.self) else { return }
        isWorking = true
        do {
            try await privacy.requestDataExport(auth: auth)
            statusMessage = privacy.snapshot.lastMessage
        } catch {
            statusMessage = error.localizedDescription
        }
        isWorking = false
    }

    private func requestDeletion() async {
        guard let auth = container.service(AuthManaging.self), let privacy = container.service(PrivacyRequestManaging.self) else { return }
        isWorking = true
        do {
            try await privacy.requestAccountDeletion(auth: auth, reason: deletionReason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : deletionReason)
            statusMessage = privacy.snapshot.lastMessage
        } catch {
            statusMessage = error.localizedDescription
        }
        isWorking = false
    }
}
