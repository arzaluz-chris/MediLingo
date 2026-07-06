// Required environment variable lookup. Fails loudly at runtime instead of
// silently falling back to placeholders that mask misconfiguration.
//
// Exception: during `next build` env vars are often absent (CI, fresh clone),
// so a placeholder is returned to keep the build green — the error then
// surfaces immediately on the first real request.
export function requireEnv(name: string): string {
  const value = process.env[name];
  if (value && value.length > 0) return value;

  if (process.env.NEXT_PHASE === "phase-production-build") {
    return `build-placeholder-${name}`;
  }

  throw new Error(
    `[MediLingo Admin] Missing required environment variable "${name}". ` +
      "Add it to admin/.env.local (see CLAUDE.md § Environment Variables).",
  );
}
