import SwiftUI

struct ProductionReadinessView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        let report = container.service(ProductionReadinessServicing.self)?.makeReport(container: container)
        List {
            Section("Summary") {
                LabeledContent("Score", value: "\(report?.score ?? 0)%")
                LabeledContent("Blocking", value: "\(report?.blockingCount ?? 0)")
                LabeledContent("Warnings", value: "\(report?.warningCount ?? 0)")
                LabeledContent("Environment", value: BuildEnvironmentReader.current.displayName)
            }

            Section("Checks") {
                ForEach(report?.checks ?? []) { check in
                    VStack(alignment: .leading, spacing: 6) {
                        Label(check.title, systemImage: check.severity.systemImage)
                            .font(.headline)
                        Text(check.detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if check.severity != .pass {
                            Text(check.recovery)
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            Section("Recommended Commands") {
                Text("python3 Scripts/ycstarter.py validate")
                Text("python3 Scripts/appstore_preflight.py")
                Text("python3 Scripts/validate_storekit.py")
                Text("python3 Scripts/validate_ci.py")
            }
        }
        .navigationTitle("Production")
    }
}
