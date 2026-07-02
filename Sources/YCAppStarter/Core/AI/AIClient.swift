import Foundation

@MainActor
protocol AIClient: AnyObject {
    var baseURL: URL? { get }
    var lastEventMessage: String? { get }

    func health() async -> AIProxyHealth
    func quota() async -> AIQuotaSnapshot?
    func complete(prompt: String, systemPrompt: String?, model: String?, container: AppContainer) async throws -> AITextResponse
    func analyzeImage(imageData: Data, mimeType: String, prompt: String, model: String?, container: AppContainer) async throws -> AITextResponse
    func stream(prompt: String, systemPrompt: String?, model: String?, container: AppContainer) -> AsyncThrowingStream<String, Error>
}

@MainActor
final class AIProxyClient: AIClient {
    let baseURL: URL?
    private let clientToken: String
    private let logger: AppLogging
    private(set) var lastEventMessage: String?

    init(baseURLString: String, clientToken: String, logger: AppLogging) {
        let trimmed = baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)
        self.baseURL = trimmed.isEmpty ? nil : URL(string: trimmed)
        self.clientToken = clientToken
        self.logger = logger
    }

    func health() async -> AIProxyHealth {
        do {
            return try await get("/health", as: AIProxyHealth.self)
        } catch {
            lastEventMessage = error.localizedDescription
            return AIProxyHealth(status: "unavailable", provider: nil, defaultModel: nil, message: error.localizedDescription)
        }
    }

    func quota() async -> AIQuotaSnapshot? {
        try? await get("/v1/ai/quota", as: AIQuotaSnapshot.self)
    }

    func complete(prompt: String, systemPrompt: String?, model: String?, container: AppContainer) async throws -> AITextResponse {
        try validateTextRequest(prompt: prompt, container: container)
        let request = AITextRequest(prompt: prompt, systemPrompt: systemPrompt, model: model)
        return try await post("/v1/ai/complete", body: request, as: AITextResponse.self, authToken: await container.service(AuthManaging.self)?.accessToken())
    }

    func analyzeImage(imageData: Data, mimeType: String, prompt: String, model: String?, container: AppContainer) async throws -> AITextResponse {
        try validateTextRequest(prompt: prompt, container: container)
        guard policy(container: container).visionEnabled else { throw AIProxyError.visionDisabled }
        let request = AIVisionRequest(
            prompt: prompt,
            imageBase64: imageData.base64EncodedString(),
            mimeType: mimeType,
            model: model
        )
        return try await post("/v1/ai/vision", body: request, as: AITextResponse.self, authToken: await container.service(AuthManaging.self)?.accessToken())
    }

    func stream(prompt: String, systemPrompt: String?, model: String?, container: AppContainer) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task { @MainActor in
                do {
                    try validateTextRequest(prompt: prompt, container: container)
                    guard policy(container: container).streamingEnabled else { throw AIProxyError.streamingDisabled }
                    var request = try makeRequest(path: "/v1/ai/stream", method: "POST", authToken: await container.service(AuthManaging.self)?.accessToken())
                    request.httpBody = try JSONEncoder().encode(AITextRequest(prompt: prompt, systemPrompt: systemPrompt, model: model))
                    request.setValue("text/event-stream", forHTTPHeaderField: "Accept")

                    let (bytes, response) = try await URLSession.shared.bytes(for: request)
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                    guard (200..<300).contains(statusCode) else {
                        throw AIProxyError.httpStatus(statusCode, "Streaming request failed.")
                    }

                    for try await line in bytes.lines {
                        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard trimmed.hasPrefix("data:") else { continue }
                        let payload = String(trimmed.dropFirst(5)).trimmingCharacters(in: .whitespacesAndNewlines)
                        if payload == "[DONE]" {
                            continuation.finish()
                            return
                        }
                        if let data = payload.data(using: .utf8), let event = try? JSONDecoder().decode(AIStreamEvent.self, from: data) {
                            if let error = event.error { throw AIProxyError.transport(error) }
                            if event.done == true { continuation.finish(); return }
                            if let delta = event.delta ?? event.text, !delta.isEmpty {
                                continuation.yield(delta)
                            }
                        } else if !payload.isEmpty {
                            continuation.yield(payload)
                        }
                    }
                    continuation.finish()
                } catch {
                    lastEventMessage = error.localizedDescription
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    private func policy(container: AppContainer) -> AILaunchPolicy {
        if let remoteConfig = container.service(RemoteConfigServicing.self) {
            return AILaunchPolicy.make(from: remoteConfig)
        }
        return AILaunchPolicy(isEnabled: false, streamingEnabled: false, visionEnabled: false, defaultModel: "gpt-5.5-mini", dailyQuota: 0)
    }

    private func validateTextRequest(prompt: String, container: AppContainer) throws {
        guard !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw AIProxyError.emptyPrompt }
        guard policy(container: container).isEnabled else { throw AIProxyError.disabledByPolicy }
        guard baseURL != nil else { throw AIProxyError.missingProxyBaseURL }
        if let remoteConfig = container.service(RemoteConfigServicing.self), AuthLaunchPolicy.make(from: remoteConfig).requireLoginForAI {
            guard container.service(AuthManaging.self)?.snapshot.isSignedIn == true else { throw AIProxyError.transport("AI requires a signed-in Supabase user.") }
        }
    }

    private func get<Response: Decodable>(_ path: String, as type: Response.Type) async throws -> Response {
        let request = try makeRequest(path: path, method: "GET")
        return try await perform(request, as: type)
    }

    private func post<Body: Encodable, Response: Decodable>(_ path: String, body: Body, as type: Response.Type, authToken: String? = nil) async throws -> Response {
        var request = try makeRequest(path: path, method: "POST", authToken: authToken)
        request.httpBody = try JSONEncoder().encode(body)
        return try await perform(request, as: type)
    }

    private func makeRequest(path: String, method: String, authToken: String? = nil) throws -> URLRequest {
        guard let baseURL else { throw AIProxyError.missingProxyBaseURL }
        guard let url = URL(string: path, relativeTo: baseURL) else { throw AIProxyError.invalidProxyURL(path) }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if !clientToken.isEmpty {
            request.setValue(clientToken, forHTTPHeaderField: "X-Starter-Client-Token")
        }
        if let authToken, !authToken.isEmpty {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    private func perform<Response: Decodable>(_ request: URLRequest, as type: Response.Type) async throws -> Response {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            guard (200..<300).contains(statusCode) else {
                let body = String(data: data, encoding: .utf8) ?? ""
                lastEventMessage = "HTTP \(statusCode)"
                throw AIProxyError.httpStatus(statusCode, body)
            }
            do {
                let decoded = try JSONDecoder().decode(type, from: data)
                lastEventMessage = "\(request.httpMethod ?? "GET") \(request.url?.path ?? "") succeeded"
                return decoded
            } catch {
                throw AIProxyError.decodingFailed(error.localizedDescription)
            }
        } catch let error as AIProxyError {
            throw error
        } catch {
            logger.error("AI proxy request failed: \(error.localizedDescription)")
            throw AIProxyError.transport(error.localizedDescription)
        }
    }
}
