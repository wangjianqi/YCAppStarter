import Foundation

struct StarterVersion: RawRepresentable, Comparable, Hashable, Codable, CustomStringConvertible {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    static let v1 = StarterVersion(rawValue: "1.0.0")
    static let v2 = StarterVersion(rawValue: "2.0.0")
    static let v21 = StarterVersion(rawValue: "2.1.0")
    static let v22 = StarterVersion(rawValue: "2.2.0")
    static let v23 = StarterVersion(rawValue: "2.3.0")
    static let v24 = StarterVersion(rawValue: "2.4.0")
    static let v25 = StarterVersion(rawValue: "2.5.0")
    static let v26 = StarterVersion(rawValue: "2.6.0")
    static let v27 = StarterVersion(rawValue: "2.7.0")
    static let v28 = StarterVersion(rawValue: "2.8.0")
    static let v29 = StarterVersion(rawValue: "2.9.0")
    static let v30 = StarterVersion(rawValue: "3.0.0")

    var description: String { rawValue }

    static func < (lhs: StarterVersion, rhs: StarterVersion) -> Bool {
        lhs.rawValue.localizedStandardCompare(rhs.rawValue) == .orderedAscending
    }
}
