import Foundation

struct PluginHomeItem: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let systemImage: String
    let route: AppRoute?

    init(id: String, title: String, subtitle: String, systemImage: String, route: AppRoute? = nil) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.route = route
    }
}

struct PluginSettingsItem: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let systemImage: String
    let route: AppRoute?

    init(id: String, title: String, subtitle: String, systemImage: String, route: AppRoute? = nil) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.route = route
    }
}

struct PluginDebugItem: Identifiable, Hashable {
    let id: String
    let title: String
    let value: String
    let systemImage: String

    init(id: String, title: String, value: String, systemImage: String) {
        self.id = id
        self.title = title
        self.value = value
        self.systemImage = systemImage
    }
}
