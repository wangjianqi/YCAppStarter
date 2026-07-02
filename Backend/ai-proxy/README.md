# YCAppStarter AI Proxy Backend

Cloudflare Workers + Hono template for YCAppStarter V2.8.

## Why this exists

Do not put OpenAI, Gemini, Claude or DeepSeek API keys in the iOS client. The app calls this proxy, and the proxy calls the model provider.

## Local setup

```bash
cd Backend/ai-proxy
npm install
cp .dev.vars.example .dev.vars
# Fill OPENAI_API_KEY
npm run dev
```

## Deploy

```bash
cd Backend/ai-proxy
npx wrangler secret put OPENAI_API_KEY
npx wrangler secret put AI_PROXY_CLIENT_TOKEN
npm run deploy
```

Then configure the iOS app:

```bash
python3 Scripts/configure_ai_proxy.py   --base-url https://ycappstarter-ai-proxy.your-subdomain.workers.dev   --client-token your-client-token
```

## Endpoints

| Method | Path | Purpose |
|---|---|---|
| GET | `/health` | backend health |
| GET | `/v1/ai/quota` | quota snapshot |
| POST | `/v1/ai/complete` | text completion |
| POST | `/v1/ai/stream` | SSE streaming |
| POST | `/v1/ai/vision` | image/vision analysis |

## Production notes

The sample quota uses isolate memory, which is enough for local testing but not durable. For production, replace it with Cloudflare KV, D1 or Supabase Postgres.


## Supabase Auth middleware

Set `SUPABASE_URL` and `SUPABASE_REQUIRE_AUTH=true` to require Supabase bearer tokens for `/v1/ai/*` routes.
