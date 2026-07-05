// Multi-provider AI abstraction. Switch providers by configuration, not code.
// Order: Gemini primary, OpenAI fallback, Claude specialty (CLAUDE.md § AI).
//
// Phase 0: provider implementations are stubs that require an API key in the
// environment. Wire real SDK calls in Phase 1. Until keys are set, chat()
// throws and chatWithFallback() surfaces a clean "all providers failed" error.

import type { AIProvider, AIResponse, ChatOptions, Message } from "./types.ts";

class GeminiProvider implements AIProvider {
  async chat(messages: Message[], options?: ChatOptions): Promise<AIResponse> {
    const key = Deno.env.get("GEMINI_API_KEY");
    if (!key) throw new Error("GEMINI_API_KEY not configured");

    const model = options?.model ?? "gemini-2.0-flash";
    // Map our message list to Gemini's shape: system → systemInstruction,
    // user/assistant → contents (assistant becomes role "model").
    const systemParts = messages.filter((m) => m.role === "system").map((m) => ({ text: m.content }));
    const contents = messages
      .filter((m) => m.role !== "system")
      .map((m) => ({ role: m.role === "assistant" ? "model" : "user", parts: [{ text: m.content }] }));

    const body: Record<string, unknown> = {
      contents,
      generationConfig: {
        temperature: options?.temperature ?? 0.7,
        maxOutputTokens: options?.maxTokens ?? 1024,
        ...(options?.responseFormat === "json" ? { responseMimeType: "application/json" } : {}),
      },
    };
    if (systemParts.length > 0) body.systemInstruction = { parts: systemParts };

    const res = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${key}`,
      { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(body) },
    );
    if (!res.ok) throw new Error(`Gemini ${res.status}: ${await res.text()}`);

    const data = await res.json();
    const content = data?.candidates?.[0]?.content?.parts?.map((p: { text?: string }) => p.text ?? "").join("") ?? "";
    const tokensUsed = data?.usageMetadata?.totalTokenCount ?? 0;
    return { content, tokensUsed, provider: "gemini", model };
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
