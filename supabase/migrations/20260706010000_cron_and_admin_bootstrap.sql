-- ============================================================================
-- MediLingo — Weekly league-rollover schedule + admin bootstrap
-- Rollback: SELECT cron.unschedule('league-rollover-weekly');
--           DROP FUNCTION promote_to_admin(TEXT), demote_admin(TEXT);
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Weekly league rotation via pg_cron. Calls the SQL function directly (no HTTP,
-- no secret needed). Runs Mondays at 08:00 UTC. Wrapped defensively so a
-- reset never fails where pg_cron is unavailable (it must be enabled in the
-- hosted project dashboard: Database → Extensions → pg_cron).
-- ----------------------------------------------------------------------------
DO $$
BEGIN
  CREATE EXTENSION IF NOT EXISTS pg_cron;
  PERFORM cron.schedule(
    'league-rollover-weekly',
    '0 8 * * 1',
    'SELECT public.rollover_leagues();'
  );
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'pg_cron unavailable; schedule public.rollover_leagues() manually. (%)', SQLERRM;
END $$;

-- ----------------------------------------------------------------------------
-- Admin bootstrap. admin_users is SELECT-only for the owner, so the first admin
-- cannot be created from the client. These SECURITY DEFINER helpers are granted
-- to service_role ONLY — run from the Supabase SQL editor or a server script:
--   SELECT public.promote_to_admin('you@example.com');
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.promote_to_admin(p_email TEXT)
RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_uid UUID;
BEGIN
  SELECT id INTO v_uid FROM auth.users WHERE email = LOWER(p_email);
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'no auth user with email %', p_email;
  END IF;

  INSERT INTO public.admin_users (user_id, email, role)
  VALUES (v_uid, LOWER(p_email), 'admin')
  ON CONFLICT (user_id) DO UPDATE SET role = 'admin';

  RETURN v_uid;
END;
$$;

CREATE OR REPLACE FUNCTION public.demote_admin(p_email TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_uid UUID;
BEGIN
  SELECT id INTO v_uid FROM auth.users WHERE email = LOWER(p_email);
  IF v_uid IS NULL THEN RETURN FALSE; END IF;
  DELETE FROM public.admin_users WHERE user_id = v_uid;
  RETURN TRUE;
END;
$$;

-- Never callable by app users — server / SQL-editor only.
REVOKE ALL ON FUNCTION public.promote_to_admin(TEXT) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.demote_admin(TEXT) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.promote_to_admin(TEXT) TO service_role;
GRANT EXECUTE ON FUNCTION public.demote_admin(TEXT) TO service_role;
