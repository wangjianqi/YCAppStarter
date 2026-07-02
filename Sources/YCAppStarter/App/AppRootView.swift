import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var container: AppContainer
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if container.flags.isEnabled(.onboarding) && !hasCompletedOnboarding {
                OnboardingView()
            } else {
                HomeView()
            }
        }
        .preferredColorScheme(container.config.appearance.preferredColorScheme)
        .tint(container.config.theme.accentColor)
        .onOpenURL { url in
            Task {
                _ = await container.service(DeepLinkManaging.self)?.handle(url: url, source: .customScheme, container: container)
            }
        }
    }
}
