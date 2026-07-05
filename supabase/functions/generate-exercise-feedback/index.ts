// POST /functions/v1/generate-exercise-feedback
// Body: { exerciseId, userAnswer, isCorrect }
// Returns envelope: { data: { explanation }, error, metadata }
//
// Phase 0 stub: verifies auth + input, returns NOT_IMPLEMENTED until wired.

import { handleCorsPreflight, jsonHeaders } from "../_shared/cors.ts";
import { getUser } from "../_shared/auth.ts";
import { fail } from "../_shared/types.ts";

Deno.serve(async (req) => {
  const preflight = handleCorsPreflight(req);
  if (preflight) return preflight;

  const user = await getUser(req);
  if (!user) {
    return new Response(JSON.stringify(fail("UNAUTHORIZED", "Sign in required.")), {
      status: 401, headers: jsonHeaders,
    });
  }

  let body: { exerciseId?: string; userAnswer?: string; isCorrect?: boolean };
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify(fail("BAD_REQUEST", "Invalid JSON body.")), {
      status: 400, headers: jsonHeaders,
    });
  }

  if (!body.exerciseId) {
    return new Response(JSON.stringify(fail("BAD_REQUEST", "`exerciseId` is required.")), {
      status: 400, headers: jsonHeaders,
    });
  }

  return new Response(JSON.stringify(fail("NOT_IMPLEMENTED", "Feedback generation not configured yet.")), {
    status: 501, headers: jsonHeaders,
  });
});
