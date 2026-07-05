import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";
import { createClient as createServiceClient } from "@supabase/supabase-js";

const URL = process.env.NEXT_PUBLIC_SUPABASE_URL ?? "http://127.0.0.1:54321";
const ANON = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ?? "anon-key-placeholder";

// Server Supabase client bound to the request cookies (anon key, RLS enforced).
// Use in Server Components, Route Handlers, and Server Actions.
export async function createClient() {
  const cookieStore = await cookies();
  return createServerClient(URL, ANON, {
    cookies: {
      getAll() {
        return cookieStore.getAll();
      },
      setAll(cookiesToSet) {
        try {
          cookiesToSet.forEach(({ name, value, options }) =>
            cookieStore.set(name, value, options),
          );
        } catch {
          // Called from a Server Component — safe to ignore; middleware refreshes.
        }
      },
    },
  });
}

// Service-role client — BYPASSES RLS. Server-only. Never import in a Client
// Component. Used for privileged content writes from the CMS.
export function createAdminClient() {
  return createServiceClient(
    URL,
    process.env.SUPABASE_SERVICE_ROLE_KEY ?? "service-role-placeholder",
    { auth: { persistSession: false, autoRefreshToken: false } },
  );
}
