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

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    { global: { headers: { Authorization: authHeader } } },
  );

  const { data, error } = await supabase.auth.getUser();
  if (error || !data.user) return null;
  return { id: data.user.id, email: data.user.email ?? undefined };
}
