import Foundation

struct OnboardingPage: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let message: String
    let systemImage: String
}

enum OnboardingStore {
    static let pages = [
        OnboardingPage(title: "Plugin First", message: "V2 keeps features removable and registered through PluginCatalog.", systemImage: "puzzlepiece.extension"),
        OnboardingPage(title: "Service Registry", message: "Plugins register services without hard-coding them into the app shell.", systemImage: "server.rack"),
        OnboardingPage(title: "Version Ready", message: "Add V2.4/V3 features behind flags and plugins.", systemImage: "arrow.triangle.2.circlepath")
    ]
}
