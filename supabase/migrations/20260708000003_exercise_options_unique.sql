-- ============================================================================
-- MediLingo — idempotent exercise_options seeding
--
-- exercise_options rows are seeded without an explicit id (PK defaults to
-- gen_random_uuid()), so the `ON CONFLICT DO NOTHING` in content seeds never had
-- a constraint to fire on: re-applying a content migration silently DUPLICATED
-- every option row. A given exercise never has two options at the same
-- sort_order, so a UNIQUE (exercise_id, sort_order) is both correct and the
-- conflict target that makes those seeds idempotent (matching rows differ by
-- sort_order too, so grouped pairs are unaffected).
-- Existing content (Essentials) already satisfies this — verified: 0 dup pairs.
-- Rollback: ALTER TABLE public.exercise_options DROP CONSTRAINT exercise_options_exercise_sort_uniq;
-- ============================================================================
ALTER TABLE public.exercise_options DROP CONSTRAINT IF EXISTS exercise_options_exercise_sort_uniq;
ALTER TABLE public.exercise_options
  ADD CONSTRAINT exercise_options_exercise_sort_uniq UNIQUE (exercise_id, sort_order);
