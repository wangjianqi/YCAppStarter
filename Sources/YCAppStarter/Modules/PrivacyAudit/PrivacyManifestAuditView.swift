import SwiftUI

struct PrivacyManifestAuditView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        let service = container.requireService(AppStoreLaunchServicing.self)
        let results = service.privacyManifestAudit(container: container)

        List {
            Section("Runtime Checks") {
                ForEach(results) { result in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Label(result.title, systemImage: result.status.systemImage)
                                .font(.headline)
                            Spacer()
                            Text(result.status.title)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        Text(result.message)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(result.recoverySuggestion)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 4)
                }
            }

            Section("Files") {
                LabeledContent("Manifest", value: "Sources/YCAppStarter/Resources/PrivacyInfo.xcprivacy")
                LabeledContent("Guide", value: "Docs/PrivacyManifest.md")
                LabeledContent("Answers", value: "Metadata/privacy_answers.md")
            }
        }
        .navigationTitle("Privacy Audit")
    }
}
