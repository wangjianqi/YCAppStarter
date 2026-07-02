import Foundation

protocol AnalyticsTracking: Sendable {
    func configure()
    func track(_ event: AnalyticsEvent)
    func setUserID(_ userID: String?)
}

struct AnalyticsEvent: Sendable, Hashable {
    let name: String
    let parameters: [String: String]

    init(_ name: String, parameters: [String: String] = [:]) {
        self.name = name
        self.parameters = parameters
    }
}
