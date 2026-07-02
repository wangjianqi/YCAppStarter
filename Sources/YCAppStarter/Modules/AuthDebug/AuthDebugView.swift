import SwiftUI
import AuthenticationServices

struct AuthDebugView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var email = ""
    @State private var password = ""
    @State private var message: String?
    @State private var isWorking = false

    private var auth: AuthManaging? { container.service(AuthManaging.self) }
    private var policy: AuthLaunchPolicy? { container.service(RemoteConfigServicing.self).map { AuthLaunchPolicy.make(from: $0) } }

    var body: some View {
        List {
            Section("Status") {
                LabeledContent("Configured", value: auth?.isConfigured == true ? "true" : "false")
                LabeledContent("Signed In", value: auth?.snapshot.isSignedIn == true ? "true" : "false")
                LabeledContent("User", value: auth?.snapshot.user?.email ?? auth?.snapshot.user?.shortID ?? "None")
                LabeledContent("Provider", value: auth?.snapshot.provider ?? "Unknown")
                LabeledContent("Token", value: auth?.snapshot.accessTokenPreview ?? "None")
                LabeledContent("Expires", value: auth?.snapshot.expiresAt?.formatted(date: .abbreviated, time: .shortened) ?? "Unknown")
                LabeledContent("Last Event", value: auth?.lastEventMessage ?? "None")
            }

            Section("Launch Policy") {
                LabeledContent("Auth Enabled", value: policy?.isAuthEnabled == true ? "true" : "false")
                LabeledContent("Email Password", value: policy?.allowEmailPassword == true ? "true" : "false")
                LabeledContent("Apple", value: policy?.allowApple == true ? "true" : "false")
                LabeledContent("Require Login for AI", value: policy?.requireLoginForAI == true ? "true" : "false")
                LabeledContent("Profile Sync", value: policy?.profileSyncEnabled == true ? "true" : "false")
            }

            Section("Email / Password") {
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                SecureField("Password", text: $password)
                HStack {
                    Button("Sign In") { Task { await run { try await auth?.signIn(email: email, password: password) } } }
                    Spacer()
                    Button("Sign Up") { Task { await run { try await auth?.signUp(email: email, password: password) } } }
                }
                .disabled(isWorking || policy?.allowEmailPassword == false)
            }

            Section("Apple / Anonymous") {
                Button {
                    Task { await run { try await auth?.signInWithApple(container: container) } }
                } label: {
                    Label("Sign in with Apple", systemImage: "apple.logo")
                }
                .disabled(isWorking || policy?.allowApple == false)

                Button {
                    Task { await run { try await auth?.signInAnonymously() } }
                } label: {
                    Label("Sign in Anonymously", systemImage: "person.crop.circle.badge.questionmark")
                }
                .disabled(isWorking)
            }

            Section("Session") {
                Button("Refresh Session") { Task { await refresh() } }
                    .disabled(isWorking)
                Button("Fetch Profile") { Task { await fetchProfile() } }
                    .disabled(isWorking || auth?.snapshot.isSignedIn != true)
                Button(role: .destructive) { Task { await signOut() } } label: {
                    Text("Sign Out")
                }
                .disabled(isWorking || auth?.snapshot.isSignedIn != true)
            }

            if let message {
                Section("Message") {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Auth Debug")
    }

    @MainActor
    private func run(_ operation: @escaping () async throws -> AuthUser?) async {
        isWorking = true
        defer { isWorking = false }
        do {
            let user = try await operation()
            message = "OK: \(user?.email ?? user?.id ?? "done")"
        } catch {
            message = "Error: \(error.localizedDescription)"
        }
    }

    @MainActor
    private func refresh() async {
        isWorking = true
        await auth?.refreshSession()
        message = auth?.lastEventMessage ?? "Refreshed."
        isWorking = false
    }

    @MainActor
    private func fetchProfile() async {
        isWorking = true
        defer { isWorking = false }
        do {
            let profile = try await auth?.fetchProfile()
            message = "Profile: \(profile?.displayName ?? profile?.email ?? profile?.id ?? "missing")"
        } catch {
            message = "Error: \(error.localizedDescription)"
        }
    }

    @MainActor
    private func signOut() async {
        isWorking = true
        defer { isWorking = false }
        do {
            try await auth?.signOut()
            message = "Signed out."
        } catch {
            message = "Error: \(error.localizedDescription)"
        }
    }
}
