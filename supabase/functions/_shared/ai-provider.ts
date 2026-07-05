// Multi-provider AI abstraction. Switch providers by configuration, not code.
// Order: Gemini primary, OpenAI fallback, Claude specialty (CLAUDE.md § AI).
//
// Phase 0: provider implementations are stubs that require an API key in the
// environment. Wire real SDK calls in Phase 1. Until keys are set, chat()
// throws and chatWithFallback() surfaces a clean "all providers failed" error.

import type { AIProvider, AIResponse, ChatOptions, Message } from "./types.ts";

class GeminiProvider implements AIProvider {
  async chat(_messages: Message[], options?: ChatOptions): Promise<AIResponse> {
    const key = Deno.env.get("GEMINI_API_KEY");
    if (!key) throw new Error("GEMINI_API_KEY not configured");
    // TODO(phase-1): call Gemini generateContent.
    throw new Error("GeminiProvider.chat not implemented");
  }
}

class OpenAIProvider implements AIProvider {
  async chat(_messages: Message[], options?: ChatOptions): Promise<AIResponse> {
    const key = Deno.env.get("OPENAI_API_KEY");
    if (!key) throw new Error("OPENAI_API_KEY not configured");
    // TODO(phase-1): call OpenAI chat completions.
    throw new Error("OpenAIProvider.chat not implemented");
  }
}

class ClaudeProvider implements AIProvider {
  async chat(_messages: Message[], options?: ChatOptions): Promise<AIResponse> {
    const key = Deno.env.get("ANTHROPIC_API_KEY");
    if (!key) throw new Error("ANTHROPIC_API_KEY not configured");
    // TODO(phase-1): call Anthropic messages API.
    throw new Error("ClaudeProvider.chat not implemented");
  }
}

export function getAIProvider(provider = "gemini"): AIProvider {
  switch (provider) {
    case "gemini": return new GeminiProvider();
    case "openai": return new OpenAIProvider();
    case "claude": return new ClaudeProvider();
    default: return new GeminiProvider();
  }
}

// Try each provider in order; return the first success.
export async function chatWithFallback(
  messages: Message[],
  options?: ChatOptions,
): Promise<AIResponse> {
  const providers = ["gemini", "openai", "claude"];
  for (const provider of providers) {
    try {
      return await getAIProvider(provider).chat(messages, options);
    } catch (error) {
      console.error(`Provider ${provider} failed:`, error);
      continue;
    }
  }
  throw new Error("All AI providers failed");
}
