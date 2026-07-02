import SwiftUI

struct LocalizationAuditView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        let service = container.requireService(AppStoreLaunchServicing.self)
        let results = service.localizationAudit(container: container)

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

            Section("CLI") {
                Text("python3 Scripts/check_localization.py")
                    .font(.caption.monospaced())
                Text("The script statically scans Localizable.xcstrings and reports missing or empty localizations.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Localization Audit")
    }
}
