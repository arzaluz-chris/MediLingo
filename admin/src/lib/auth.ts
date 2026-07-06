import { createClient } from "@/lib/supabase/server";

// Server-side admin guard. Every server action that touches the service-role
// client MUST call this FIRST — middleware gates page routes, but server
// actions are directly invokable endpoints and need their own check.
//
// Uses the caller's cookie-bound anon client: the "Read own admin row" RLS
// policy on admin_users lets a user see only their own row, so a hit proves
// the session belongs to an admin. Returns an error message, or null when the
// caller is a verified admin.
export async function assertAdmin(): Promise<string | null> {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return "Not authenticated";

  const { data: admin, error } = await supabase
    .from("admin_users")
    .select("user_id")
    .eq("user_id", user.id)
    .maybeSingle();

  if (error) return `Admin check failed: ${error.message}`;
  if (!admin) return "This account does not have admin access";
  return null;
}
