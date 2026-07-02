# YCAppStarter V2.6 Release Notes

## Added

- `BackendKitPlugin`
- `AIProxyPlugin`
- `AIClient` protocol
- `AIProxyClient`
- `BackendClient` protocol
- `HTTPBackendClient`
- `AIDebugView`
- `BackendDebugView`
- Cloudflare Workers/Hono AI proxy backend template
- `configure_ai_proxy.py`
- `validate_ai_backend.py`
- Remote Config keys for AI controls

## Runtime policy

AI requests are allowed only when:

1. `ai_enabled=true`
2. Review Safe Mode is false
3. Global Kill Switch is false
4. AI proxy base URL is configured
5. The backend accepts the request and quota remains

Streaming and vision have independent Remote Config switches.
