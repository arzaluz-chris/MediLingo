-- ============================================================================
-- MediLingo — Push tokens, course certificates, referrals
-- Rollback: DROP TABLE push_tokens, certificates, referrals;
--           DROP FUNCTION issue_certificate, redeem_referral;
--
-- push_tokens: APNs/FCM device registrations for future remote push.
-- certificates: issued on course completion (server-side function).
-- referrals: invite codes; both parties get gems when the invitee finishes
-- their first lesson (docs/GAMIFICATION.md § Referrals).
-- ============================================================================

-- ----------------------------------------------------------------------------
-- PUSH TOKENS
-- ----------------------------------------------------------------------------
CREATE TABLE push_tokens (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  token         TEXT NOT NULL,
  platform      TEXT NOT NULL CHECK (platform IN ('ios', 'android', 'web')),
  device_name   TEXT,
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, token)
);
CREATE INDEX idx_push_tokens_user ON push_tokens(user_id) WHERE is_active;

ALTER TABLE push_tokens ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Own push tokens" ON push_tokens FOR ALL
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE TRIGGER trg_push_tokens_updated_at BEFORE UPDATE ON push_tokens
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ----------------------------------------------------------------------------
-- CERTIFICATES
-- ----------------------------------------------------------------------------
CREATE TABLE certificates (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  course_id     UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  serial        TEXT NOT NULL UNIQUE DEFAULT ENCODE(extensions.gen_random_bytes(8), 'hex'),
  issued_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, course_id)
);
CREATE INDEX idx_certificates_user ON certificates(user_id);

ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;
-- Read-only for the owner; issuance goes through issue_certificate().
CREATE POLICY "Own certificates readable" ON certificates FOR SELECT
  USING (auth.uid() = user_id);

-- Issue a certificate for a completed course. Verifies completion server-side:
-- every published lesson of the course must have a completed user_progress row.
CREATE OR REPLACE FUNCTION public.issue_certificate(p_course_id UUID)
RETURNS public.certificates
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_uid UUID := auth.uid();
  v_total INT;
  v_done INT;
  v_cert public.certificates;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'not authenticated'; END IF;

  SELECT COUNT(*) INTO v_total
  FROM public.lessons l
  JOIN public.modules m ON m.id = l.module_id
  WHERE m.course_id = p_course_id AND l.is_published AND m.is_published;

  IF v_total = 0 THEN RAISE EXCEPTION 'course has no published lessons'; END IF;

  SELECT COUNT(*) INTO v_done
  FROM public.user_progress up
  JOIN public.lessons l ON l.id = up.entity_id
  JOIN public.modules m ON m.id = l.module_id
  WHERE up.user_id = v_uid AND up.entity_type = 'lesson'
    AND up.status = 'completed'
    AND m.course_id = p_course_id AND l.is_published AND m.is_published;

  IF v_done < v_total THEN
    RAISE EXCEPTION 'course not complete: % of % lessons', v_done, v_total;
  END IF;

  INSERT INTO public.certificates (user_id, course_id)
  VALUES (v_uid, p_course_id)
  ON CONFLICT (user_id, course_id) DO UPDATE SET issued_at = certificates.issued_at
  RETURNING * INTO v_cert;

  -- Mark the course itself completed (feeds course_completed achievements).
  INSERT INTO public.user_progress (user_id, entity_type, entity_id, status, score, xp_earned, completed_at)
  VALUES (v_uid, 'course', p_course_id, 'completed', 1.0, 0, NOW())
  ON CONFLICT (user_id, entity_type, entity_id) DO NOTHING;

  RETURN v_cert;
END;
$$;

REVOKE ALL ON FUNCTION public.issue_certificate(UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.issue_certificate(UUID) TO authenticated;

-- ----------------------------------------------------------------------------
-- REFERRALS
-- ----------------------------------------------------------------------------
CREATE TABLE referrals (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  referrer_id   UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  referee_id    UUID REFERENCES profiles(id) ON DELETE SET NULL,
  code          TEXT NOT NULL UNIQUE,
  status        TEXT NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending', 'redeemed', 'rewarded')),
  redeemed_at   TIMESTAMPTZ,
  rewarded_at   TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_referrals_referrer ON referrals(referrer_id);
CREATE INDEX idx_referrals_code ON referrals(code);

ALTER TABLE referrals ENABLE ROW LEVEL SECURITY;
-- Each party can read the rows they participate in; writes go through RPCs.
CREATE POLICY "Own referrals readable" ON referrals FOR SELECT
  USING (auth.uid() = referrer_id OR auth.uid() = referee_id);

-- Get (or lazily create) the caller's shareable referral code.
CREATE OR REPLACE FUNCTION public.get_referral_code()
RETURNS TEXT
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_uid UUID := auth.uid();
  v_code TEXT;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'not authenticated'; END IF;

  SELECT code INTO v_code FROM public.referrals
  WHERE referrer_id = v_uid AND referee_id IS NULL AND status = 'pending'
  LIMIT 1;
  IF FOUND THEN RETURN v_code; END IF;

  v_code := UPPER(ENCODE(extensions.gen_random_bytes(4), 'hex'));
  INSERT INTO public.referrals (referrer_id, code) VALUES (v_uid, v_code);
  RETURN v_code;
END;
$$;

-- Redeem a code (called once by the new user). Both parties get 100 gems.
CREATE OR REPLACE FUNCTION public.redeem_referral(p_code TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_uid UUID := auth.uid();
  v_ref public.referrals;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'not authenticated'; END IF;

  SELECT * INTO v_ref FROM public.referrals
  WHERE code = UPPER(p_code) AND status = 'pending' AND referee_id IS NULL
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'invalid or used code'; END IF;
  IF v_ref.referrer_id = v_uid THEN RAISE EXCEPTION 'cannot redeem own code'; END IF;

  -- One redemption per referee, ever.
  IF EXISTS (SELECT 1 FROM public.referrals WHERE referee_id = v_uid) THEN
    RAISE EXCEPTION 'referral already redeemed';
  END IF;

  UPDATE public.referrals SET
    referee_id = v_uid,
    status = 'rewarded',
    redeemed_at = NOW(),
    rewarded_at = NOW()
  WHERE id = v_ref.id;

  UPDATE public.user_stats SET gems = gems + 100, updated_at = NOW()
  WHERE user_id IN (v_uid, v_ref.referrer_id);

  RETURN TRUE;
END;
$$;

REVOKE ALL ON FUNCTION public.get_referral_code() FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.redeem_referral(TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_referral_code() TO authenticated;
GRANT EXECUTE ON FUNCTION public.redeem_referral(TEXT) TO authenticated;
