import Foundation

enum RemoteConfigValue: Codable, Equatable, Hashable, CustomStringConvertible {
    case bool(Bool)
    case string(String)
    case int(Int)
    case double(Double)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else {
            throw DecodingError.typeMismatch(
                RemoteConfigValue.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported remote config value type.")
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .bool(let value): try container.encode(value)
        case .string(let value): try container.encode(value)
        case .int(let value): try container.encode(value)
        case .double(let value): try container.encode(value)
        }
    }

    var boolValue: Bool? {
        switch self {
        case .bool(let value): return value
        case .string(let value): return ["true", "1", "yes", "on"].contains(value.lowercased())
        case .int(let value): return value != 0
        case .double(let value): return value != 0
        }
    }

    var stringValue: String {
        switch self {
        case .bool(let value): return value ? "true" : "false"
        case .string(let value): return value
        case .int(let value): return String(value)
        case .double(let value): return String(value)
        }
    }

    var intValue: Int? {
        switch self {
        case .bool(let value): return value ? 1 : 0
        case .string(let value): return Int(value)
        case .int(let value): return value
        case .double(let value): return Int(value)
        }
    }

    var doubleValue: Double? {
        switch self {
        case .bool(let value): return value ? 1 : 0
        case .string(let value): return Double(value)
        case .int(let value): return Double(value)
        case .double(let value): return value
        }
    }

    var description: String { stringValue }
}
