import type { Context, Next } from 'hono'
import { currentUserID } from './auth'
import type { Bindings } from './types'

type QuotaRecord = { day: string; used: number }
const memoryQuota = new Map<string, QuotaRecord>()

function today() {
  return new Date().toISOString().slice(0, 10)
}

function quotaKey(c: Context<{ Bindings: Bindings }>) {
  return currentUserID(c as never) || c.req.header('X-Starter-Client-Token') || c.req.header('CF-Connecting-IP') || 'anonymous'
}

export function quotaSnapshot(c: Context<{ Bindings: Bindings }>) {
  const limit = Number.parseInt(c.env.AI_DAILY_QUOTA || '25', 10)
  const key = quotaKey(c)
  const day = today()
  const record = memoryQuota.get(key)
  const used = record?.day === day ? record.used : 0
  return { limit, used, remaining: Math.max(0, limit - used), window: day, keyType: currentUserID(c as never) ? 'supabase-user' : 'client-or-ip' }
}

export async function enforceQuota(c: Context<{ Bindings: Bindings }>, next: Next) {
  const snapshot = quotaSnapshot(c)
  if (snapshot.remaining <= 0) {
    return c.json({ error: 'quota_exceeded', ...snapshot }, 429)
  }

  await next()

  if (c.res.status >= 200 && c.res.status < 300) {
    const key = quotaKey(c)
    const current = quotaSnapshot(c)
    memoryQuota.set(key, { day: current.window, used: current.used + 1 })
  }
}
