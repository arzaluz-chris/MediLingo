-- ============================================================================
-- MediLingo — Streak on lesson progress
-- Rollback: DROP TRIGGER on_progress_streak ON user_progress;
-- Completing (or updating) a lesson's progress row bumps the daily streak via
-- the existing update_streak() function (20260704000002).
-- ============================================================================

CREATE TRIGGER on_progress_streak
  AFTER INSERT OR UPDATE ON user_progress
  FOR EACH ROW EXECUTE FUNCTION update_streak();
