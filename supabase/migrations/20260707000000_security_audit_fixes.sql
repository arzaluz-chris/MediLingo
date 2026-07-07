-- ============================================================================
-- MediLingo — Security audit fixes (2026-07-07)
--
-- Closes the findings from the security/architecture audit:
--   1. rollover_leagues() was re-exposed to anon/authenticated by the blanket
--      GRANT in 20260706030000 (only promote/demote_admin were re-locked).
--   2. profiles.email (+ referral columns) leaked to anyone with the anon key
--      via the "USING (TRUE)" SELECT policy + the anon/authenticated table grant.
--   3. record_lesson_completion had no idempotency → replaying it farmed XP,
--      gems, counters and achievements. add_xp() was directly callable with an
--      arbitrary (clamped-per-call) amount, unbounded in aggregate.
--   4. AI Edge Functions had no rate-limit / quota (this adds the server side).
--   5. guard_profile_columns only reverted is_premium; premium_until/referred_by/
--      referral_code were still client-writable.
--   6. redeem_referral could double-pay under a race and paid out immediately
--      instead of on the invitee's first lesson (docs/GAMIFICATION.md).
--   7. leagues had a UNIQUE(tier, week_start, id) that includes the PK and so
--      never constrained anything.
--
-- Rollback notes are inline per section.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- (1) Re-lock rollover_leagues(). Recreated WITH an internal guard so it stays
-- service-role only even if a future blanket GRANT re-exposes it. auth.uid() is
-- NULL for pg_cron (runs as the table owner) and for the service role.
-- Rollback: restore the body from 20260705000001 and drop the guard.
-- ----------------------------------------------------------------------------
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
  -- Defense in depth: never runnable in the context of a signed-in app user.
  IF auth.uid() IS NOT NULL THEN
    RAISE EXCEPTION 'rollover_leagues is service-role only';
  END IF;

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
GRANT EXECUTE ON FUNCTION public.rollover_leagues() TO service_role;

-- ----------------------------------------------------------------------------
-- (2) Stop leaking PII. RLS is row-level only, so column exposure is controlled
-- via table grants. The public leaderboard needs display_name/avatar of other
-- users; nothing in the app reads other users' email. Revoke the blanket SELECT
-- and re-grant every column EXCEPT email (anon gets only identity columns).
-- Rollback: GRANT SELECT ON public.profiles TO anon, authenticated;
-- ----------------------------------------------------------------------------
REVOKE SELECT ON public.profiles FROM anon, authenticated;

GRANT SELECT (
  id, display_name, avatar_url, role, english_level, primary_goal, specialty,
  daily_goal_xp, locale, timezone, is_premium, premium_until, referral_code,
  referred_by, created_at, updated_at
) ON public.profiles TO authenticated;

GRANT SELECT (id, display_name, avatar_url) ON public.profiles TO anon;

-- ----------------------------------------------------------------------------
-- (5) Extend the profile guard: block client writes to every server-controlled
-- column, not just is_premium. role/english_level/primary_goal/daily_goal_xp
-- stay editable (onboarding writes them).
-- Rollback: restore the single-column body from 20260706020000.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.guard_profile_columns()
RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_claims TEXT := current_setting('request.jwt.claims', true);
BEGIN
  IF v_claims IS NOT NULL AND v_claims <> ''
     AND (v_claims::jsonb ->> 'role') = 'authenticated' THEN
    NEW.is_premium    := OLD.is_premium;
    NEW.premium_until := OLD.premium_until;
    NEW.referred_by   := OLD.referred_by;
    NEW.referral_code := OLD.referral_code;
  END IF;
  RETURN NEW;
END;
$$;

-- ----------------------------------------------------------------------------
-- (3a) add_xp: unused by the client (no call sites) and a raw balance-forgery
-- primitive. Revoke it from app roles; server-side XP now flows exclusively
-- through record_lesson_completion / update_quest_progress / check_achievements.
-- Rollback: GRANT EXECUTE ON FUNCTION public.add_xp(INT) TO authenticated;
-- ----------------------------------------------------------------------------
REVOKE ALL ON FUNCTION public.add_xp(INT) FROM PUBLIC, anon, authenticated;

