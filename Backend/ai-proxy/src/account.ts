import type { Context } from 'hono'
import { currentUserID } from './auth'
import type { Bindings, SupabaseClaims } from './types'

type HonoEnv = { Bindings: Bindings; Variables: { supabaseClaims?: SupabaseClaims } }

function supabaseHeaders(env: Bindings) {
  const key = env.SUPABASE_SERVICE_ROLE_KEY
  return {
    apikey: key || '',
    Authorization: `Bearer ${key || ''}`,
    'Content-Type': 'application/json'
  }
}

export async function createPrivacyRequest(c: Context<HonoEnv>, requestType: 'data_export' | 'delete_account') {
  const userID = currentUserID(c)
  if (!userID) return c.json({ error: 'missing_user' }, 401)
  if (!c.env.SUPABASE_URL || !c.env.SUPABASE_SERVICE_ROLE_KEY) {
    return c.json({ error: 'missing_supabase_service_role_config' }, 500)
  }
  const body = await c.req.json().catch(() => ({})) as { reason?: string }
  const response = await fetch(`${c.env.SUPABASE_URL}/rest/v1/privacy_requests`, {
    method: 'POST',
    headers: { ...supabaseHeaders(c.env), Prefer: 'return=representation' },
    body: JSON.stringify({ user_id: userID, request_type: requestType, status: 'pending', reason: body.reason || null })
  })
  const payload = await response.text()
  return new Response(payload, { status: response.status, headers: { 'Content-Type': 'application/json' } })
}

export async function userDataExportPreview(c: Context<HonoEnv>) {
  const claims = c.get('supabaseClaims')
  return c.json({
    user: {
      id: claims?.sub,
      email: claims?.email,
      role: claims?.role
    },
    note: 'This is a starter export preview. Add profile, purchases, AI usage and app-specific tables for production.'
  })
}
