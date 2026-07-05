-- ============================================================================
-- MediLingo — Functions & Triggers
-- Rollback: DROP TRIGGER / DROP FUNCTION for each object below.
-- ============================================================================

-- Auto-create profile + child rows on signup ---------------------------------
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, email, display_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1))
  );
  INSERT INTO user_settings   (user_id) VALUES (NEW.id);
  INSERT INTO user_stats      (user_id) VALUES (NEW.id);
  INSERT INTO user_onboarding (user_id) VALUES (NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Calculate level from XP: XP_required(n) = floor(50 * n^1.5) -----------------
CREATE OR REPLACE FUNCTION calculate_level(total_xp BIGINT)
RETURNS INT AS $$
BEGIN
  RETURN GREATEST(1, FLOOR(POWER(total_xp::FLOAT / 50.0, 2.0/3.0)));
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Streak update, called after XP-bearing activity ----------------------------
CREATE OR REPLACE FUNCTION update_streak()
RETURNS TRIGGER AS $$
DECLARE
  today DATE := CURRENT_DATE;
  last_date DATE;
BEGIN
  SELECT streak_last_date INTO last_date FROM user_stats WHERE user_id = NEW.user_id;

  IF last_date IS NULL OR last_date < today - 1 THEN
    UPDATE user_stats SET
      current_streak = 1,
      streak_last_date = today,
      updated_at = NOW()
    WHERE user_id = NEW.user_id;
  ELSIF last_date = today - 1 THEN
    UPDATE user_stats SET
      current_streak = current_streak + 1,
      longest_streak = GREATEST(longest_streak, current_streak + 1),
      streak_last_date = today,
      updated_at = NOW()
    WHERE user_id = NEW.user_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Heart refill: 1 heart every 4 hours up to hearts_max -----------------------
CREATE OR REPLACE FUNCTION refill_hearts(p_user_id UUID)
RETURNS INT AS $$
DECLARE
  current_hearts INT;
  max_hearts INT;
  last_refill TIMESTAMPTZ;
  hours_elapsed INT;
  hearts_to_add INT;
  new_hearts INT;
BEGIN
  SELECT hearts, hearts_max, hearts_last_refill
  INTO current_hearts, max_hearts, last_refill
  FROM user_stats WHERE user_id = p_user_id;

  IF current_hearts >= max_hearts THEN
    RETURN current_hearts;
  END IF;

  hours_elapsed := EXTRACT(EPOCH FROM (NOW() - last_refill)) / 3600;
  hearts_to_add := hours_elapsed / 4;

  IF hearts_to_add > 0 THEN
    new_hearts := LEAST(current_hearts + hearts_to_add, max_hearts);
    UPDATE user_stats SET
      hearts = new_hearts,
      hearts_last_refill = NOW(),
      updated_at = NOW()
    WHERE user_id = p_user_id;
    RETURN new_hearts;
  END IF;

  RETURN current_hearts;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Generic updated_at touch ----------------------------------------------------
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_profiles_updated_at          BEFORE UPDATE ON profiles           FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_user_settings_updated_at     BEFORE UPDATE ON user_settings      FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_courses_updated_at           BEFORE UPDATE ON courses            FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_modules_updated_at           BEFORE UPDATE ON modules            FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_lessons_updated_at           BEFORE UPDATE ON lessons            FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_exercises_updated_at         BEFORE UPDATE ON exercises          FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_vocabulary_updated_at        BEFORE UPDATE ON vocabulary         FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_vocab_mastery_updated_at     BEFORE UPDATE ON vocabulary_mastery FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_user_stats_updated_at        BEFORE UPDATE ON user_stats         FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_subscriptions_updated_at     BEFORE UPDATE ON subscriptions      FOR EACH ROW EXECUTE FUNCTION set_updated_at();
