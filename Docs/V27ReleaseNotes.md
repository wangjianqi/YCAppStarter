# YCAppStarter V2.7 Release Notes

## Focus

V2.7 turns the starter into a login-aware launch kit by adding Supabase Auth, user profiles, membership sync, AI usage sync and backend JWT middleware.

## Added

- `SupabaseAuthPlugin`
- `AuthManaging`
- `SupabaseAuthManager`
- Email/password auth
- Native Sign in with Apple
- Anonymous auth
- `AuthDebugView`
- `UserProfileView`
- Supabase RLS SQL baseline
- `configure_supabase.py`
- `validate_supabase_schema.py`
- Worker Supabase JWT middleware
- Supabase bearer-token support for AI Proxy calls

## Defaults

Auth is enabled in bundled Remote Config defaults, but Supabase URL and key are empty. The app remains runnable; auth operations show configuration warnings until real values are provided.

## Validation

Run:

```bash
python3 Scripts/validate_supabase_schema.py
python3 Scripts/validate_remote_config.py
python3 Scripts/ycstarter_doctor.py
```
