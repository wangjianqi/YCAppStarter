import Foundation

enum LegalDocument: String, Identifiable, Hashable {
    case privacy
    case terms
    case eula

    var id: String { rawValue }

    var title: String {
        switch self {
        case .privacy: return "Privacy Policy"
        case .terms: return "Terms of Use"
        case .eula: return "EULA"
        }
    }
}

struct LegalLinks {
    let privacyPolicyURL: URL
    let termsURL: URL
    let eulaURL: URL

    static let `default` = LegalLinks(
        privacyPolicyURL: URL(string: "https://example.com/privacy")!,
        termsURL: URL(string: "https://example.com/terms")!,
        eulaURL: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    )

    func url(for document: LegalDocument) -> URL {
        switch document {
        case .privacy: return privacyPolicyURL
        case .terms: return termsURL
        case .eula: return eulaURL
        }
    }
}
