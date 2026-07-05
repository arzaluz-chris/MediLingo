import { createBrowserClient } from "@supabase/ssr";

// Browser Supabase client (anon key). Use in Client Components.
// Placeholder defaults keep `next build` from failing before .env.local is set.
export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL ?? "http://127.0.0.1:54321",
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ?? "anon-key-placeholder",
  );
}
