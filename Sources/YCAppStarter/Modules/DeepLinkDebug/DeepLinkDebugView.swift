import SwiftUI

struct DeepLinkDebugView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var urlText = "ycappstarter://account-center"

    var body: some View {
        List {
            Section("Policy") {
                if let remote = container.service(RemoteConfigServicing.self) {
                    let policy = DeepLinkLaunchPolicy.make(from: remote)
                    LabeledContent("Deep Links", value: policy.deepLinksEnabled ? "Enabled" : "Disabled")
                    LabeledContent("Magic Links", value: policy.magicLinksEnabled ? "Enabled" : "Disabled")
                }
            }

            Section("Test URL") {
                TextField("URL", text: $urlText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                Button("Handle URL") { Task { await handleTypedURL() } }
            }

            Section("Examples") {
                example("ycappstarter://settings")
                example("ycappstarter://paywall")
                example("ycappstarter://profile")
                example("ycappstarter://privacy/delete-account")
                example("ycappstarter://auth/callback?type=magiclink")
            }

            Section("History") {
                if let router = container.service(DeepLinkManaging.self), !router.handledResults.isEmpty {
                    ForEach(router.handledResults) { result in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(result.action)
                                .font(.headline)
                            Text(result.url.absoluteString)
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)
                            Text(result.message)
                                .font(.caption)
                        }
                    }
                } else {
                    Text("No handled links yet.")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Deep Links")
    }

    private func example(_ value: String) -> some View {
        Button(value) { urlText = value }
    }

    private func handleTypedURL() async {
        guard let url = URL(string: urlText) else { return }
        _ = await container.service(DeepLinkManaging.self)?.handle(url: url, source: .customScheme, container: container)
    }
}
