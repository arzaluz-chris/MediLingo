-- ============================================================================
-- MediLingo — course pathway targeting
--
-- profiles.primary_goal (enarm/research/patient_care/remote_work/
-- travel_medicine/usmle/general) is collected at onboarding but never used to
-- pick content — the app serves the first published course to everyone. This
-- column lets a course declare which goals it serves; iOS fetchCourses() filters
-- on it (a course is shown if its target_goals overlaps the user's goal, or it
-- is a 'general' course). Empty array = untargeted (treated as general).
-- Rollback: ALTER TABLE public.courses DROP COLUMN target_goals;
-- ============================================================================
ALTER TABLE public.courses
  ADD COLUMN IF NOT EXISTS target_goals TEXT[] NOT NULL DEFAULT '{}';

COMMENT ON COLUMN public.courses.target_goals IS
  'primary_goal values this course targets; empty = untargeted/general. Consumed by iOS fetchCourses().';
