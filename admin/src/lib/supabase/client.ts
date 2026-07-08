import { createBrowserClient } from "@supabase/ssr";

// Browser Supabase client (anon key). Use in Client Components.
// NEXT_PUBLIC_* vars are inlined at build time via static replacement of the
// literal `process.env.NEXT_PUBLIC_X` expression. They must be referenced that
// way here (not via a computed process.env[name] lookup, which the bundler
// cannot statically analyze and which always evaluates to undefined in the
// browser). We still fail loudly at runtime rather than falling back to bogus
// values that mask a misconfigured deployment, except during the production
// build itself, where the vars may legitimately be absent.
function publicEnv(name: string, value: string | undefined): string {
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
          publicEnv("NEXT_PUBLIC_SUPABASE_URL", process.env.NEXT_PUBLIC_SUPABASE_URL),
          publicEnv("NEXT_PUBLIC_SUPABASE_ANON_KEY", process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY),
        );
}
