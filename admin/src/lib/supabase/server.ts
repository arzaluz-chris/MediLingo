import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";
import { createClient as createServiceClient } from "@supabase/supabase-js";
import { requireEnv } from "@/lib/env";

// Server Supabase client bound to the request cookies (anon key, RLS enforced).
// Use in Server Components, Route Handlers, and Server Actions.
export async function createClient() {
  const cookieStore = await cookies();
  return createServerClient(
    requireEnv("NEXT_PUBLIC_SUPABASE_URL"),
    requireEnv("NEXT_PUBLIC_SUPABASE_ANON_KEY"),
    {
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
    },
  );
}

// Service-role client — BYPASSES RLS. Server-only. Never import in a Client
// Component. Used for privileged content writes from the CMS. Every server
// action that uses this client MUST call assertAdmin() first (lib/auth.ts).
export function createAdminClient() {
  return createServiceClient(
    requireEnv("NEXT_PUBLIC_SUPABASE_URL"),
    requireEnv("SUPABASE_SERVICE_ROLE_KEY"),
    { auth: { persistSession: false, autoRefreshToken: false } },
  );
}
