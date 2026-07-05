// POST /functions/v1/ai-conversation
// Body: { conversationId?, message, conversationType?, scenario? }
// Returns envelope: { data: { response, scores, conversationId }, error, metadata }
//
// Phase 0 stub: verifies auth + input shape, then returns NOT_IMPLEMENTED until
// an AI provider key is configured (see _shared/ai-provider.ts).

import { handleCorsPreflight, jsonHeaders } from "../_shared/cors.ts";
import { getUser } from "../_shared/auth.ts";
import { chatWithFallback } from "../_shared/ai-provider.ts";
import { fail, ok } from "../_shared/types.ts";

const PATIENT_SYSTEM_PROMPT = `
You are a patient in a medical consultation simulation for MediLingo,
a medical English learning app. Respond ONLY in English, stay in character
as the patient described in the scenario, and adapt to the user's English level.
`.trim();

Deno.serve(async (req) => {
  const preflight = handleCorsPreflight(req);
  if (preflight) return preflight;

  const user = await getUser(req);
  if (!user) {
    return new Response(JSON.stringify(fail("UNAUTHORIZED", "Sign in required.")), {
      status: 401, headers: jsonHeaders,
    });
  }

  let body: { message?: string; conversationType?: string; scenario?: unknown };
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify(fail("BAD_REQUEST", "Invalid JSON body.")), {
      status: 400, headers: jsonHeaders,
    });
  }

  if (!body.message || typeof body.message !== "string") {
    return new Response(JSON.stringify(fail("BAD_REQUEST", "`message` is required.")), {
      status: 400, headers: jsonHeaders,
    });
  }

  try {
    const result = await chatWithFallback([
      { role: "system", content: PATIENT_SYSTEM_PROMPT },
      { role: "user", content: body.message },
    ], { responseFormat: "text" });

    return new Response(JSON.stringify(ok({ response: result.content, scores: null, provider: result.provider })), {
      status: 200, headers: jsonHeaders,
    });
  } catch (_e) {
    return new Response(JSON.stringify(fail("NOT_IMPLEMENTED", "AI provider not configured yet.")), {
      status: 501, headers: jsonHeaders,
    });
  }
});
