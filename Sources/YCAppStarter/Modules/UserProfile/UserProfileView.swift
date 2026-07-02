import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var message: String?
    @State private var displayName = ""
    @State private var aiUsedToday = 0
    @State private var isPremium = false

    private var auth: AuthManaging? { container.service(AuthManaging.self) }
    private var snapshot: AuthSessionSnapshot { auth?.snapshot ?? .signedOut }

    var body: some View {
        List {
            Section("User") {
                if let user = snapshot.user {
                    LabeledContent("ID", value: user.id)
                    LabeledContent("Email", value: user.email ?? "None")
                    LabeledContent("Display Name", value: snapshot.profile?.displayName ?? user.displayName ?? "None")
                    LabeledContent("Anonymous", value: user.isAnonymous ? "true" : "false")
                } else {
                    ContentUnavailableView("Signed Out", systemImage: "person.slash", description: Text("Sign in before syncing profile data."))
                }
            }

            Section("Profile Sync") {
                LabeledContent("Premium", value: snapshot.profile?.isPremium == true ? "true" : "false")
                LabeledContent("Entitlement", value: snapshot.profile?.entitlementID ?? "None")
                LabeledContent("AI Quota", value: "\(snapshot.profile?.aiUsedToday ?? 0)/\(snapshot.profile?.aiDailyQuota ?? 0)")
                TextField("Display Name", text: $displayName)
                Toggle("Premium", isOn: $isPremium)
                Stepper("AI Used Today: \(aiUsedToday)", value: $aiUsedToday, in: 0...999)
                Button("Upsert Profile") { Task { await upsertProfile() } }
                    .disabled(snapshot.user == nil)
            }

            Section("Actions") {
                Button("Fetch Profile") { Task { await fetchProfile() } }
                    .disabled(snapshot.user == nil)
                Button("Sync Membership from Purchase Manager") { Task { await syncMembership() } }
                    .disabled(snapshot.user == nil)
                Button("Increment AI Usage") { Task { await syncAIUsage() } }
                    .disabled(snapshot.user == nil)
            }

            if let message {
                Section("Message") {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("User Profile")
        .task { seedFields() }
    }

    @MainActor
    private func seedFields() {
        displayName = snapshot.profile?.displayName ?? snapshot.user?.displayName ?? ""
        aiUsedToday = snapshot.profile?.aiUsedToday ?? 0
        isPremium = snapshot.profile?.isPremium ?? false
    }

    @MainActor
    private func fetchProfile() async {
        do {
            _ = try await auth?.fetchProfile()
            seedFields()
            message = "Profile fetched."
        } catch {
            message = "Error: \(error.localizedDescription)"
        }
    }

    @MainActor
    private func upsertProfile() async {
        guard let user = snapshot.user else { return }
        var profile = snapshot.profile ?? UserProfile.empty(user: user)
        profile.displayName = displayName.isEmpty ? nil : displayName
        profile.email = user.email
        profile.isPremium = isPremium
        profile.aiUsedToday = aiUsedToday
        profile.updatedAt = Date()
        do {
            try await auth?.upsertProfile(profile)
            message = "Profile upserted."
        } catch {
            message = "Error: \(error.localizedDescription)"
        }
    }

    @MainActor
    private func syncMembership() async {
        let purchase = container.service(PurchaseManaging.self)
        do {
            try await auth?.syncMembership(isPremium: purchase?.entitlement.isPremium == true, entitlementID: container.secrets.revenueCatEntitlementID)
            message = "Membership synced."
        } catch {
            message = "Error: \(error.localizedDescription)"
        }
    }

    @MainActor
    private func syncAIUsage() async {
        do {
            try await auth?.syncAIUsage(delta: 1)
            seedFields()
            message = "AI usage incremented."
        } catch {
            message = "Error: \(error.localizedDescription)"
        }
    }
}
