# Supabase Auth Plugin

YCAppStarter includes `SupabaseAuthPlugin` as a removable plugin.

## What it provides

- `AuthManaging` protocol for app-facing auth operations.
- `SupabaseAuthManager` implementation.
- Email/password sign up and sign in.
- Native Sign in with Apple using `AuthenticationServices`.
- Anonymous sign-in.
- `profiles` table sync.
- Membership sync hook from `PurchaseManaging`.
- AI usage counter sync hook.
- Auth Debug and User Profile debug screens.

## Configure

```bash
python3 Scripts/configure_supabase.py \
  --url https://your-project-ref.supabase.co \
  --anon-key sb_publishable_xxx \
  --redirect-scheme ycappstarter
```

Run the SQL template:

```text
Supabase/migrations/0001_profiles_membership_ai_usage.sql
```

## Sign in with Apple checklist

1. Enable **Sign in with Apple** capability for the App ID in Apple Developer.
2. Enable the Apple provider in Supabase Auth.
3. Keep `Sources/YCAppStarter/YCAppStarter.entitlements` attached to the app target.
4. Test on a real device or simulator with a signed Apple ID.

## Backend auth middleware

The Cloudflare Worker now accepts Supabase bearer tokens and can require them for AI routes:

```bash
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_REQUIRE_AUTH=true
```

When `SUPABASE_REQUIRE_AUTH=true`, `/v1/ai/*` requires:

```http
Authorization: Bearer <supabase-access-token>
```

## Remote Config keys

```json
{
  "auth_enabled": true,
  "auth_require_login_for_ai": false,
  "auth_allow_email_password": true,
  "auth_allow_apple": true,
  "profile_sync_enabled": true,
  "membership_sync_enabled": true,
  "ai_usage_sync_enabled": true
}
```
