# Backend Kit

V2.6 adds a backend client and a Cloudflare Workers/Hono backend template.

## Directory

```text
Backend/ai-proxy
├── package.json
├── wrangler.jsonc
├── .dev.vars.example
└── src
    ├── index.ts
    ├── openai.ts
    ├── quota.ts
    ├── auth.ts
    └── types.ts
```

## Local development

```bash
cd Backend/ai-proxy
npm install
cp .dev.vars.example .dev.vars
npm run dev
```

## Deploy

```bash
npx wrangler secret put OPENAI_API_KEY
npx wrangler secret put AI_PROXY_CLIENT_TOKEN
npm run deploy
```

## iOS integration

`BackendKitPlugin` registers `BackendClient`. `AIProxyPlugin` registers `AIClient`. Business features should depend on these protocols, not on a concrete backend implementation.
