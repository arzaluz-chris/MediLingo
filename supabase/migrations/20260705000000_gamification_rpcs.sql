-- ============================================================================
-- MediLingo — Server-side gamification RPCs + RLS tightening
-- Rollback: DROP FUNCTION for each below; recreate the dropped FOR ALL policies.
--
-- Before this migration, clients could UPDATE their own user_stats row
-- directly (gems/XP/hearts forgeable) and purchases were two non-atomic
-- client writes. This migration moves every balance mutation behind
-- SECURITY DEFINER functions keyed on auth.uid() and demotes the client
-- policies to SELECT-only.
-- ============================================================================

-- user_inventory upsert target -------------------------------------------------
ALTER TABLE user_inventory
  ADD CONSTRAINT user_inventory_user_item_unique UNIQUE (user_id, item_id);

-- ----------------------------------------------------------------------------
-- add_xp: total/weekly XP + derived level + active league tally
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.add_xp(p_amount INT)
RETURNS public.user_stats
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_uid UUID := auth.uid();
  v_amount INT := LEAST(GREATEST(p_amount, 0), 1000); -- sanity clamp per call
  v_stats public.user_stats;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'not authenticated'; END IF;

  UPDATE public.user_stats SET
    total_xp  = total_xp + v_amount,
    weekly_xp = weekly_xp + v_amount,
    level     = public.calculate_level(total_xp + v_amount),
    updated_at = NOW()
  WHERE user_id = v_uid
  RETURNING * INTO v_stats;

  UPDATE public.league_members lm SET weekly_xp = lm.weekly_xp + v_amount
  FROM public.leagues l
  WHERE lm.user_id = v_uid AND lm.league_id = l.id AND l.is_active;

  RETURN v_stats;
END;
$$;

-- ----------------------------------------------------------------------------
-- consume_heart: -1 heart (premium users keep unlimited hearts)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.consume_heart()
RETURNS INT
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_uid UUID := auth.uid();
  v_hearts INT;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'not authenticated'; END IF;

  IF EXISTS (SELECT 1 FROM public.profiles WHERE id = v_uid AND is_premium) THEN
    SELECT hearts INTO v_hearts FROM public.user_stats WHERE user_id = v_uid;
    RETURN v_hearts;
  END IF;

  UPDATE public.user_stats SET
    hearts = GREATEST(hearts - 1, 0),
    updated_at = NOW()
  WHERE user_id = v_uid
  RETURNING hearts INTO v_hearts;
  RETURN v_hearts;
END;
$$;

-- ----------------------------------------------------------------------------
-- refill_hearts: replace the p_user_id variant (any caller could refill any
-- user) with an auth.uid()-keyed one. Same 1 heart / 4h policy.
-- ----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS public.refill_hearts(UUID);

CREATE OR REPLACE FUNCTION public.refill_hearts()
RETURNS INT
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_uid UUID := auth.uid();
  current_hearts INT;
  max_hearts INT;
  last_refill TIMESTAMPTZ;
  hearts_to_add INT;
  new_hearts INT;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'not authenticated'; END IF;

  SELECT hearts, hearts_max, hearts_last_refill
  INTO current_hearts, max_hearts, last_refill
  FROM public.user_stats WHERE user_id = v_uid;

  IF current_hearts >= max_hearts THEN
    RETURN current_hearts;
  END IF;

  hearts_to_add := FLOOR(EXTRACT(EPOCH FROM (NOW() - last_refill)) / 3600 / 4);
  IF hearts_to_add > 0 THEN
    new_hearts := LEAST(current_hearts + hearts_to_add, max_hearts);
    UPDATE public.user_stats SET
      hearts = new_hearts,
      hearts_last_refill = NOW(),
      updated_at = NOW()
    WHERE user_id = v_uid;
    RETURN new_hearts;
  END IF;

  RETURN current_hearts;
END;
$$;

-- ----------------------------------------------------------------------------
-- purchase_item: atomic gem purchase (lock → price/max checks → deduct →
-- inventory upsert → immediate effects)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.purchase_item(p_item_id UUID)
RETURNS public.user_stats
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_uid UUID := auth.uid();
  v_item public.shop_items;
  v_owned INT;
  v_stats public.user_stats;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'not authenticated'; END IF;

  SELECT * INTO v_item FROM public.shop_items
  WHERE id = p_item_id AND is_available;
  IF NOT FOUND THEN RAISE EXCEPTION 'item not available'; END IF;

  -- Serialize concurrent purchases for this user.
  SELECT * INTO v_stats FROM public.user_stats WHERE user_id = v_uid FOR UPDATE;

  IF v_stats.gems < v_item.price_gems THEN
    RAISE EXCEPTION 'insufficient gems';
  END IF;

  SELECT COALESCE(quantity, 0) INTO v_owned
  FROM public.user_inventory WHERE user_id = v_uid AND item_id = p_item_id;
  IF v_item.max_owned IS NOT NULL AND COALESCE(v_owned, 0) >= v_item.max_owned THEN
    RAISE EXCEPTION 'max owned reached';
  END IF;

  UPDATE public.user_stats SET
    gems = gems - v_item.price_gems,
    -- Immediate effects for consumable/power-up purchases.
    hearts = CASE WHEN v_item.effect->>'type' = 'heart_refill' THEN hearts_max ELSE hearts END,
    streak_freeze_count = CASE WHEN v_item.effect->>'type' = 'streak_freeze'
                               THEN streak_freeze_count + 1 ELSE streak_freeze_count END,
    updated_at = NOW()
  WHERE user_id = v_uid
  RETURNING * INTO v_stats;

  INSERT INTO public.user_inventory (user_id, item_id, quantity)
  VALUES (v_uid, p_item_id, 1)
  ON CONFLICT (user_id, item_id) DO UPDATE SET quantity = user_inventory.quantity + 1;

  RETURN v_stats;
