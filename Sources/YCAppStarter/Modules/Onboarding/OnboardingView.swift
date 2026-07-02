import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selection = 0

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            TabView(selection: $selection) {
                ForEach(Array(OnboardingStore.pages.enumerated()), id: \.offset) { index, page in
                    VStack(spacing: DesignTokens.Spacing.lg) {
                        Image(systemName: page.systemImage)
                            .font(.system(size: 64, weight: .semibold))
                        Text(page.title)
                            .font(.largeTitle.bold())
                        Text(page.message)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page)

            PrimaryButton(selection == OnboardingStore.pages.count - 1 ? "Start" : "Next") {
                if selection == OnboardingStore.pages.count - 1 {
                    hasCompletedOnboarding = true
                } else {
                    withAnimation { selection += 1 }
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.bottom, DesignTokens.Spacing.lg)
        }
    }
}
