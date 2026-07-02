import SwiftUI

struct AppStoreLaunchView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        let service = container.requireService(AppStoreLaunchServicing.self)
        let report = service.makeReadinessReport(container: container)

        List {
            Section {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("\(report.score)%")
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                        VStack(alignment: .leading) {
                            Text("Launch readiness")
                                .font(.headline)
                            Text("\(report.passedCount) passed · \(report.warningCount) warnings · \(report.failedCount) failed · \(report.manualCount) manual")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    ProgressView(value: Double(report.score), total: 100)
                }
                .padding(.vertical, 8)
            }

            Section("Surfaces") {
                NavigationLink(value: AppRoute.privacyAudit) {
                    Label("Privacy Manifest Audit", systemImage: "hand.raised")
                }
                NavigationLink(value: AppRoute.metadataTemplates) {
                    Label("Metadata Templates", systemImage: "doc.richtext")
                }
                NavigationLink(value: AppRoute.localizationAudit) {
                    Label("Localization Audit", systemImage: "globe")
                }
                NavigationLink(value: AppRoute.adMobCompliance) {
                    Label("AdMob Compliance", systemImage: "megaphone")
                }
            }

            ForEach(AppStoreChecklistCategory.allCases) { category in
                let items = report.items(in: category)
                if items.isEmpty == false {
                    Section(category.title) {
                        ForEach(items) { item in
                            ChecklistItemRow(item: item)
                        }
                    }
                }
            }
        }
        .navigationTitle("App Store Launch")
    }
}

struct ChecklistItemRow: View {
    let item: AppStoreChecklistItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Label(item.title, systemImage: item.status.systemImage)
                    .font(.headline)
                Spacer()
                Text(item.status.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            Text(item.detail)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(item.recoverySuggestion)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}
