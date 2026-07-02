import SwiftUI

struct BackendDebugView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var health: BackendHealth?
    @State private var isLoading = false

    private let endpoints: [BackendEndpoint] = [
        BackendEndpoint(path: "/health", method: "GET", description: "Worker health and provider metadata."),
        BackendEndpoint(path: "/v1/ai/quota", method: "GET", description: "Quota snapshot for the current client token."),
        BackendEndpoint(path: "/v1/ai/complete", method: "POST", description: "Non-streaming text completion proxy."),
        BackendEndpoint(path: "/v1/ai/stream", method: "POST", description: "Server-sent events streaming proxy."),
        BackendEndpoint(path: "/v1/ai/vision", method: "POST", description: "Vision/image analysis proxy.")
    ]

    var body: some View {
        List {
            Section("Backend") {
                LabeledContent("Base URL", value: container.service(BackendClient.self)?.baseURL?.absoluteString ?? "Missing")
                if let health {
                    LabeledContent("Status", value: health.status)
                    if let version = health.version { LabeledContent("Version", value: version) }
                    if let provider = health.provider { LabeledContent("Provider", value: provider) }
                    if let message = health.message { Text(message).font(.caption).foregroundStyle(.secondary) }
                }
                Button {
                    Task { await refresh() }
                } label: {
                    Label("Check Health", systemImage: "heart.text.square")
                }
                if isLoading { ProgressView() }
            }

            Section("Template Endpoints") {
                ForEach(endpoints) { endpoint in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(endpoint.method)
                                .font(.caption.monospaced().bold())
                            Text(endpoint.path)
                                .font(.callout.monospaced())
                        }
                        Text(endpoint.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Backend Kit")
        .task { await refresh() }
    }

    private func refresh() async {
        isLoading = true
        health = await container.service(BackendClient.self)?.health()
        isLoading = false
    }
}
