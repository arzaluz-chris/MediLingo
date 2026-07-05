-- ============================================================================
-- MediLingo — Row Level Security
-- Rollback: ALTER TABLE <t> DISABLE ROW LEVEL SECURITY; DROP POLICY ...;
-- RLS is enabled on EVERY table (CLAUDE.md: "RLS on ALL tables. No exceptions.").
-- Content writes have NO user policies — they go through the service-role key
-- (admin panel). Tables with RLS on and no policy deny all non-service access.
-- ============================================================================

-- Enable RLS everywhere -------------------------------------------------------
ALTER TABLE profiles            ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings       ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_onboarding     ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses             ENABLE ROW LEVEL SECURITY;
ALTER TABLE modules             ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons             ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercises           ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercise_options    ENABLE ROW LEVEL SECURITY;
ALTER TABLE vocabulary          ENABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_vocabulary   ENABLE ROW LEVEL SECURITY;
ALTER TABLE audio_clips         ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress       ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercise_attempts   ENABLE ROW LEVEL SECURITY;
ALTER TABLE vocabulary_mastery  ENABLE ROW LEVEL SECURITY;
ALTER TABLE flashcard_reviews   ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_stats          ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements        ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements   ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_quests        ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_daily_quests   ENABLE ROW LEVEL SECURITY;
ALTER TABLE leagues             ENABLE ROW LEVEL SECURITY;
ALTER TABLE league_members      ENABLE ROW LEVEL SECURITY;
ALTER TABLE friendships         ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenges          ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_conversations    ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_messages         ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions       ENABLE ROW LEVEL SECURITY;
ALTER TABLE shop_items          ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_inventory      ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_events    ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_ratings     ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_users         ENABLE ROW LEVEL SECURITY;

-- PROFILES --------------------------------------------------------------------
CREATE POLICY "Profiles are readable" ON profiles FOR SELECT USING (TRUE);
CREATE POLICY "Users update own profile" ON profiles FOR UPDATE
  USING (auth.uid() = id) WITH CHECK (auth.uid() = id);
CREATE POLICY "Users insert own profile" ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- CONTENT (published rows public-readable; writes are service-role only) -------
CREATE POLICY "Published courses public"    ON courses    FOR SELECT USING (is_published = TRUE);
CREATE POLICY "Published modules public"    ON modules    FOR SELECT USING (is_published = TRUE);
CREATE POLICY "Published lessons public"    ON lessons    FOR SELECT USING (is_published = TRUE);
CREATE POLICY "Published exercises public"  ON exercises  FOR SELECT USING (is_published = TRUE);
CREATE POLICY "Published vocabulary public" ON vocabulary FOR SELECT USING (is_published = TRUE);
CREATE POLICY "Published audio public"      ON audio_clips FOR SELECT USING (is_published = TRUE);
-- Child rows of published content are readable (parent gate enforced by join).
CREATE POLICY "Exercise options readable"   ON exercise_options  FOR SELECT USING (TRUE);
CREATE POLICY "Lesson vocabulary readable"  ON lesson_vocabulary FOR SELECT USING (TRUE);

-- REFERENCE DATA (read-only lookups for any authenticated user) ----------------
CREATE POLICY "Achievements public" ON achievements FOR SELECT USING (TRUE);
CREATE POLICY "Daily quests public" ON daily_quests FOR SELECT USING (TRUE);
CREATE POLICY "Shop items public"   ON shop_items   FOR SELECT USING (TRUE);

-- USER-OWNED DATA (full access to own rows only) ------------------------------
CREATE POLICY "Own settings"        ON user_settings      FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Own onboarding"      ON user_onboarding    FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Own progress"        ON user_progress      FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Own attempts"        ON exercise_attempts  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Own vocab mastery"   ON vocabulary_mastery FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Own flashcards"      ON flashcard_reviews  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Own stats"           ON user_stats         FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Own achievements"    ON user_achievements  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Own daily quests"    ON user_daily_quests  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Own subscriptions"   ON subscriptions      FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Own inventory"       ON user_inventory     FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Own ratings"         ON content_ratings    FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Own conversations"   ON ai_conversations   FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- AI messages: access gated through owning conversation.
CREATE POLICY "Own conversation messages" ON ai_messages FOR ALL
  USING (EXISTS (SELECT 1 FROM ai_conversations c WHERE c.id = conversation_id AND c.user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM ai_conversations c WHERE c.id = conversation_id AND c.user_id = auth.uid()));

-- Analytics: users may insert + read their own events.
CREATE POLICY "Insert own events" ON analytics_events FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Read own events"   ON analytics_events FOR SELECT USING (auth.uid() = user_id);

-- SOCIAL ----------------------------------------------------------------------
CREATE POLICY "See own friendships" ON friendships FOR SELECT
  USING (auth.uid() = user_id OR auth.uid() = friend_id);
CREATE POLICY "Create friendship requests" ON friendships FOR INSERT
  WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Update received friendships" ON friendships FOR UPDATE
  USING (auth.uid() = friend_id);

CREATE POLICY "See own challenges" ON challenges FOR SELECT
  USING (auth.uid() = challenger_id OR auth.uid() = challenged_id);
CREATE POLICY "Create challenges" ON challenges FOR INSERT
  WITH CHECK (auth.uid() = challenger_id);

-- LEAGUES (standings public; membership mutated by Edge Functions/service role)-
CREATE POLICY "Leagues public"        ON leagues        FOR SELECT USING (TRUE);
CREATE POLICY "League members public" ON league_members FOR SELECT USING (TRUE);

-- ADMIN -----------------------------------------------------------------------
CREATE POLICY "Read own admin row" ON admin_users FOR SELECT USING (auth.uid() = user_id);

-- STORAGE POLICIES ------------------------------------------------------------
CREATE POLICY "Public audio read"      ON storage.objects FOR SELECT USING (bucket_id = 'audio');
CREATE POLICY "Public images read"     ON storage.objects FOR SELECT USING (bucket_id = 'images');
CREATE POLICY "Public animations read" ON storage.objects FOR SELECT USING (bucket_id = 'animations');
CREATE POLICY "Own recordings" ON storage.objects FOR ALL
  USING (bucket_id = 'user-recordings' AND auth.uid()::TEXT = (storage.foldername(name))[1])
  WITH CHECK (bucket_id = 'user-recordings' AND auth.uid()::TEXT = (storage.foldername(name))[1]);
