-- ============================================================================
-- MediLingo — Grant Data API roles access to the public schema
--
-- The hosted project has "Automatically expose new tables" disabled, so tables
-- created by migrations did NOT receive the anon/authenticated grants that
-- Supabase normally adds — clients hit "permission denied for table profiles".
--
-- RLS remains the real guard: these grants only let the roles *attempt* access;
-- the row-level policies (rls_policies.sql + later migrations) decide which rows
-- are actually visible/writable. This mirrors Supabase's default grant set.
-- ============================================================================

GRANT USAGE ON SCHEMA public TO anon, authenticated;

-- authenticated: full DML (RLS restricts to own rows / published content).
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;

-- anon: read-only (RLS still limits to published content).
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;

-- Sequences + functions.
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated;

-- Future tables/sequences/functions created in public inherit the same grants.
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT USAGE, SELECT ON SEQUENCES TO anon, authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT EXECUTE ON FUNCTIONS TO anon, authenticated;

-- Re-lock the admin bootstrap helpers: the blanket EXECUTE grant above would
-- otherwise undo their service_role-only restriction.
REVOKE ALL ON FUNCTION public.promote_to_admin(TEXT) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.demote_admin(TEXT) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.promote_to_admin(TEXT) TO service_role;
GRANT EXECUTE ON FUNCTION public.demote_admin(TEXT) TO service_role;
