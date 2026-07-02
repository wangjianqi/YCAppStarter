import Foundation

@MainActor
protocol AdConsentManaging {
    var canRequestAds: Bool { get }
    var privacyOptionsRequired: Bool { get }
    var statusText: String { get }
    var lastErrorMessage: String? { get }

    func requestConsentIfNeeded() async
    func presentPrivacyOptions() async
    func resetForTesting()
}

@MainActor
final class NoopAdConsentManager: ObservableObject, AdConsentManaging {
    @Published private(set) var canRequestAds: Bool = false
    @Published private(set) var privacyOptionsRequired: Bool = false
    @Published private(set) var statusText: String = "No-op"
    @Published private(set) var lastErrorMessage: String?

    func requestConsentIfNeeded() async {
        statusText = "Unavailable"
        lastErrorMessage = "UMPConsentPlugin is disabled or UserMessagingPlatform is unavailable."
    }

    func presentPrivacyOptions() async {
        lastErrorMessage = "Privacy options form is unavailable in no-op mode."
    }

    func resetForTesting() {
        canRequestAds = false
        statusText = "Reset"
    }
}
