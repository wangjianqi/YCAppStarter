import Foundation

struct AppSecrets: Equatable {
    var revenueCatAPIKey: String = "appl_xxx"
    var revenueCatEntitlementID: String = "premium"
    var revenueCatOfferingID: String? = nil
    var openAIProxyBaseURL: String = ""
    var supabaseURL: String = ""
    var supabaseAnonKey: String = ""
    var admobAppID: String = ""
    var hasFirebaseGoogleServiceInfo: Bool = true
}