-- ----------------------------------------------------------------------------
-- (3b) record_lesson_completion: make it idempotent. The completion is claimed
-- atomically by inserting the 'completed' user_progress row; only the call that
-- actually inserts it awards XP/counters/quests. Replays and concurrent
-- duplicates conflict on (user_id, entity_type, entity_id) and are no-ops.
-- (Also pays out a pending referral on the invitee's first lesson — see (6).)
-- Rollback: restore the body from 20260705000000.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.record_lesson_completion(
  p_lesson_id UUID,
  p_score REAL,
  p_perfect BOOLEAN,
  p_time_minutes INT,
  p_exercise_count INT
)
RETURNS public.user_stats
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_uid UUID := auth.uid();
  v_xp INT;
  v_stats public.user_stats;
  v_referrer UUID;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'not authenticated'; END IF;

  -- XP comes from the published lesson definition, never from the client.
  SELECT xp_reward INTO v_xp FROM public.lessons
  WHERE id = p_lesson_id AND is_published;
  IF NOT FOUND THEN RAISE EXCEPTION 'lesson not found'; END IF;

  -- Idempotency gate: first writer wins.
  INSERT INTO public.user_progress (user_id, entity_type, entity_id, status, score, xp_earned, completed_at)
  VALUES (v_uid, 'lesson', p_lesson_id, 'completed', p_score, v_xp, NOW())
  ON CONFLICT (user_id, entity_type, entity_id) DO NOTHING;

  IF NOT FOUND THEN
    -- Already recorded — do not re-award. Ensure it reads as completed and return.
    UPDATE public.user_progress SET
      status = 'completed',
      score = GREATEST(COALESCE(score, 0), p_score),
      completed_at = COALESCE(completed_at, NOW()),
      last_active_at = NOW()
    WHERE user_id = v_uid AND entity_type = 'lesson' AND entity_id = p_lesson_id;

    SELECT * INTO v_stats FROM public.user_stats WHERE user_id = v_uid;
    RETURN v_stats;
  END IF;

  UPDATE public.user_stats SET
    lessons_completed   = lessons_completed + 1,
    exercises_completed = exercises_completed + LEAST(GREATEST(p_exercise_count, 0), 100),
    perfect_lessons     = perfect_lessons + CASE WHEN p_perfect THEN 1 ELSE 0 END,
    time_spent_minutes  = time_spent_minutes + LEAST(GREATEST(p_time_minutes, 0), 240),
    total_xp  = total_xp + v_xp,
    weekly_xp = weekly_xp + v_xp,
    level     = public.calculate_level(total_xp + v_xp),
    updated_at = NOW()
  WHERE user_id = v_uid
  RETURNING * INTO v_stats;

  UPDATE public.league_members lm SET weekly_xp = lm.weekly_xp + v_xp
  FROM public.leagues l
  WHERE lm.user_id = v_uid AND lm.league_id = l.id AND l.is_active;

  PERFORM public.update_quest_progress('complete_lessons', 1);
  PERFORM public.update_quest_progress('earn_xp', v_xp);
  IF p_perfect THEN
    PERFORM public.update_quest_progress('perfect_lesson', 1);
  END IF;

  -- (6) Deferred referral payout: reward both parties the first time the invitee
  -- completes a lesson. At most one row (uniq_referrals_referee) so RETURNING is
  -- single-valued; idempotent because status flips to 'rewarded'.
  UPDATE public.referrals SET status = 'rewarded', rewarded_at = NOW()
  WHERE referee_id = v_uid AND status = 'redeemed'
  RETURNING referrer_id INTO v_referrer;
  IF v_referrer IS NOT NULL THEN
    UPDATE public.user_stats SET gems = gems + 100, updated_at = NOW()
    WHERE user_id IN (v_uid, v_referrer);
  END IF;

  SELECT * INTO v_stats FROM public.user_stats WHERE user_id = v_uid;
  RETURN v_stats;
END;
$$;

-- ----------------------------------------------------------------------------
-- (6) redeem_referral: prevent double-redeem with a hard unique index, and defer
-- the gem reward to the invitee's first lesson — unless they already completed
-- one, in which case pay out immediately. referee_id is set atomically; the
-- unique index turns a concurrent second redemption into a constraint error.
-- Rollback: DROP INDEX uniq_referrals_referee; restore body from 20260706000000.
-- ----------------------------------------------------------------------------
CREATE UNIQUE INDEX IF NOT EXISTS uniq_referrals_referee
  ON public.referrals (referee_id) WHERE referee_id IS NOT NULL;

CREATE OR REPLACE FUNCTION public.redeem_referral(p_code TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_uid UUID := auth.uid();
  v_ref public.referrals;
  v_done INT;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'not authenticated'; END IF;

  SELECT * INTO v_ref FROM public.referrals
  WHERE code = UPPER(p_code) AND status = 'pending' AND referee_id IS NULL
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'invalid or used code'; END IF;
  IF v_ref.referrer_id = v_uid THEN RAISE EXCEPTION 'cannot redeem own code'; END IF;

  -- One redemption per referee, ever (belt-and-suspenders with the unique index).
  IF EXISTS (SELECT 1 FROM public.referrals WHERE referee_id = v_uid) THEN
    RAISE EXCEPTION 'referral already redeemed';
  END IF;

  SELECT lessons_completed INTO v_done FROM public.user_stats WHERE user_id = v_uid;

  IF COALESCE(v_done, 0) > 0 THEN
    -- Established user: reward now.
    UPDATE public.referrals SET
      referee_id = v_uid, status = 'rewarded',
      redeemed_at = NOW(), rewarded_at = NOW()
    WHERE id = v_ref.id;

    UPDATE public.user_stats SET gems = gems + 100, updated_at = NOW()
    WHERE user_id IN (v_uid, v_ref.referrer_id);
  ELSE
    -- New user: mark redeemed; record_lesson_completion pays out on first lesson.
    UPDATE public.referrals SET
      referee_id = v_uid, status = 'redeemed', redeemed_at = NOW()
    WHERE id = v_ref.id;
  END IF;

  RETURN TRUE;
END;
$$;

-- ----------------------------------------------------------------------------
-- (7) Drop the meaningless UNIQUE(tier, week_start, id): including the PK makes
-- it always satisfied. Multiple active cohorts per tier/week are intended
-- (join_league spins up a new cohort when the current one fills), so no
-- replacement constraint is needed.
-- Rollback: ALTER TABLE public.leagues ADD UNIQUE (tier, week_start, id);
-- ----------------------------------------------------------------------------
ALTER TABLE public.leagues DROP CONSTRAINT IF EXISTS leagues_tier_week_start_id_key;

-- ----------------------------------------------------------------------------
-- (4) AI usage quota. Server-side rate limiting for the AI Edge Functions
-- (ai-conversation, evaluate-pronunciation, generate-exercise-feedback), with a
-- higher ceiling for premium users. The Edge Functions call consume_ai_quota()
-- with the caller's JWT before invoking a provider; FALSE ⇒ HTTP 429.
-- Rollback: DROP FUNCTION public.consume_ai_quota(TEXT,INT,INT,INT);
--           DROP TABLE public.ai_usage_events;
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ai_usage_events (
  id          BIGSERIAL PRIMARY KEY,
  user_id     UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  kind        TEXT NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_ai_usage_user_kind_time
  ON public.ai_usage_events (user_id, kind, created_at DESC);

-- RLS on, no policies: only SECURITY DEFINER / service role may read or write it.
-- The blanket DML grant + default privileges from 20260706030000 would otherwise
-- hand authenticated a direct grant; RLS (no policy = deny all) still blocks it,
-- but revoke explicitly so the table is service-role-only by grant as well.
ALTER TABLE public.ai_usage_events ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.ai_usage_events FROM anon, authenticated;

CREATE OR REPLACE FUNCTION public.consume_ai_quota(
  p_kind TEXT,
  p_free_limit INT,
  p_premium_limit INT,
  p_window_seconds INT
)
RETURNS BOOLEAN
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_uid UUID := auth.uid();
  v_premium BOOLEAN;
  v_limit INT;
  v_count INT;
BEGIN
  IF v_uid IS NULL THEN RETURN FALSE; END IF;

  SELECT is_premium INTO v_premium FROM public.profiles WHERE id = v_uid;
  v_limit := CASE WHEN COALESCE(v_premium, FALSE) THEN p_premium_limit ELSE p_free_limit END;

  SELECT COUNT(*) INTO v_count FROM public.ai_usage_events
  WHERE user_id = v_uid AND kind = p_kind
    AND created_at > NOW() - make_interval(secs => p_window_seconds);

  IF v_count >= v_limit THEN RETURN FALSE; END IF;

  INSERT INTO public.ai_usage_events (user_id, kind) VALUES (v_uid, p_kind);
  RETURN TRUE;
END;
$$;

REVOKE ALL ON FUNCTION public.consume_ai_quota(TEXT, INT, INT, INT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.consume_ai_quota(TEXT, INT, INT, INT) TO authenticated, service_role;
