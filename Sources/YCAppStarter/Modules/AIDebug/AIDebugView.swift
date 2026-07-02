import SwiftUI

struct AIDebugView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var prompt = "Give me three concise App Store subtitle ideas for a camera utility app."
    @State private var systemPrompt = "You are a precise iOS product assistant."
    @State private var responseText = ""
    @State private var streamText = ""
    @State private var health: AIProxyHealth?
    @State private var quota: AIQuotaSnapshot?
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        List {
            policySection
            backendSection
            promptSection
            actionsSection
            responseSection
        }
        .navigationTitle("AI Proxy")
        .task { await refreshStatus() }
    }

    private var policySection: some View {
        let policy = container.service(RemoteConfigServicing.self).map { AILaunchPolicy.make(from: $0) }
        return Section("Runtime Policy") {
            LabeledContent("AI Enabled", value: policy?.isEnabled == true ? "Yes" : "No")
            LabeledContent("Streaming", value: policy?.streamingEnabled == true ? "Yes" : "No")
            LabeledContent("Vision", value: policy?.visionEnabled == true ? "Yes" : "No")
            LabeledContent("Default Model", value: policy?.defaultModel ?? "Missing")
            LabeledContent("Daily Quota", value: String(policy?.dailyQuota ?? 0))
            Text("Review Safe Mode and Kill Switch suppress AI entry points by default. Use Remote Config to enable AI after review-safe validation.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var backendSection: some View {
        let ai = container.service(AIClient.self)
        return Section("Proxy") {
            LabeledContent("Base URL", value: ai?.baseURL?.absoluteString ?? "Missing")
            if let health {
                LabeledContent("Health", value: health.status)
                if let provider = health.provider { LabeledContent("Provider", value: provider) }
                if let model = health.defaultModel { LabeledContent("Default Model", value: model) }
                if let message = health.message { Text(message).font(.caption).foregroundStyle(.secondary) }
            }
            if let quota {
                LabeledContent("Quota", value: "\(quota.used)/\(quota.limit)")
                LabeledContent("Remaining", value: String(quota.remaining))
                LabeledContent("Window", value: quota.window)
            }
        }
    }

    private var promptSection: some View {
        Section("Prompt") {
            TextField("System prompt", text: $systemPrompt, axis: .vertical)
            TextField("Prompt", text: $prompt, axis: .vertical)
                .lineLimit(4...8)
        }
    }

    private var actionsSection: some View {
        Section("Actions") {
            Button {
                Task { await refreshStatus() }
            } label: {
                Label("Refresh Health / Quota", systemImage: "arrow.clockwise")
            }
            Button {
                Task { await complete() }
            } label: {
                Label("Complete", systemImage: "text.bubble")
            }
            Button {
                Task { await stream() }
            } label: {
                Label("Stream", systemImage: "waveform")
            }
            .disabled(container.service(RemoteConfigServicing.self).map { AILaunchPolicy.make(from: $0).streamingEnabled } != true)
        }
    }

    private var responseSection: some View {
        Section("Result") {
            if isLoading { ProgressView() }
            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            if !responseText.isEmpty {
                Text(responseText)
                    .textSelection(.enabled)
            }
            if !streamText.isEmpty {
                Text(streamText)
                    .textSelection(.enabled)
            }
        }
    }

    private func refreshStatus() async {
        health = await container.service(AIClient.self)?.health()
        quota = await container.service(AIClient.self)?.quota()
    }

    private func complete() async {
        guard let ai = container.service(AIClient.self) else { return }
        isLoading = true
        errorMessage = nil
        responseText = ""
        do {
            let policy = container.service(RemoteConfigServicing.self).map { AILaunchPolicy.make(from: $0) }
            let result = try await ai.complete(prompt: prompt, systemPrompt: systemPrompt, model: policy?.defaultModel, container: container)
            responseText = result.text
            await refreshStatus()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func stream() async {
        guard let ai = container.service(AIClient.self) else { return }
        isLoading = true
        errorMessage = nil
        streamText = ""
        do {
            let policy = container.service(RemoteConfigServicing.self).map { AILaunchPolicy.make(from: $0) }
            for try await delta in ai.stream(prompt: prompt, systemPrompt: systemPrompt, model: policy?.defaultModel, container: container) {
                streamText += delta
            }
            await refreshStatus()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
