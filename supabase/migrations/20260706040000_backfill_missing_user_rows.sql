-- ============================================================================
-- MediLingo — Backfill profile/stats/settings/onboarding for pre-trigger users
--
-- handle_new_user() only fires on NEW auth.users inserts. Any account created
-- before the trigger existed (e.g. during early hosted testing) has no
-- public.profiles / user_stats / user_settings / user_onboarding row, which
-- breaks join_league() (null tier) and stats reads. This backfill is
-- idempotent — safe to re-run; it only inserts what is missing.
-- ============================================================================

INSERT INTO public.profiles (id, email, display_name)
SELECT u.id, u.email,
       COALESCE(u.raw_user_meta_data->>'full_name', split_part(u.email, '@', 1))
FROM auth.users u
LEFT JOIN public.profiles p ON p.id = u.id
WHERE p.id IS NULL;

INSERT INTO public.user_settings (user_id)
SELECT u.id FROM auth.users u
LEFT JOIN public.user_settings s ON s.user_id = u.id
WHERE s.user_id IS NULL;

INSERT INTO public.user_stats (user_id)
SELECT u.id FROM auth.users u
LEFT JOIN public.user_stats st ON st.user_id = u.id
WHERE st.user_id IS NULL;

INSERT INTO public.user_onboarding (user_id)
SELECT u.id FROM auth.users u
LEFT JOIN public.user_onboarding o ON o.user_id = u.id
WHERE o.user_id IS NULL;
