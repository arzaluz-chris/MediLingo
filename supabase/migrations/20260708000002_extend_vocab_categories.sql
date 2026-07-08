-- ============================================================================
-- MediLingo — extend vocabulary.category for specialty pathways
--
-- The Clinical English by Specialty pathway (20260709000000) adds vocabulary in
-- pulmonology, gastroenterology and neurology — specialties the original
-- vocabulary_category_check did not allow. Widen the CHECK to include them so
-- those seeds load. Existing values are preserved; this only adds.
-- Rollback: restore the prior CHECK (drop these three values) — only safe if no
-- rows use them.
-- ============================================================================
ALTER TABLE public.vocabulary DROP CONSTRAINT IF EXISTS vocabulary_category_check;
ALTER TABLE public.vocabulary ADD CONSTRAINT vocabulary_category_check
  CHECK (category IN (
    'general', 'anatomy', 'physiology', 'pathology', 'pharmacology',
    'surgery', 'emergency', 'cardiology', 'pediatrics', 'ob_gyn',
    'psychiatry', 'dermatology', 'radiology', 'laboratory',
    'nursing', 'abbreviation', 'latin_abbreviation', 'billing',
    'insurance', 'equipment', 'procedures',
    'pulmonology', 'gastroenterology', 'neurology'
  ));
