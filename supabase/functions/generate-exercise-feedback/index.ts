// POST /functions/v1/generate-exercise-feedback
// Body: { prompt, userAnswer, correctAnswer, isCorrect }
// Returns envelope: { data: { explanation }, error, metadata }
//
// Generates a short, encouraging explanation (in Spanish) for a Spanish-speaking
// medical professional after they answer an exercise.

import { handleCorsPreflight, jsonHeaders } from "../_shared/cors.ts";
import { getUser } from "../_shared/auth.ts";
import { chatWithFallback } from "../_shared/ai-provider.ts";
import { fail, ok } from "../_shared/types.ts";

const SYSTEM_PROMPT = `You are a friendly medical English tutor for Spanish-speaking
healthcare professionals in MediLingo. Given an exercise and the user's answer,
write a concise explanation IN SPANISH (2-3 sentences) of why the correct answer
is right. If the user was wrong, gently point out the mistake. Keep medical terms
in English. Return plain text, no markdown.`;

Deno.serve(async (req) => {
  const preflight = handleCorsPreflight(req);
  if (preflight) return preflight;

  const user = await getUser(req);
  if (!user) {
    return new Response(JSON.stringify(fail("UNAUTHORIZED", "Sign in required.")), { status: 401, headers: jsonHeaders });
  }

  let body: { prompt?: string; userAnswer?: string; correctAnswer?: string; isCorrect?: boolean };
  try { body = await req.json(); } catch {
    return new Response(JSON.stringify(fail("BAD_REQUEST", "Invalid JSON body.")), { status: 400, headers: jsonHeaders });
  }
  if (!body.prompt) {
    return new Response(JSON.stringify(fail("BAD_REQUEST", "`prompt` is required.")), { status: 400, headers: jsonHeaders });
  }

  const userPrompt = `Exercise: ${body.prompt}
Correct answer: ${body.correctAnswer ?? "(unspecified)"}
User's answer: ${body.userAnswer ?? "(none)"}
The user was ${body.isCorrect ? "correct" : "incorrect"}.`;

  try {
    const result = await chatWithFallback(
      [{ role: "system", content: SYSTEM_PROMPT }, { role: "user", content: userPrompt }],
      { temperature: 0.5, maxTokens: 300 },
    );
    return new Response(JSON.stringify(ok({ explanation: result.content })), { status: 200, headers: jsonHeaders });
  } catch (_e) {
    return new Response(JSON.stringify(fail("NOT_IMPLEMENTED", "Feedback generation not configured yet.")), { status: 501, headers: jsonHeaders });
  }
});