END;
$$;

-- ----------------------------------------------------------------------------
-- get_or_assign_daily_quests: server-side assignment of 3 random active quests
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_or_assign_daily_quests()
RETURNS SETOF public.user_daily_quests
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_uid UUID := auth.uid();
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'not authenticated'; END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.user_daily_quests
    WHERE user_id = v_uid AND quest_date = CURRENT_DATE
  ) THEN
    INSERT INTO public.user_daily_quests (user_id, quest_id, quest_date)
    SELECT v_uid, id, CURRENT_DATE
    FROM public.daily_quests WHERE is_active
    ORDER BY RANDOM() LIMIT 3
    ON CONFLICT (user_id, quest_id, quest_date) DO NOTHING;
  END IF;

  RETURN QUERY SELECT * FROM public.user_daily_quests
  WHERE user_id = v_uid AND quest_date = CURRENT_DATE;
END;
$$;

-- ----------------------------------------------------------------------------
-- update_quest_progress: bump today's quests of a type; auto-award on complete
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.update_quest_progress(p_quest_type TEXT, p_increment INT)
RETURNS SETOF public.user_daily_quests
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_uid UUID := auth.uid();
  v_increment INT := LEAST(GREATEST(p_increment, 0), 500);
  v_row public.user_daily_quests;
  v_quest public.daily_quests;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'not authenticated'; END IF;

  FOR v_row IN
    SELECT udq.* FROM public.user_daily_quests udq
    JOIN public.daily_quests dq ON dq.id = udq.quest_id
    WHERE udq.user_id = v_uid AND udq.quest_date = CURRENT_DATE
      AND NOT udq.is_completed AND dq.quest_type = p_quest_type
  LOOP
    SELECT * INTO v_quest FROM public.daily_quests WHERE id = v_row.quest_id;

    UPDATE public.user_daily_quests SET
      current_value = current_value + v_increment,
      is_completed  = current_value + v_increment >= v_quest.target_value,
      completed_at  = CASE WHEN current_value + v_increment >= v_quest.target_value
                           THEN NOW() ELSE completed_at END
    WHERE id = v_row.id
    RETURNING * INTO v_row;

    IF v_row.is_completed THEN
      UPDATE public.user_stats SET
        total_xp  = total_xp + v_quest.xp_reward,
        weekly_xp = weekly_xp + v_quest.xp_reward,
        level     = public.calculate_level(total_xp + v_quest.xp_reward),
        gems      = gems + v_quest.gem_reward,
        updated_at = NOW()
      WHERE user_id = v_uid;
    END IF;

    RETURN NEXT v_row;
  END LOOP;
END;
$$;

-- ----------------------------------------------------------------------------
-- record_lesson_completion: single round-trip for the end-of-lesson mutation
-- (counters + XP + quests). Achievements checked separately.
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
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'not authenticated'; END IF;

  -- XP comes from the published lesson definition, never from the client.
  SELECT xp_reward INTO v_xp FROM public.lessons
  WHERE id = p_lesson_id AND is_published;
  IF NOT FOUND THEN RAISE EXCEPTION 'lesson not found'; END IF;

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

  SELECT * INTO v_stats FROM public.user_stats WHERE user_id = v_uid;
  RETURN v_stats;
END;
$$;

-- ----------------------------------------------------------------------------
-- record_activity: non-lesson counters (flashcards, vocabulary, AI chats)
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
  ELSE
    RAISE EXCEPTION 'unknown activity %', p_activity;
  END IF;

  SELECT * INTO v_stats FROM public.user_stats WHERE user_id = v_uid;
  RETURN v_stats;
END;
$$;

