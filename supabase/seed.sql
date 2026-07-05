-- ============================================================================
-- MediLingo — Dev seed (loaded by `supabase db reset`)
-- Minimal published content so the admin CMS and iOS app render real data.
-- Not for production. Fixed UUIDs keep relationships readable.
-- ============================================================================

-- Course ---------------------------------------------------------------------
INSERT INTO courses (id, slug, title, description, short_desc, color_hex, difficulty, category, target_role, estimated_hours, sort_order, is_published, is_featured, published_at)
VALUES (
  '11111111-1111-1111-1111-111111111111',
  'medical-english-essentials',
  'Medical English Essentials',
  'Core medical English for Spanish-speaking healthcare professionals. Foundations of clinical communication.',
  'Foundations of clinical English.',
  '#4F46E5', 'beginner', 'general', ARRAY['student','doctor','nurse'], 10, 0, TRUE, TRUE, NOW()
) ON CONFLICT (id) DO NOTHING;

-- Module ---------------------------------------------------------------------
INSERT INTO modules (id, course_id, slug, title, description, sort_order, is_published)
VALUES (
  '22222222-2222-2222-2222-222222222222',
  '11111111-1111-1111-1111-111111111111',
  'patient-intake',
  'Patient Intake',
  'Greeting patients, taking history, and basic vitals vocabulary.',
  0, TRUE
) ON CONFLICT (id) DO NOTHING;

-- Lessons --------------------------------------------------------------------
INSERT INTO lessons (id, module_id, slug, title, description, lesson_type, difficulty, estimated_minutes, xp_reward, sort_order, is_published, intro_text, completion_text)
VALUES
  ('33333333-3333-3333-3333-333333333331', '22222222-2222-2222-2222-222222222222', 'greetings',
   'Greeting the Patient', 'Introduce yourself and put the patient at ease.', 'standard', 'beginner', 5, 50, 0, TRUE,
   'Learn how to greet a patient professionally.', 'Great work! You can now greet patients in English.'),
  ('33333333-3333-3333-3333-333333333332', '22222222-2222-2222-2222-222222222222', 'chief-complaint',
   'The Chief Complaint', 'Ask what brings the patient in today.', 'standard', 'beginner', 6, 50, 1, TRUE,
   'Learn to ask about the chief complaint.', 'Well done! You can now open a consultation.')
ON CONFLICT (id) DO NOTHING;

-- Exercises for lesson 1 (across several MVP types) --------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, xp_reward, sort_order, metadata, is_published)
VALUES
  ('44444444-0000-0000-0000-000000000001', '33333333-3333-3333-3333-333333333331', 'multiple_choice',
   'Which is the most professional greeting for a new patient?', 'Hello, I''m Dr. Smith. How can I help you today?',
   '"How can I help you today?" is a warm, open-ended opener.', 'Es un saludo cálido y abierto.', 10, 0,
   '{}'::jsonb, TRUE),
  ('44444444-0000-0000-0000-000000000002', '33333333-3333-3333-3333-333333333331', 'translation',
   'Translate to English: "¿Cómo se siente hoy?"', 'How are you feeling today?',
   'Present continuous is natural here.', 'El presente continuo es natural aquí.', 10, 1,
   '{"source_lang":"es","target_lang":"en"}'::jsonb, TRUE),
  ('44444444-0000-0000-0000-000000000003', '33333333-3333-3333-3333-333333333331', 'fill_in_blank',
   'Complete: "Please have a ____ and make yourself comfortable."', 'seat',
   '"Have a seat" invites the patient to sit.', '"Have a seat" invita al paciente a sentarse.', 10, 2,
   '{"blanks":["seat"]}'::jsonb, TRUE),
  ('44444444-0000-0000-0000-000000000004', '33333333-3333-3333-3333-333333333331', 'flashcard',
   'consultation', 'consulta',
   'A meeting between a patient and a clinician.', 'Reunión entre paciente y clínico.', 10, 3,
   '{"front":"consultation","back":"consulta","phonetic":"/ˌkɒn.səlˈteɪ.ʃən/"}'::jsonb, TRUE)
ON CONFLICT (id) DO NOTHING;

-- Multiple-choice options for exercise 1 -------------------------------------
INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('44444444-0000-0000-0000-000000000001', 'Hello, I''m Dr. Smith. How can I help you today?', TRUE, 0),
  ('44444444-0000-0000-0000-000000000001', 'What do you want?', FALSE, 1),
  ('44444444-0000-0000-0000-000000000001', 'Next!', FALSE, 2),
  ('44444444-0000-0000-0000-000000000001', 'Sit down and tell me your problem.', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Vocabulary -----------------------------------------------------------------
INSERT INTO vocabulary (id, word, phonetic, translation_es, definition_en, definition_es, example_en, example_es, category, difficulty, tags, is_published)
VALUES
  ('55555555-0000-0000-0000-000000000001', 'consultation', '/ˌkɒn.səlˈteɪ.ʃən/', 'consulta',
   'A meeting between a patient and a clinician.', 'Reunión entre un paciente y un clínico.',
   'The consultation lasted twenty minutes.', 'La consulta duró veinte minutos.', 'general', 'beginner', ARRAY['intake'], TRUE),
  ('55555555-0000-0000-0000-000000000002', 'chief complaint', '/tʃiːf kəmˈpleɪnt/', 'motivo de consulta',
   'The main reason a patient seeks care.', 'La razón principal por la que un paciente busca atención.',
   'Her chief complaint was chest pain.', 'Su motivo de consulta fue dolor torácico.', 'general', 'beginner', ARRAY['intake'], TRUE)
ON CONFLICT (id) DO NOTHING;

-- Link vocabulary to lesson 1 ------------------------------------------------
INSERT INTO lesson_vocabulary (lesson_id, vocabulary_id, sort_order)
VALUES
  ('33333333-3333-3333-3333-333333333331', '55555555-0000-0000-0000-000000000001', 0),
  ('33333333-3333-3333-3333-333333333331', '55555555-0000-0000-0000-000000000002', 1)
ON CONFLICT DO NOTHING;
