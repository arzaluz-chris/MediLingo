// POST /functions/v1/evaluate-pronunciation
// Body: { word, phonetic?, transcription, confidence? }
// Returns envelope: { data: { overallScore, feedback, tips }, error, metadata }
//
// The client does on-device STT (Speech framework) and sends the transcription;
// Gemini grades it against the expected word and returns structured JSON.

import { handleCorsPreflight, jsonHeaders } from "../_shared/cors.ts";
import { getUser } from "../_shared/auth.ts";
import { chatWithFallback } from "../_shared/ai-provider.ts";
import { fail, ok } from "../_shared/types.ts";

const SYSTEM_PROMPT = `You are a medical English pronunciation evaluator for MediLingo.
Evaluate the user's pronunciation and return ONLY JSON:
{"overall_score": number 0-100, "word_scores": [{"word": string, "score": number}],
 "errors": [{"phoneme": string, "expected": string, "detected": string}],
 "feedback": string, "tips": string[]}`;

Deno.serve(async (req) => {
  const preflight = handleCorsPreflight(req);
  if (preflight) return preflight;

  const user = await getUser(req);
  if (!user) {
    return new Response(JSON.stringify(fail("UNAUTHORIZED", "Sign in required.")), { status: 401, headers: jsonHeaders });
  }

  let body: { word?: string; phonetic?: string; transcription?: string; confidence?: number };
  try { body = await req.json(); } catch {
    return new Response(JSON.stringify(fail("BAD_REQUEST", "Invalid JSON body.")), { status: 400, headers: jsonHeaders });
  }
  if (!body.word || typeof body.transcription !== "string") {
    return new Response(JSON.stringify(fail("BAD_REQUEST", "`word` and `transcription` are required.")), { status: 400, headers: jsonHeaders });
  }

  const userPrompt = `Expected word/phrase: "${body.word}"${body.phonetic ? ` (IPA: ${body.phonetic})` : ""}
The user said (STT transcription): "${body.transcription}"
STT confidence: ${body.confidence ?? "unknown"}
Score the pronunciation and give brief, encouraging feedback for a Spanish speaker.`;

  try {
    const result = await chatWithFallback(
      [{ role: "system", content: SYSTEM_PROMPT }, { role: "user", content: userPrompt }],
      { responseFormat: "json", temperature: 0.3 },
    );
    const parsed = JSON.parse(result.content);
    return new Response(JSON.stringify(ok(parsed)), { status: 200, headers: jsonHeaders });
  } catch (_e) {
    return new Response(JSON.stringify(fail("NOT_IMPLEMENTED", "Pronunciation scoring not configured yet.")), { status: 501, headers: jsonHeaders });
  }
});