-- ----------------------------------------------------------------------------
-- check_achievements: evaluate stat-based requirements, insert unlocks,
-- award their XP/gem rewards, and return the newly unlocked rows.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.check_achievements()
RETURNS SETOF public.achievements
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_uid UUID := auth.uid();
  v_stats public.user_stats;
  v_flashcards BIGINT;
  v_ach public.achievements;
  v_met BOOLEAN;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'not authenticated'; END IF;

  SELECT * INTO v_stats FROM public.user_stats WHERE user_id = v_uid;
  SELECT COUNT(*) INTO v_flashcards FROM public.flashcard_reviews WHERE user_id = v_uid;

  FOR v_ach IN
    SELECT a.* FROM public.achievements a
    WHERE NOT EXISTS (
      SELECT 1 FROM public.user_achievements ua
      WHERE ua.user_id = v_uid AND ua.achievement_id = a.id
    )
  LOOP
    v_met := CASE v_ach.requirement->>'type'
      WHEN 'streak'              THEN v_stats.current_streak      >= (v_ach.requirement->>'value')::INT
      WHEN 'lessons_completed'   THEN v_stats.lessons_completed   >= (v_ach.requirement->>'value')::INT
      WHEN 'perfect_lessons'     THEN v_stats.perfect_lessons     >= (v_ach.requirement->>'value')::INT
      WHEN 'exercises_completed' THEN v_stats.exercises_completed >= (v_ach.requirement->>'value')::INT
      WHEN 'words_learned'       THEN v_stats.words_learned       >= (v_ach.requirement->>'value')::INT
      WHEN 'flashcards_reviewed' THEN v_flashcards                >= (v_ach.requirement->>'value')::INT
      WHEN 'clinical_cases'      THEN v_stats.clinical_cases_done >= (v_ach.requirement->>'value')::INT
      WHEN 'ai_conversations'    THEN v_stats.ai_conversations    >= (v_ach.requirement->>'value')::INT
      WHEN 'level'               THEN v_stats.level               >= (v_ach.requirement->>'value')::INT
      WHEN 'total_xp'            THEN v_stats.total_xp            >= (v_ach.requirement->>'value')::BIGINT
      WHEN 'league_reached'      THEN v_stats.current_league       = (v_ach.requirement->>'tier')
      WHEN 'course_completed'    THEN EXISTS (
        SELECT 1 FROM public.user_progress up
        JOIN public.courses c ON c.id = up.entity_id
        WHERE up.user_id = v_uid AND up.entity_type = 'course'
          AND up.status = 'completed' AND c.slug = v_ach.requirement->>'course_slug')
      ELSE FALSE -- social/time-of-day types evaluated elsewhere (post-MVP)
    END;

    IF v_met THEN
      INSERT INTO public.user_achievements (user_id, achievement_id)
      VALUES (v_uid, v_ach.id)
      ON CONFLICT (user_id, achievement_id) DO NOTHING;

      UPDATE public.user_stats SET
        total_xp  = total_xp + v_ach.xp_reward,
        weekly_xp = weekly_xp + v_ach.xp_reward,
        level     = public.calculate_level(total_xp + v_ach.xp_reward),
        gems      = gems + v_ach.gem_reward,
        updated_at = NOW()
      WHERE user_id = v_uid;

      RETURN NEXT v_ach;
    END IF;
  END LOOP;
END;
$$;

-- ----------------------------------------------------------------------------
-- Grants: RPCs for signed-in users only.
-- ----------------------------------------------------------------------------
REVOKE ALL ON FUNCTION public.add_xp(INT) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.consume_heart() FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.refill_hearts() FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.purchase_item(UUID) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.get_or_assign_daily_quests() FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.update_quest_progress(TEXT, INT) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.record_lesson_completion(UUID, REAL, BOOLEAN, INT, INT) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.record_activity(TEXT, INT) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.check_achievements() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.add_xp(INT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.consume_heart() TO authenticated;
GRANT EXECUTE ON FUNCTION public.refill_hearts() TO authenticated;
GRANT EXECUTE ON FUNCTION public.purchase_item(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_or_assign_daily_quests() TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_quest_progress(TEXT, INT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.record_lesson_completion(UUID, REAL, BOOLEAN, INT, INT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.record_activity(TEXT, INT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.check_achievements() TO authenticated;

-- ----------------------------------------------------------------------------
-- RLS tightening: balances/unlocks/quests become read-only for clients.
-- All writes now flow through the SECURITY DEFINER functions above.
-- ----------------------------------------------------------------------------
DROP POLICY "Own stats" ON user_stats;
CREATE POLICY "Own stats readable" ON user_stats FOR SELECT USING (auth.uid() = user_id);

DROP POLICY "Own inventory" ON user_inventory;
CREATE POLICY "Own inventory readable" ON user_inventory FOR SELECT USING (auth.uid() = user_id);

DROP POLICY "Own achievements" ON user_achievements;
CREATE POLICY "Own achievements readable" ON user_achievements FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Mark achievements notified" ON user_achievements FOR UPDATE
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY "Own daily quests" ON user_daily_quests;
CREATE POLICY "Own daily quests readable" ON user_daily_quests FOR SELECT USING (auth.uid() = user_id);

-- Challenges: participants can update state/scores (was SELECT+INSERT only).
CREATE POLICY "Participants update challenges" ON challenges FOR UPDATE
  USING (auth.uid() = challenger_id OR auth.uid() = challenged_id)
  WITH CHECK (auth.uid() = challenger_id OR auth.uid() = challenged_id);
