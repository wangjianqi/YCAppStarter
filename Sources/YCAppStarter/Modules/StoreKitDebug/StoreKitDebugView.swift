import SwiftUI

struct StoreKitDebugView: View {
    var body: some View {
        List {
            Section("StoreKit Test") {
                LabeledContent("Config File", value: "StoreKit/YCAppStarter.storekit")
                LabeledContent("Sample Product", value: "premium_lifetime")
                LabeledContent("Use In", value: "Development scheme")
            }

            Section("Local Validation") {
                Text("python3 Scripts/validate_storekit.py")
                Text("xcodebuild test -scheme YCAppStarter -destination 'platform=iOS Simulator,name=iPhone 16'")
            }

            Section("Release Rule") {
                Text("StoreKit test products are for local validation only. Production purchases must be verified with App Store Connect products and RevenueCat offerings.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("StoreKit Test")
    }
}
