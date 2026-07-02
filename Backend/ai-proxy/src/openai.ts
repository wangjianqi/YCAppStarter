import type { AIVisionRequest, AITextRequest, AITextResponse, Bindings } from './types'

const OPENAI_RESPONSES_URL = 'https://api.openai.com/v1/responses'

function model(env: Bindings, requested?: string) {
  return requested || env.AI_DEFAULT_MODEL || 'gpt-5.5-mini'
}

function authHeaders(env: Bindings) {
  return {
    Authorization: `Bearer ${env.OPENAI_API_KEY}`,
    'Content-Type': 'application/json'
  }
}

function extractText(payload: any): string {
  if (typeof payload?.output_text === 'string') return payload.output_text
  const parts: string[] = []
  for (const item of payload?.output || []) {
    for (const content of item?.content || []) {
      if (typeof content?.text === 'string') parts.push(content.text)
    }
  }
  return parts.join('')
}

function usage(payload: any) {
  const inputTokens = payload?.usage?.input_tokens
  const outputTokens = payload?.usage?.output_tokens
  const totalTokens = typeof inputTokens === 'number' && typeof outputTokens === 'number' ? inputTokens + outputTokens : undefined
  return { inputTokens, outputTokens, totalTokens }
}

export async function completeWithOpenAI(env: Bindings, request: AITextRequest): Promise<AITextResponse> {
  const input = request.systemPrompt
    ? [
        { role: 'system', content: request.systemPrompt },
        { role: 'user', content: request.prompt }
      ]
    : request.prompt

  const response = await fetch(OPENAI_RESPONSES_URL, {
    method: 'POST',
    headers: authHeaders(env),
    body: JSON.stringify({ model: model(env, request.model), input })
  })

  const payload = await response.json() as any
  if (!response.ok) throw new Error(payload?.error?.message || `OpenAI HTTP ${response.status}`)
  return { text: extractText(payload), model: payload?.model || model(env, request.model), provider: 'openai', usage: usage(payload) }
}

export async function visionWithOpenAI(env: Bindings, request: AIVisionRequest): Promise<AITextResponse> {
  const mimeType = request.mimeType || 'image/jpeg'
  const response = await fetch(OPENAI_RESPONSES_URL, {
    method: 'POST',
    headers: authHeaders(env),
    body: JSON.stringify({
      model: model(env, request.model),
      input: [
        {
          role: 'user',
          content: [
            { type: 'input_text', text: request.prompt },
            { type: 'input_image', image_url: `data:${mimeType};base64,${request.imageBase64}` }
          ]
        }
      ]
    })
  })

  const payload = await response.json() as any
  if (!response.ok) throw new Error(payload?.error?.message || `OpenAI HTTP ${response.status}`)
  return { text: extractText(payload), model: payload?.model || model(env, request.model), provider: 'openai', usage: usage(payload) }
}

export async function streamWithOpenAI(env: Bindings, request: AITextRequest): Promise<Response> {
  const input = request.systemPrompt
    ? [
        { role: 'system', content: request.systemPrompt },
        { role: 'user', content: request.prompt }
      ]
    : request.prompt

  const upstream = await fetch(OPENAI_RESPONSES_URL, {
    method: 'POST',
    headers: authHeaders(env),
    body: JSON.stringify({ model: model(env, request.model), input, stream: true })
  })

  if (!upstream.ok || !upstream.body) {
    const body = await upstream.text()
    return new Response(`data: ${JSON.stringify({ error: body })}

`, { status: upstream.status, headers: { 'Content-Type': 'text/event-stream' } })
  }

  const stream = new TransformStream()
  const writer = stream.writable.getWriter()
  const reader = upstream.body.getReader()
  const decoder = new TextDecoder()
  const encoder = new TextEncoder()

  queueMicrotask(async () => {
    try {
      while (true) {
        const { done, value } = await reader.read()
        if (done) break
        const chunk = decoder.decode(value, { stream: true })
        for (const line of chunk.split('
')) {
          if (!line.startsWith('data:')) continue
          const raw = line.slice(5).trim()
          if (raw === '[DONE]') continue
          try {
            const event = JSON.parse(raw)
            if (event.type === 'response.output_text.delta' && event.delta) {
              await writer.write(encoder.encode(`data: ${JSON.stringify({ delta: event.delta })}

`))
            }
          } catch {
            // Ignore upstream comments or partial lines.
          }
        }
      }
      await writer.write(encoder.encode('data: [DONE]

'))
    } catch (error) {
      await writer.write(encoder.encode(`data: ${JSON.stringify({ error: String(error) })}

`))
    } finally {
      await writer.close()
    }
  })

  return new Response(stream.readable, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      Connection: 'keep-alive'
    }
  })
}
