// POST /functions/v1/league-rollover
// Weekly cron entry point (schedule via `supabase functions deploy` + cron, or
// pg_cron calling this endpoint). Requires the service-role key — league
// rotation is never client-triggered.
//
// Delegates to the SQL function public.rollover_leagues(): ranks each expired
// active cohort, promotes top 10 / demotes bottom 25+, resets weekly XP, and
// closes the week. Returns the number of cohorts closed.

import { handleCorsPreflight, jsonHeaders } from "../_shared/cors.ts";
import { fail, ok } from "../_shared/types.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

Deno.serve(async (req) => {
  const preflight = handleCorsPreflight(req);
  if (preflight) return preflight;

  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  const authHeader = req.headers.get("Authorization") ?? "";
  if (!serviceKey || authHeader !== `Bearer ${serviceKey}`) {
    return new Response(JSON.stringify(fail("UNAUTHORIZED", "Service role required.")), {
      status: 401, headers: jsonHeaders,
    });
  }

  const supabase = createClient(Deno.env.get("SUPABASE_URL") ?? "", serviceKey);
  const { data, error } = await supabase.rpc("rollover_leagues");
  if (error) {
    return new Response(JSON.stringify(fail("INTERNAL", error.message)), {
      status: 500, headers: jsonHeaders,
    });
  }

  return new Response(JSON.stringify(ok({ cohortsClosed: data })), {
    status: 200, headers: jsonHeaders,
  });
});
