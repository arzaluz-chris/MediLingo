import { createBrowserClient } from "@supabase/ssr";

// Browser Supabase client (anon key). Use in Client Components.
// NEXT_PUBLIC_* vars are inlined at build time, so they cannot go through the
// server-only requireEnv(). We still fail loudly at runtime rather than falling
// back to bogus values that mask a misconfigured deployment — except during the
// production build itself, where the vars may legitimately be absent.
function publicEnv(name: string): string {
  const value = process.env[name];
  if (value && value.length > 0) return value;
  if (process.env.NEXT_PHASE === "phase-production-build") {
    return `build-placeholder-${name}`;
  }
  throw new Error(
    `[MediLingo Admin] Missing required public environment variable "${name}". ` +
      "Add it to admin/.env.local (see .env.local.example).",
  );
}

export function createClient() {
  return createBrowserClient(
    publicEnv("NEXT_PUBLIC_SUPABASE_URL"),
    publicEnv("NEXT_PUBLIC_SUPABASE_ANON_KEY"),
  );
}
