# AI Proxy Plugin

YCAppStarter V2.6 adds an AI proxy plugin instead of calling model providers directly from iOS.

## App-side services

- `AIClient`
- `AIProxyClient`
- `AIProxyPlugin`
- `AIDebugView`

The app reads runtime controls from `RemoteConfigServicing`:

```json
{
  "ai_enabled": false,
  "ai_streaming_enabled": false,
  "ai_vision_enabled": false,
  "ai_default_model": "gpt-5.5-mini",
  "ai_daily_quota": 25
}
```

Review Safe Mode and Global Kill Switch suppress AI entry points.

## Configure

```bash
python3 Scripts/configure_ai_proxy.py   --base-url https://ycappstarter-ai-proxy.your-subdomain.workers.dev   --client-token your-client-token
```

## Endpoints expected by iOS

| Method | Path | Response |
|---|---|---|
| GET | `/health` | `AIProxyHealth` |
| GET | `/v1/ai/quota` | `AIQuotaSnapshot` |
| POST | `/v1/ai/complete` | `AITextResponse` |
| POST | `/v1/ai/stream` | Server-sent events |
| POST | `/v1/ai/vision` | `AITextResponse` |

## Production notes

- Do not put provider API keys in the iOS app.
- Require `X-Starter-Client-Token` in production.
- Replace the sample in-memory quota with Cloudflare KV, D1, Supabase Postgres or another durable store.
- Add request logging only with redaction.
