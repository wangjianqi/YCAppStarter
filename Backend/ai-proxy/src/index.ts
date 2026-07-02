import { Hono } from 'hono'
import { cors } from 'hono/cors'
import { attachSupabaseClaims, requireClientToken, requireSupabaseAuth } from './auth'
import { enforceQuota, quotaSnapshot } from './quota'
import { completeWithOpenAI, streamWithOpenAI, visionWithOpenAI } from './openai'
import type { AIVisionRequest, AITextRequest, Bindings, SupabaseClaims } from './types'
import { createPrivacyRequest, userDataExportPreview } from './account'

const app = new Hono<{ Bindings: Bindings; Variables: { supabaseClaims?: SupabaseClaims } }>()

app.use('*', cors())
app.use('/v1/*', requireClientToken)
app.use('/v1/*', attachSupabaseClaims)
app.use('/v1/ai/*', requireSupabaseAuth)

app.get('/health', (c) => c.json({
  status: c.env.OPENAI_API_KEY ? 'ok' : 'missing_openai_key',
  version: '2.8.0',
  provider: c.env.AI_PROVIDER || 'openai',
  defaultModel: c.env.AI_DEFAULT_MODEL || 'gpt-5.5-mini',
  supabaseAuth: c.env.SUPABASE_REQUIRE_AUTH === 'true' ? 'required' : 'optional',
  message: 'YCAppStarter AI proxy is reachable.'
}))

app.get('/v1/auth/me', requireSupabaseAuth, (c) => c.json({ user: c.get('supabaseClaims') || null }))
app.get('/v1/account/export-preview', requireSupabaseAuth, userDataExportPreview)
app.post('/v1/account/request-data-export', requireSupabaseAuth, (c) => createPrivacyRequest(c, 'data_export'))
app.post('/v1/account/request-delete', requireSupabaseAuth, (c) => createPrivacyRequest(c, 'delete_account'))
app.get('/v1/ai/quota', (c) => c.json(quotaSnapshot(c)))

app.post('/v1/ai/complete', enforceQuota, async (c) => {
  const body = await c.req.json<AITextRequest>()
  if (!body.prompt?.trim()) return c.json({ error: 'prompt_required' }, 400)
  try {
    return c.json(await completeWithOpenAI(c.env, body))
  } catch (error) {
    return c.json({ error: String(error) }, 502)
  }
})

app.post('/v1/ai/vision', enforceQuota, async (c) => {
  const body = await c.req.json<AIVisionRequest>()
  if (!body.prompt?.trim()) return c.json({ error: 'prompt_required' }, 400)
  if (!body.imageBase64?.trim()) return c.json({ error: 'image_required' }, 400)
  try {
    return c.json(await visionWithOpenAI(c.env, body))
  } catch (error) {
    return c.json({ error: String(error) }, 502)
  }
})

app.post('/v1/ai/stream', enforceQuota, async (c) => {
  const body = await c.req.json<AITextRequest>()
  if (!body.prompt?.trim()) return c.json({ error: 'prompt_required' }, 400)
  return streamWithOpenAI(c.env, body)
})

export default app
