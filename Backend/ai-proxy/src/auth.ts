import type { Context, Next } from 'hono'
import { createRemoteJWKSet, jwtVerify } from 'jose'
import type { Bindings, SupabaseClaims } from './types'

type HonoEnv = { Bindings: Bindings; Variables: { supabaseClaims?: SupabaseClaims } }

export async function requireClientToken(c: Context<HonoEnv>, next: Next) {
  const shouldRequire = c.env.AI_REQUIRE_CLIENT_TOKEN === 'true'
  if (!shouldRequire) {
    await next()
    return
  }

  const expected = c.env.AI_PROXY_CLIENT_TOKEN
  const actual = c.req.header('X-Starter-Client-Token')
  if (!expected || actual !== expected) {
    return c.json({ error: 'unauthorized_client_token' }, 401)
  }

  await next()
}

export async function attachSupabaseClaims(c: Context<HonoEnv>, next: Next) {
  const authorization = c.req.header('Authorization')
  const token = authorization?.startsWith('Bearer ') ? authorization.slice('Bearer '.length).trim() : undefined
  if (!token) {
    await next()
    return
  }

  const claims = await verifySupabaseJWT(c.env, token)
  if (claims) c.set('supabaseClaims', claims)
  await next()
}

export async function requireSupabaseAuth(c: Context<HonoEnv>, next: Next) {
  const shouldRequire = c.env.SUPABASE_REQUIRE_AUTH === 'true'
  if (!shouldRequire) {
    await next()
    return
  }

  const authorization = c.req.header('Authorization')
  const token = authorization?.startsWith('Bearer ') ? authorization.slice('Bearer '.length).trim() : undefined
  if (!token) return c.json({ error: 'missing_supabase_bearer_token' }, 401)

  const claims = await verifySupabaseJWT(c.env, token)
  if (!claims?.sub) return c.json({ error: 'invalid_supabase_bearer_token' }, 401)
  c.set('supabaseClaims', claims)
  await next()
}

export function currentUserID(c: Context<HonoEnv>): string | undefined {
  return c.get('supabaseClaims')?.sub
}

async function verifySupabaseJWT(env: Bindings, token: string): Promise<SupabaseClaims | undefined> {
  if (!env.SUPABASE_URL) return undefined
  try {
    const jwksURL = new URL('/auth/v1/.well-known/jwks.json', env.SUPABASE_URL)
    const JWKS = createRemoteJWKSet(jwksURL)
    const { payload } = await jwtVerify(token, JWKS, {
      issuer: `${env.SUPABASE_URL}/auth/v1`,
    })
    return payload as SupabaseClaims
  } catch {
    return undefined
  }
}
