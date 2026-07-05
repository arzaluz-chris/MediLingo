-- ============================================================================
-- MediLingo — Leagues: self-serve join + weekly rollover support
-- Rollback: DROP FUNCTION public.join_league(); DROP FUNCTION public.rollover_leagues();
--
-- join_league(): called by the client the first time it opens standings —
-- places the user in an active league of their current tier (creating a
-- cohort when all are full), keyed on auth.uid().
-- rollover_leagues(): service-role only (weekly cron / league-rollover Edge
-- Function) — ranks cohorts, promotes top 10 / demotes bottom 5, closes the
-- week, and re-seats everyone for the new week.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.join_league()
RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_uid UUID := auth.uid();
  v_tier TEXT;
  v_league_id UUID;
  v_week_start DATE := DATE_TRUNC('week', CURRENT_DATE)::DATE;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'not authenticated'; END IF;

  -- Already seated this week?
  SELECT lm.league_id INTO v_league_id
  FROM public.league_members lm
  JOIN public.leagues l ON l.id = lm.league_id
  WHERE lm.user_id = v_uid AND l.is_active AND l.week_start = v_week_start;
  IF FOUND THEN RETURN v_league_id; END IF;

  SELECT current_league INTO v_tier FROM public.user_stats WHERE user_id = v_uid;

  -- Active cohort of this tier with a free seat.
  SELECT l.id INTO v_league_id
  FROM public.leagues l
  WHERE l.is_active AND l.tier = v_tier AND l.week_start = v_week_start
    AND (SELECT COUNT(*) FROM public.league_members m WHERE m.league_id = l.id) < l.max_members
  ORDER BY l.created_at
  LIMIT 1;

  IF v_league_id IS NULL THEN
    INSERT INTO public.leagues (tier, week_start, week_end)
    VALUES (v_tier, v_week_start, v_week_start + 6)
    RETURNING id INTO v_league_id;
  END IF;

  INSERT INTO public.league_members (league_id, user_id, weekly_xp)
  VALUES (v_league_id, v_uid, 0)
  ON CONFLICT (league_id, user_id) DO NOTHING;

  RETURN v_league_id;
END;
$$;

REVOKE ALL ON FUNCTION public.join_league() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.join_league() TO authenticated;

-- Weekly rotation. No auth.uid() — restricted to service_role.
CREATE OR REPLACE FUNCTION public.rollover_leagues()
RETURNS INT
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_league RECORD;
  v_member RECORD;
  v_rank INT;
  v_closed INT := 0;
BEGIN
  FOR v_league IN
    SELECT * FROM public.leagues WHERE is_active AND week_end < CURRENT_DATE
  LOOP
    v_rank := 0;
    FOR v_member IN
      SELECT * FROM public.league_members
      WHERE league_id = v_league.id
      ORDER BY weekly_xp DESC
    LOOP
      v_rank := v_rank + 1;

      UPDATE public.league_members SET
        rank = v_rank,
        promoted = v_rank <= 10 AND v_league.tier <> 'master',
        demoted  = v_rank > 25 AND v_league.tier <> 'bronze'
      WHERE id = v_member.id;

      UPDATE public.user_stats SET
        current_league = CASE
          WHEN v_rank <= 10 THEN CASE v_league.tier
            WHEN 'bronze' THEN 'silver' WHEN 'silver' THEN 'gold'
            WHEN 'gold' THEN 'diamond' WHEN 'diamond' THEN 'master'
            ELSE 'master' END
          WHEN v_rank > 25 THEN CASE v_league.tier
            WHEN 'master' THEN 'diamond' WHEN 'diamond' THEN 'gold'
            WHEN 'gold' THEN 'silver' ELSE 'bronze' END
          ELSE v_league.tier END,
        weekly_xp = 0,
        updated_at = NOW()
      WHERE user_id = v_member.user_id;
    END LOOP;

    UPDATE public.leagues SET is_active = FALSE WHERE id = v_league.id;
    v_closed := v_closed + 1;
  END LOOP;

  RETURN v_closed;
END;
$$;

REVOKE ALL ON FUNCTION public.rollover_leagues() FROM PUBLIC, anon, authenticated;
