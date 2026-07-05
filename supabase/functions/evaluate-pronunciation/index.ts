// POST /functions/v1/evaluate-pronunciation
// Body: { word, phonetic?, audioUrl }
// Returns envelope: { data: { score, feedback }, error, metadata }
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

  let body: { word?: string; audioUrl?: string };
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify(fail("BAD_REQUEST", "Invalid JSON body.")), {
      status: 400, headers: jsonHeaders,
    });
  }

  if (!body.word || !body.audioUrl) {
    return new Response(JSON.stringify(fail("BAD_REQUEST", "`word` and `audioUrl` are required.")), {
      status: 400, headers: jsonHeaders,
    });
  }

  return new Response(JSON.stringify(fail("NOT_IMPLEMENTED", "Pronunciation scoring not configured yet.")), {
    status: 501, headers: jsonHeaders,
  });
});
