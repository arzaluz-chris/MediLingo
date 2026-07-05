-- ============================================================================
-- MediLingo — Harden SECURITY DEFINER functions
-- Rollback: restore prior CREATE OR REPLACE bodies from 20260704000002.
--
-- Bug: handle_new_user() (SECURITY DEFINER) referenced tables unqualified. When
-- GoTrue runs it as `supabase_auth_admin`, search_path excludes `public`, so the
-- INSERT failed with "relation \"profiles\" does not exist" → every signup 500'd.
-- Fix: pin `search_path = ''` and fully-qualify every object (security best
-- practice for SECURITY DEFINER). Same fix applied to update_streak/refill_hearts.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, display_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1))
  );
  INSERT INTO public.user_settings   (user_id) VALUES (NEW.id);
  INSERT INTO public.user_stats      (user_id) VALUES (NEW.id);
  INSERT INTO public.user_onboarding (user_id) VALUES (NEW.id);
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_streak()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  today DATE := CURRENT_DATE;
  last_date DATE;
BEGIN
  SELECT streak_last_date INTO last_date
  FROM public.user_stats WHERE user_id = NEW.user_id;

  IF last_date IS NULL OR last_date < today - 1 THEN
    UPDATE public.user_stats SET
      current_streak = 1,
      streak_last_date = today,
      updated_at = NOW()
    WHERE user_id = NEW.user_id;
  ELSIF last_date = today - 1 THEN
    UPDATE public.user_stats SET
      current_streak = current_streak + 1,
      longest_streak = GREATEST(longest_streak, current_streak + 1),
      streak_last_date = today,
      updated_at = NOW()
    WHERE user_id = NEW.user_id;
  END IF;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.refill_hearts(p_user_id UUID)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
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
  FROM public.user_stats WHERE user_id = p_user_id;

  IF current_hearts >= max_hearts THEN
    RETURN current_hearts;
  END IF;

  hours_elapsed := EXTRACT(EPOCH FROM (NOW() - last_refill)) / 3600;
  hearts_to_add := hours_elapsed / 4;

  IF hearts_to_add > 0 THEN
    new_hearts := LEAST(current_hearts + hearts_to_add, max_hearts);
    UPDATE public.user_stats SET
      hearts = new_hearts,
      hearts_last_refill = NOW(),
      updated_at = NOW()
    WHERE user_id = p_user_id;
    RETURN new_hearts;
  END IF;

  RETURN current_hearts;
END;
$$;
