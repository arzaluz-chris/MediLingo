// POST /functions/v1/delete-account
// GDPR account deletion. Called by the signed-in user from the iOS app
// (SupabaseAuthService.deleteAccount). Verifies the caller's JWT, then uses the
// service role to remove the auth user — profiles and all user-owned rows
// cascade via ON DELETE CASCADE foreign keys.

import { handleCorsPreflight, jsonHeaders } from "../_shared/cors.ts";
import { fail, ok } from "../_shared/types.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

Deno.serve(async (req) => {
  const preflight = handleCorsPreflight(req);
  if (preflight) return preflight;

  const authHeader = req.headers.get("Authorization") ?? "";
  const jwt = authHeader.replace(/^Bearer\s+/i, "");
  if (!jwt) {
    return new Response(JSON.stringify(fail("UNAUTHORIZED", "Sign in required.")), {
      status: 401, headers: jsonHeaders,
    });
  }

  const url = Deno.env.get("SUPABASE_URL") ?? "";
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  const admin = createClient(url, serviceKey);

  // Resolve the caller from their own JWT — never trust a client-supplied id.
  const { data: userData, error: userError } = await admin.auth.getUser(jwt);
  if (userError || !userData?.user) {
    return new Response(JSON.stringify(fail("UNAUTHORIZED", "Invalid session.")), {
      status: 401, headers: jsonHeaders,
    });
  }

  const userId = userData.user.id;
  const { error: deleteError } = await admin.auth.admin.deleteUser(userId);
  if (deleteError) {
    return new Response(JSON.stringify(fail("INTERNAL", deleteError.message)), {
      status: 500, headers: jsonHeaders,
    });
  }

  return new Response(JSON.stringify(ok({ deleted: userId })), {
    status: 200, headers: jsonHeaders,
  });
});
