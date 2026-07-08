// Auth verification helper. Resolves the calling user from the Bearer JWT
// using the anon Supabase client. Returns null when unauthenticated.

import { createClient } from "jsr:@supabase/supabase-js@2";

export interface AuthedUser {
  id: string;
  email?: string;
}

export async function getUser(req: Request): Promise<AuthedUser | null> {
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return null;

  const supabase = userClient(req);
  const { data, error } = await supabase.auth.getUser();
  if (error || !data.user) return null;
  return { id: data.user.id, email: data.user.email ?? undefined };
}

// Supabase client bound to the caller's JWT — RLS applies and auth.uid() resolves
// to the caller inside SECURITY DEFINER RPCs (e.g. consume_ai_quota).
export function userClient(req: Request) {
  return createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    { global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } } },
  );
}

// Enforce a per-user AI usage quota via the consume_ai_quota RPC. Returns true
// when the call is allowed, false when the user is over their window limit.
export async function withinAIQuota(
  req: Request,
  kind: string,
  freeLimit: number,
  premiumLimit: number,
  windowSeconds: number,
): Promise<boolean> {
  const { data, error } = await userClient(req).rpc("consume_ai_quota", {
    p_kind: kind,
    p_free_limit: freeLimit,
    p_premium_limit: premiumLimit,
    p_window_seconds: windowSeconds,
  });
  // Fail closed on an unexpected error; allow only an explicit TRUE.
  if (error) return false;
  return data === true;
}
