import Foundation

struct PluginDescriptor: Identifiable, Hashable {
    let id: String
    let displayName: String
    let version: StarterVersion
    let feature: AppFeature
    let category: PluginCategory
    let dependencies: [AppFeature]
    let optionalDependencies: [AppFeature]
    let requiredSecrets: [SecretKey]
    let requiredServices: [ServiceRequirement]
    let minimumIOSVersion: String
    let isRemovable: Bool
    let summary: String

    init(
        id: String,
        displayName: String,
        version: StarterVersion = .v21,
        feature: AppFeature,
        category: PluginCategory,
        dependencies: [AppFeature] = [],
        optionalDependencies: [AppFeature] = [],
        requiredSecrets: [SecretKey] = [],
        requiredServices: [ServiceRequirement] = [],
        minimumIOSVersion: String = "17.6",
        isRemovable: Bool = true,
        summary: String
    ) {
        self.id = id
        self.displayName = displayName
        self.version = version
        self.feature = feature
        self.category = category
        self.dependencies = dependencies
        self.optionalDependencies = optionalDependencies
        self.requiredSecrets = requiredSecrets
        self.requiredServices = requiredServices
        self.minimumIOSVersion = minimumIOSVersion
        self.isRemovable = isRemovable
        self.summary = summary
    }
}

enum PluginCategory: String, CaseIterable, Identifiable {
    case core
    case monetization
    case growth
    case system
    case developer
    case quality
    case release
    case sample

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .core: return "Core"
        case .monetization: return "Monetization"
        case .growth: return "Growth"
        case .system: return "System"
        case .developer: return "Developer"
        case .quality: return "Quality"
        case .release: return "Release"
        case .sample: return "Sample"
        }
    }
}

enum SecretKey: String, CaseIterable, Identifiable, Hashable {
    case revenueCatAPIKey
    case firebaseGoogleServiceInfo
    case openAIProxyBaseURL
    case aiProxyClientToken
    case backendBaseURL
    case supabaseURL
    case supabaseAnonKey
    case admobAppID
    case apnsEnvironment
    case appGroupIdentifier

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .revenueCatAPIKey: return "RevenueCat API Key"
        case .firebaseGoogleServiceInfo: return "GoogleService-Info.plist"
        case .openAIProxyBaseURL: return "AI Proxy Base URL"
        case .aiProxyClientToken: return "AI Proxy Client Token"
        case .backendBaseURL: return "Backend Base URL"
        case .supabaseURL: return "Supabase URL"
        case .supabaseAnonKey: return "Supabase Anon Key"
        case .admobAppID: return "AdMob App ID"
        case .apnsEnvironment: return "APNs Environment"
        case .appGroupIdentifier: return "App Group Identifier"
        }
    }
}

struct ServiceRequirement: Identifiable, Hashable {
    let id: String
    let displayName: String

    init(_ id: String, displayName: String? = nil) {
        self.id = id
        self.displayName = displayName ?? id
    }
}
