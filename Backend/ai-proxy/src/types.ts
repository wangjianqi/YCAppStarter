export type Bindings = {
  OPENAI_API_KEY: string
  AI_PROXY_CLIENT_TOKEN?: string
  AI_REQUIRE_CLIENT_TOKEN?: string
  AI_PROVIDER?: string
  AI_DEFAULT_MODEL?: string
  AI_DAILY_QUOTA?: string
  SUPABASE_URL?: string
  SUPABASE_REQUIRE_AUTH?: string
  SUPABASE_SERVICE_ROLE_KEY?: string
}

export type SupabaseClaims = {
  sub?: string
  email?: string
  role?: string
  exp?: number
  aud?: string | string[]
  iss?: string
  [key: string]: unknown
}

export type AITextRequest = {
  prompt: string
  systemPrompt?: string
  model?: string
}

export type AIVisionRequest = {
  prompt: string
  imageBase64: string
  mimeType?: string
  model?: string
}

export type AITextResponse = {
  text: string
  model?: string
  provider: string
  usage?: {
    inputTokens?: number
    outputTokens?: number
    totalTokens?: number
  }
}
