import Foundation

struct OnboardingPlugin: AppPlugin {
    let descriptor = PluginDescriptor(
        id: "yc.onboarding",
        displayName: "Onboarding",
        version: .v1,
        feature: .onboarding,
        category: .growth,
        summary: "Controls first-run onboarding flow through AppStorage and FeatureFlags."
    )

    func makeDebugItems(container: AppContainer) -> [PluginDebugItem] {
        [
            PluginDebugItem(
                id: "onboarding-enabled",
                title: "Onboarding",
                value: container.flags.isEnabled(.onboarding) ? "Enabled" : "Disabled",
                systemImage: "rectangle.stack"
            )
        ]
    }
}
