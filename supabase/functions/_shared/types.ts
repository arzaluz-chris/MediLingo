// Shared types + API envelope helpers for all Edge Functions.
// Envelope shape (CLAUDE-backend.md § API Contracts): { data, error, metadata }.

export interface ApiMetadata {
  timestamp: string;
  requestId: string;
}

export interface ApiError {
  code: string;
  message: string;
  details?: Record<string, unknown>;
}

export interface ApiResponse<T> {
  data: T | null;
  error: ApiError | null;
  metadata: ApiMetadata;
}

function metadata(): ApiMetadata {
  return { timestamp: new Date().toISOString(), requestId: crypto.randomUUID() };
}

export function ok<T>(data: T): ApiResponse<T> {
  return { data, error: null, metadata: metadata() };
}

export function fail(code: string, message: string, details?: Record<string, unknown>): ApiResponse<never> {
  return { data: null, error: { code, message, details }, metadata: metadata() };
}

// AI provider contracts -------------------------------------------------------
export interface Message {
  role: "system" | "user" | "assistant";
  content: string;
}

export interface ChatOptions {
  model?: string;
  temperature?: number;
  maxTokens?: number;
  responseFormat?: "text" | "json";
}

export interface AIResponse {
  content: string;
  tokensUsed: number;
  provider: string;
  model: string;
}

export interface AIProvider {
  chat(messages: Message[], options?: ChatOptions): Promise<AIResponse>;
}
