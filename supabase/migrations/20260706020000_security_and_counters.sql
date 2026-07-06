-- ============================================================================
-- MediLingo — Close premium-forgery holes + clinical-case counter
-- Rollback: DROP TRIGGER trg_profiles_guard ON profiles;
--           DROP FUNCTION guard_profile_columns();
--           recreate "Own subscriptions" FOR ALL; drop the SELECT-only policy.
--
-- Audit found two ways a client could grant itself premium:
--   1. profiles.is_premium is a plain column and the profile UPDATE policy has
--      no column restriction — a user could PATCH is_premium = true.
--   2. subscriptions had a FOR ALL policy — a user could INSERT their own
--      status='active' row.
-- Both are now server-only (webhook / service role).
-- ============================================================================

-- Ensure pgcrypto is present for gen_random_bytes (certificates/referrals).
-- Supabase preinstalls it in the extensions schema; harmless if already there.
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;

-- ----------------------------------------------------------------------------
-- Guard server-controlled profile columns against client writes. A non-service
-- role UPDATE cannot change is_premium; the value is forced back to OLD.
-- The RevenueCat webhook and admin scripts use the service role, which bypasses
-- RLS and (being the table owner path) is exempted here.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.guard_profile_columns()
RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_claims TEXT := current_setting('request.jwt.claims', true);
BEGIN
  -- service_role bypasses RLS and manages premium via the webhook; only guard
  -- the authenticated app role. Claims is '' (not NULL) for the service role,
  -- so guard against empty before casting to jsonb.
  IF v_claims IS NOT NULL AND v_claims <> ''
     AND (v_claims::jsonb ->> 'role') = 'authenticated' THEN
    NEW.is_premium := OLD.is_premium;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_profiles_guard ON public.profiles;
CREATE TRIGGER trg_profiles_guard
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.guard_profile_columns();

-- ----------------------------------------------------------------------------
-- Subscriptions become read-only for clients. All writes flow through the
-- RevenueCat webhook (service role).
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Own subscriptions" ON public.subscriptions;
CREATE POLICY "Own subscriptions readable" ON public.subscriptions FOR SELECT
  USING (auth.uid() = user_id);

-- ----------------------------------------------------------------------------
-- record_activity: add clinical-case completion so the clinical_cases_done
-- counter (and its achievements) actually advance.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.record_activity(p_activity TEXT, p_amount INT)
RETURNS public.user_stats
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_uid UUID := auth.uid();
  v_amount INT := LEAST(GREATEST(p_amount, 0), 500);
  v_stats public.user_stats;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'not authenticated'; END IF;

  IF p_activity = 'review_flashcards' THEN
    PERFORM public.update_quest_progress('review_flashcards', v_amount);
  ELSIF p_activity = 'learn_words' THEN
    UPDATE public.user_stats SET words_learned = words_learned + v_amount, updated_at = NOW()
    WHERE user_id = v_uid;
    PERFORM public.update_quest_progress('learn_words', v_amount);
  ELSIF p_activity = 'ai_conversation' THEN
    UPDATE public.user_stats SET ai_conversations = ai_conversations + 1, updated_at = NOW()
    WHERE user_id = v_uid;
    PERFORM public.update_quest_progress('ai_conversation', 1);
  ELSIF p_activity = 'clinical_case' THEN
    UPDATE public.user_stats SET clinical_cases_done = clinical_cases_done + 1, updated_at = NOW()
    WHERE user_id = v_uid;
  ELSE
    RAISE EXCEPTION 'unknown activity %', p_activity;
  END IF;

  SELECT * INTO v_stats FROM public.user_stats WHERE user_id = v_uid;
  RETURN v_stats;
END;
$$;
