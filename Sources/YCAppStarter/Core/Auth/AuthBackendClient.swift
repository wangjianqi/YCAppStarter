import Foundation

/// Small helper for attaching Supabase access tokens to custom backend requests.
/// Keep this helper separate from `BackendClient` so the default backend client remains usable without auth.
@MainActor
struct SupabaseBearerTokenProvider {
    let auth: AuthManaging

    func authorizationHeader() async -> String? {
        guard let token = await auth.accessToken(), !token.isEmpty else { return nil }
        return "Bearer \(token)"
    }
}
