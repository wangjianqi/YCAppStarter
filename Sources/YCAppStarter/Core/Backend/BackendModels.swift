import Foundation

struct BackendEndpoint: Hashable, Identifiable {
    let path: String
    let method: String
    let description: String

    var id: String { "\(method) \(path)" }
}

struct BackendHealth: Hashable, Codable {
    let status: String
    let version: String?
    let provider: String?
    let message: String?

    static let unavailable = BackendHealth(status: "unavailable", version: nil, provider: nil, message: "Backend is not configured.")
}

enum BackendError: LocalizedError, Hashable {
    case missingBaseURL
    case invalidURL(String)
    case httpStatus(Int, String)
    case decodingFailed(String)
    case transport(String)

    var errorDescription: String? {
        switch self {
        case .missingBaseURL: return "Backend base URL is not configured."
        case .invalidURL(let value): return "Invalid backend URL: \(value)"
        case .httpStatus(let code, let body): return "Backend returned HTTP \(code): \(body)"
        case .decodingFailed(let message): return "Backend response decoding failed: \(message)"
        case .transport(let message): return "Backend transport failed: \(message)"
        }
    }
}
