import Foundation

protocol BackendClient: AnyObject {
    var baseURL: URL? { get }
    var lastEventMessage: String? { get }

    func health() async -> BackendHealth
    func get<Response: Decodable>(_ path: String, as type: Response.Type) async throws -> Response
    func post<Body: Encodable, Response: Decodable>(_ path: String, body: Body, as type: Response.Type) async throws -> Response
}

final class HTTPBackendClient: BackendClient {
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

    func health() async -> BackendHealth {
        do {
            return try await get("/health", as: BackendHealth.self)
        } catch {
            lastEventMessage = error.localizedDescription
            return .unavailable
        }
    }

    func get<Response: Decodable>(_ path: String, as type: Response.Type) async throws -> Response {
        let request = try makeRequest(path: path, method: "GET")
        return try await perform(request, as: type)
    }

    func post<Body: Encodable, Response: Decodable>(_ path: String, body: Body, as type: Response.Type) async throws -> Response {
        var request = try makeRequest(path: path, method: "POST")
        request.httpBody = try JSONEncoder().encode(body)
        return try await perform(request, as: type)
    }

    private func makeRequest(path: String, method: String) throws -> URLRequest {
        guard let baseURL else { throw BackendError.missingBaseURL }
        guard let url = URL(string: path, relativeTo: baseURL) else { throw BackendError.invalidURL(path) }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if !clientToken.isEmpty {
            request.setValue(clientToken, forHTTPHeaderField: "X-Starter-Client-Token")
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
                throw BackendError.httpStatus(statusCode, body)
            }
            do {
                let decoded = try JSONDecoder().decode(type, from: data)
                lastEventMessage = "\(request.httpMethod ?? "GET") \(request.url?.path ?? "") succeeded"
                return decoded
            } catch {
                throw BackendError.decodingFailed(error.localizedDescription)
            }
        } catch let error as BackendError {
            throw error
        } catch {
            logger.error("Backend request failed: \(error.localizedDescription)")
            throw BackendError.transport(error.localizedDescription)
        }
    }
}
