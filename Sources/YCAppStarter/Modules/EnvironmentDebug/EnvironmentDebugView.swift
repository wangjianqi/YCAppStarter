import SwiftUI

struct EnvironmentDebugView: View {
    var body: some View {
        List {
            Section("Current") {
                LabeledContent("Environment", value: BuildEnvironmentReader.current.displayName)
                LabeledContent("Verbose Logging", value: BuildEnvironmentReader.current.allowsVerboseLogging ? "Enabled" : "Disabled")
                LabeledContent("StoreKit Test", value: BuildEnvironmentReader.current.shouldUseStoreKitTest ? "Enabled" : "Disabled")
            }

            Section("Available") {
                ForEach(BuildEnvironment.allCases) { environment in
                    LabeledContent(environment.displayName, value: environment.rawValue)
                }
            }

            Section("Files") {
                Text("Config/Environments/Development.xcconfig")
                Text("Config/Environments/Staging.xcconfig")
                Text("Config/Environments/Production.xcconfig")
                Text("Config/Environments/Secrets.xcconfig.sample")
            }
        }
        .navigationTitle("Environment")
    }
}
