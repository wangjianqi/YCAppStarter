import SwiftUI

struct MetadataTemplatesView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        let service = container.requireService(AppStoreLaunchServicing.self)
        let templates = service.metadataTemplates()

        List {
            Section("Templates") {
                ForEach(templates) { template in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Label(template.title, systemImage: "doc.text")
                                .font(.headline)
                            Spacer()
                            Text(template.filename)
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)
                        }
                        Text(template.summary)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(template.path)
                            .font(.caption2.monospaced())
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 4)
                }
            }

            Section("Workflow") {
                Text("Use Metadata/ as the single source of App Store Connect copy. Keep review notes, privacy answers and screenshot copy updated for every build.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Metadata")
    }
}
