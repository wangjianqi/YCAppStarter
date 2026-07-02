import Foundation

struct AITextRequest: Encodable, Hashable {
    let prompt: String
    let systemPrompt: String?
    let model: String?
}

struct AIVisionRequest: Encodable, Hashable {
    let prompt: String
    let imageBase64: String
    let mimeType: String
    let model: String?
}

struct AITextResponse: Decodable, Hashable {
    let text: String
    let model: String?
    let provider: String?
    let usage: AIUsageSnapshot?
}

struct AIUsageSnapshot: Codable, Hashable {
    let inputTokens: Int?
    let outputTokens: Int?
    let totalTokens: Int?
}

struct AIQuotaSnapshot: Codable, Hashable {
    let limit: Int
    let used: Int
    let remaining: Int
    let window: String
}

struct AIProxyHealth: Codable, Hashable {
    let status: String
    let provider: String?
    let defaultModel: String?
    let message: String?
}

struct AIStreamEvent: Decodable, Hashable {
    let delta: String?
    let text: String?
    let done: Bool?
    let error: String?
}

enum AIProxyError: LocalizedError, Hashable {
    case disabledByPolicy
    case missingProxyBaseURL
    case invalidProxyURL(String)
    case httpStatus(Int, String)
    case emptyPrompt
    case visionDisabled
    case streamingDisabled
    case decodingFailed(String)
    case transport(String)

    var errorDescription: String? {
        switch self {
        case .disabledByPolicy: return "AI is disabled by Remote Config, Review Safe Mode or Kill Switch."
        case .missingProxyBaseURL: return "AI proxy base URL is not configured."
        case .invalidProxyURL(let value): return "Invalid AI proxy URL: \(value)"
        case .httpStatus(let code, let body): return "AI proxy returned HTTP \(code): \(body)"
        case .emptyPrompt: return "Prompt is empty."
        case .visionDisabled: return "Vision requests are disabled by policy."
        case .streamingDisabled: return "Streaming requests are disabled by policy."
        case .decodingFailed(let message): return "AI response decoding failed: \(message)"
        case .transport(let message): return "AI transport failed: \(message)"
        }
    }
}
