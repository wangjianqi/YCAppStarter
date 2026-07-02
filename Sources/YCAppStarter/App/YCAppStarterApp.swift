import SwiftUI

@main
struct YCAppStarterApp: App {
    @UIApplicationDelegateAdaptor(PushAppDelegate.self) private var pushAppDelegate
    @StateObject private var container = AppBootstrapper.bootstrap()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(container)
                .task {
                    await container.configureOnLaunch()
                }
        }
    }
}
