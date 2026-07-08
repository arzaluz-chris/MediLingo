-- ============================================================================
-- MediLingo — Load "Medical English Essentials" course into the DB (migration)
--
-- The course (10 modules / ~50 lessons / ~210 exercises / ~95 vocab) lived only
-- in supabase/seed.sql + supabase/seed/*.sql, which run ONLY on `supabase db
-- reset` (local). The hosted project applies migrations, not seeds, so this
-- content never reached hosted and the admin CMS showed nothing. This migration
-- loads it into every environment. Idempotent (ON CONFLICT DO NOTHING, fixed
-- UUIDs); safe to re-run. All exercise metadata conforms to shared/schemas/
-- (verified by scripts/validate-content.mjs). Content is AI-drafted — a
-- physician must validate before it is considered production-ready; published
-- flags are preserved as authored.
-- Rollback: DELETE FROM courses WHERE id = '11111111-1111-1111-1111-111111111111';
--           (cascades to modules/lessons/exercises/options/lesson_vocabulary)
-- ============================================================================


-- ---- from seed.sql ----
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
   '{"source_language":"es","target_language":"en","source_text":"¿Cómo se siente hoy?","acceptable_translations":["How are you feeling today?","How do you feel today?"]}'::jsonb, TRUE),
  ('44444444-0000-0000-0000-000000000003', '33333333-3333-3333-3333-333333333331', 'fill_in_blank',
   'Complete: "Please have a ____ and make yourself comfortable."', 'seat',
   '"Have a seat" invites the patient to sit.', '"Have a seat" invita al paciente a sentarse.', 10, 2,
   '{"acceptable_answers":["seat"]}'::jsonb, TRUE),
  ('44444444-0000-0000-0000-000000000004', '33333333-3333-3333-3333-333333333331', 'flashcard',
   'consultation', 'consulta',
   'A meeting between a patient and a clinician.', 'Reunión entre paciente y clínico.', 10, 3,
   '{"front":{"text":"consultation","subtext":"/ˌkɒn.səlˈteɪ.ʃən/"},"back":{"text":"consulta","translation":"consulta","example":"The consultation lasted twenty minutes."}}'::jsonb, TRUE)
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

-- ---- from 01_modules_1_3.sql ----
-- ============================================================================
-- MediLingo — Seed: Course "Medical English Essentials" — Modules 1–3
-- AI-drafted content — pending physician validation (content pipeline: AI draft → physician validates → publish).
--
-- Course: 11111111-1111-1111-1111-111111111111 (medical-english-essentials)
-- Module 1 (existing): 22222222-2222-2222-2222-222222222222 (patient-intake) — adds lessons sort_order 2–4
-- Module 2 (new): anatomy-body-systems — 5 lessons
-- Module 3 (new): symptoms-pain — 5 lessons
-- All UUIDs minted here start with 'aaaa' (collision avoidance with parallel authors).
-- ============================================================================

-- Modules --------------------------------------------------------------------
INSERT INTO modules (id, course_id, slug, title, description, sort_order, is_published)
VALUES
  ('aaaa0000-0000-4000-8000-000000000002', '11111111-1111-1111-1111-111111111111', 'anatomy-body-systems',
   'Anatomy & Body Systems', 'Name body parts, organs, and body systems with confidence during physical examinations.', 1, TRUE),
  ('aaaa0000-0000-4000-8000-000000000003', '11111111-1111-1111-1111-111111111111', 'symptoms-pain',
   'Describing Symptoms & Pain', 'Understand and document how patients describe symptoms, pain quality, severity, and timing.', 2, TRUE)
ON CONFLICT (id) DO NOTHING;

-- Lessons --------------------------------------------------------------------
-- Module 1 additions (sort_order 2–4)
INSERT INTO lessons (id, module_id, slug, title, description, lesson_type, difficulty, estimated_minutes, xp_reward, sort_order, is_published, intro_text, completion_text)
VALUES
  ('aaaa1111-0000-4000-8000-000000000103', '22222222-2222-2222-2222-222222222222', 'vital-signs-measurements',
   'Vital Signs & Measurements', 'Take and report vital signs: blood pressure, heart rate, temperature, and oxygen saturation.', 'standard', 'beginner', 6, 50, 2, TRUE,
   'Learn the English you need to take vital signs and explain each measurement to your patient.',
   'Excellent! You can now take vital signs and report them in English.'),
  ('aaaa1111-0000-4000-8000-000000000104', '22222222-2222-2222-2222-222222222222', 'registration-forms',
   'Registration & Forms', 'Guide patients through registration, insurance information, and consent forms.', 'standard', 'beginner', 6, 50, 3, TRUE,
   'Learn how to request documents and help patients complete registration forms.',
   'Well done! You can now handle patient registration in English.'),
  ('aaaa1111-0000-4000-8000-000000000105', '22222222-2222-2222-2222-222222222222', 'closing-the-visit',
   'Closing the Visit', 'Wrap up the consultation: instructions, prescriptions, and follow-up appointments.', 'standard', 'beginner', 5, 50, 4, TRUE,
   'Learn how to close a visit clearly so your patient leaves knowing exactly what to do next.',
   'Great work! You can now close a patient visit professionally in English.')
ON CONFLICT (id) DO NOTHING;

-- Module 2 lessons (sort_order 0–4)
INSERT INTO lessons (id, module_id, slug, title, description, lesson_type, difficulty, estimated_minutes, xp_reward, sort_order, is_published, intro_text, completion_text)
VALUES
  ('aaaa1111-0000-4000-8000-000000000201', 'aaaa0000-0000-4000-8000-000000000002', 'head-and-neck',
   'Head & Neck', 'Name the structures of the head and neck used in everyday examinations.', 'standard', 'beginner', 6, 50, 0, TRUE,
   'Learn the English names for the head and neck structures you examine every day.',
   'Excellent! You can now name head and neck structures in English.'),
  ('aaaa1111-0000-4000-8000-000000000202', 'aaaa0000-0000-4000-8000-000000000002', 'chest-heart-lungs',
   'Chest, Heart & Lungs', 'Vocabulary for the thorax, cardiovascular system, and respiratory system.', 'standard', 'beginner', 7, 50, 1, TRUE,
   'Learn the vocabulary of the chest, heart, and lungs for cardiopulmonary exams.',
   'Well done! You can now discuss the chest, heart, and lungs in English.'),
  ('aaaa1111-0000-4000-8000-000000000203', 'aaaa0000-0000-4000-8000-000000000002', 'abdomen-digestive',
   'Abdomen & Digestive System', 'Organs of the abdomen and the digestive tract, from esophagus to colon.', 'standard', 'beginner', 7, 50, 2, TRUE,
   'Learn the English names of the abdominal organs and the digestive system.',
   'Great job! You can now name abdominal and digestive structures in English.'),
  ('aaaa1111-0000-4000-8000-000000000204', 'aaaa0000-0000-4000-8000-000000000002', 'muscles-bones-limbs',
   'Muscles, Bones & Limbs', 'The musculoskeletal system: bones, joints, muscles, and the extremities.', 'standard', 'beginner', 7, 50, 3, TRUE,
   'Learn musculoskeletal vocabulary: bones, joints, and the arms and legs.',
   'Excellent! You can now describe the musculoskeletal system in English.'),
  ('aaaa1111-0000-4000-8000-000000000205', 'aaaa0000-0000-4000-8000-000000000002', 'anatomy-review',
   'Anatomy Review', 'Review and consolidate the anatomy vocabulary from this module.', 'review', 'beginner', 5, 50, 4, TRUE,
   'Time to review! Consolidate everything you learned about anatomy and body systems.',
   'Outstanding! You have mastered the core anatomy vocabulary of this module.')
ON CONFLICT (id) DO NOTHING;

-- Module 3 lessons (sort_order 0–4)
INSERT INTO lessons (id, module_id, slug, title, description, lesson_type, difficulty, estimated_minutes, xp_reward, sort_order, is_published, intro_text, completion_text)
VALUES
  ('aaaa1111-0000-4000-8000-000000000301', 'aaaa0000-0000-4000-8000-000000000003', 'describing-pain',
   'Describing Pain', 'Pain quality vocabulary: sharp, dull, burning, throbbing, radiating, and more.', 'standard', 'intermediate', 7, 50, 0, TRUE,
   'Learn how English-speaking patients describe pain quality, and how to ask about it.',
   'Excellent! You can now understand and document pain descriptions in English.'),
  ('aaaa1111-0000-4000-8000-000000000302', 'aaaa0000-0000-4000-8000-000000000003', 'pain-scales-opqrst',
   'Pain Scales & OPQRST', 'Assess pain systematically: onset, provocation, quality, radiation, severity, timing.', 'standard', 'intermediate', 8, 50, 1, TRUE,
   'Learn to run a structured pain assessment in English using scales and OPQRST questions.',
   'Well done! You can now perform a structured pain assessment in English.'),
  ('aaaa1111-0000-4000-8000-000000000303', 'aaaa0000-0000-4000-8000-000000000003', 'common-symptoms',
   'Common Symptoms', 'Recognize and ask about nausea, dizziness, fatigue, rash, swelling, and other frequent complaints.', 'standard', 'intermediate', 7, 50, 2, TRUE,
   'Learn the most frequent symptoms patients report and how to ask about each one.',
   'Great work! You can now discuss common symptoms with your patients in English.'),
  ('aaaa1111-0000-4000-8000-000000000304', 'aaaa0000-0000-4000-8000-000000000003', 'onset-duration-frequency',
   'Onset, Duration & Frequency', 'Ask when symptoms started, how long they last, and how often they occur.', 'standard', 'intermediate', 7, 50, 3, TRUE,
   'Learn to ask about the timing of symptoms: onset, duration, and frequency.',
   'Excellent! You can now take a precise symptom timeline in English.'),
  ('aaaa1111-0000-4000-8000-000000000305', 'aaaa0000-0000-4000-8000-000000000003', 'symptoms-review',
   'Symptoms Review', 'Review and consolidate the symptom and pain vocabulary from this module.', 'review', 'intermediate', 6, 50, 4, TRUE,
   'Time to review! Bring together everything you learned about symptoms and pain.',
   'Outstanding! You have mastered describing symptoms and pain in English.')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- Exercises — Module 1 additions
-- ============================================================================

-- Lesson 1.3: Vital Signs & Measurements --------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('aaaa2222-0000-4000-8000-000000010301', 'aaaa1111-0000-4000-8000-000000000103', 'multiple_choice',
   'You need to measure the patient''s oxygen saturation. Which device do you ask for?', 'A pulse oximeter',
   'A pulse oximeter clips onto the finger and measures oxygen saturation (SpO2).', 'El oxímetro de pulso se coloca en el dedo y mide la saturación de oxígeno (SpO2).', 'beginner', 10, 0,
   '{"shuffle_options": true}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000010302', 'aaaa1111-0000-4000-8000-000000000103', 'translation',
   'Translate to English: "Voy a tomarle la presión arterial."', 'I am going to take your blood pressure.',
   '"Take your blood pressure" is the standard collocation; "measure" is also acceptable.', '"Take your blood pressure" es la colocación estándar; "measure" también es aceptable.', 'beginner', 10, 1,
   '{"source_language":"es","target_language":"en","source_text":"Voy a tomarle la presión arterial.","acceptable_translations":["I am going to take your blood pressure.","I''m going to take your blood pressure.","I am going to measure your blood pressure.","I''m going to measure your blood pressure."],"key_terms":["blood pressure"]}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000010303', 'aaaa1111-0000-4000-8000-000000000103', 'fill_in_blank',
   'Complete: "Your heart ____ is 72 beats per minute."', 'rate',
   '"Heart rate" is the number of heartbeats per minute.', '"Heart rate" (frecuencia cardíaca) es el número de latidos por minuto.', 'beginner', 10, 2,
   '{"acceptable_answers":["rate"],"case_sensitive":false,"blank_position":"inline","word_bank":["rate","pressure","level","rhythm"]}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000010304', 'aaaa1111-0000-4000-8000-000000000103', 'matching',
   'Match each English term with its Spanish translation.', 'blood pressure = presión arterial; heart rate = frecuencia cardíaca; weight = peso; fever = fiebre',
   'These are the core vital signs terms you will use at every intake.', 'Estos son los términos básicos de signos vitales que usarás en cada consulta.', 'beginner', 10, 3,
   '{"columns": 2}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000010305', 'aaaa1111-0000-4000-8000-000000000103', 'flashcard',
   'vital signs', 'signos vitales',
   'The basic body measurements: blood pressure, heart rate, respiratory rate, and temperature.', 'Las mediciones corporales básicas: presión arterial, frecuencia cardíaca, frecuencia respiratoria y temperatura.', 'beginner', 10, 4,
   '{"front":{"text":"vital signs","subtext":"/ˈvaɪ.təl saɪnz/"},"back":{"text":"signos vitales","explanation":"Blood pressure, heart rate, respiratory rate, and temperature.","example":"Your vital signs are all within normal limits."},"show_pronunciation":true}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000010306', 'aaaa1111-0000-4000-8000-000000000103', 'pronunciation',
   'Say this phrase aloud: "Please roll up your sleeve."', 'Please roll up your sleeve.',
   'You say this before taking blood pressure. Link the words: "roll-up-your-sleeve."', 'Se dice antes de tomar la presión arterial. Une las palabras: "roll-up-your-sleeve."', 'beginner', 10, 5,
   '{"word":"Please roll up your sleeve.","phonetic":"/pliːz roʊl ʌp jʊr sliːv/","minimum_score":60,"common_mistakes":[{"mistake":"esleeve","correction":"sleeve — do not add an initial e-sound"}],"definition_es":"Por favor, súbase la manga."}'::jsonb, TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order, match_pair_id)
VALUES
  ('aaaa2222-0000-4000-8000-000000010301', 'A pulse oximeter', TRUE, 0, NULL),
  ('aaaa2222-0000-4000-8000-000000010301', 'A thermometer', FALSE, 1, NULL),
  ('aaaa2222-0000-4000-8000-000000010301', 'A blood pressure cuff', FALSE, 2, NULL),
  ('aaaa2222-0000-4000-8000-000000010301', 'A scale', FALSE, 3, NULL),
  ('aaaa2222-0000-4000-8000-000000010304', 'blood pressure', TRUE, 0, 'p1'),
  ('aaaa2222-0000-4000-8000-000000010304', 'presión arterial', TRUE, 1, 'p1'),
  ('aaaa2222-0000-4000-8000-000000010304', 'heart rate', TRUE, 2, 'p2'),
  ('aaaa2222-0000-4000-8000-000000010304', 'frecuencia cardíaca', TRUE, 3, 'p2'),
  ('aaaa2222-0000-4000-8000-000000010304', 'weight', TRUE, 4, 'p3'),
  ('aaaa2222-0000-4000-8000-000000010304', 'peso', TRUE, 5, 'p3'),
  ('aaaa2222-0000-4000-8000-000000010304', 'fever', TRUE, 6, 'p4'),
  ('aaaa2222-0000-4000-8000-000000010304', 'fiebre', TRUE, 7, 'p4')
ON CONFLICT DO NOTHING;

-- Lesson 1.4: Registration & Forms --------------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('aaaa2222-0000-4000-8000-000000010401', 'aaaa1111-0000-4000-8000-000000000104', 'multiple_choice',
   'Which question correctly asks for the patient''s date of birth?', 'What is your date of birth?',
   '"What is your date of birth?" is the standard registration question.', '"What is your date of birth?" es la pregunta estándar en el registro.', 'beginner', 10, 0,
   '{"shuffle_options": true}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000010402', 'aaaa1111-0000-4000-8000-000000000104', 'typing',
   'Politely ask the patient for their insurance card, in English.', 'May I see your insurance card, please?',
   '"May I..." is the most polite way to request a document at the front desk.', '"May I..." es la forma más cortés de pedir un documento en recepción.', 'beginner', 10, 1,
   '{"acceptable_answers":["May I see your insurance card, please?","May I see your insurance card?","Can I see your insurance card, please?","Could I see your insurance card, please?"],"case_sensitive":false,"max_length":100,"placeholder":"Type your question..."}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000010403', 'aaaa1111-0000-4000-8000-000000000104', 'fill_in_blank',
   'Complete: "Please sign the consent ____ at the bottom of the page."', 'form',
   'A "consent form" is the document a patient signs to authorize care.', 'El "consent form" (formulario de consentimiento) es el documento que el paciente firma para autorizar la atención.', 'beginner', 10, 2,
   '{"acceptable_answers":["form"],"case_sensitive":false,"blank_position":"inline","word_bank":["form","paper","card","file"]}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000010404', 'aaaa1111-0000-4000-8000-000000000104', 'sentence_ordering',
   'Put the words in order to make a polite instruction.', 'Please fill out this form in the waiting room.',
   '"Fill out" is the phrasal verb used for completing forms.', '"Fill out" es el verbo compuesto que se usa para llenar formularios.', 'beginner', 10, 3,
   '{"words":["Please","fill","out","this","form","in","the","waiting","room."],"extra_words":["fill","in"],"show_punctuation":true}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000010405', 'aaaa1111-0000-4000-8000-000000000104', 'matching',
   'Match each English term with its Spanish translation.', 'insurance card = tarjeta de seguro; copay = copago; signature = firma; appointment = cita',
   'Key registration vocabulary for the front desk.', 'Vocabulario clave de registro para la recepción.', 'beginner', 10, 4,
   '{"columns": 2}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000010406', 'aaaa1111-0000-4000-8000-000000000104', 'flashcard',
   'emergency contact', 'contacto de emergencia',
   'The person to call if something happens to the patient.', 'La persona a quien llamar si algo le sucede al paciente.', 'beginner', 10, 5,
   '{"front":{"text":"emergency contact","subtext":"/ɪˈmɜːr.dʒən.si ˈkɒn.tækt/"},"back":{"text":"contacto de emergencia","example":"Who should we list as your emergency contact?"},"show_pronunciation":true}'::jsonb, TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order, match_pair_id)
VALUES
  ('aaaa2222-0000-4000-8000-000000010401', 'What is your date of birth?', TRUE, 0, NULL),
  ('aaaa2222-0000-4000-8000-000000010401', 'When are you born?', FALSE, 1, NULL),
  ('aaaa2222-0000-4000-8000-000000010401', 'What is your birthday date?', FALSE, 2, NULL),
  ('aaaa2222-0000-4000-8000-000000010401', 'How many years do you have?', FALSE, 3, NULL),
  ('aaaa2222-0000-4000-8000-000000010405', 'insurance card', TRUE, 0, 'p1'),
  ('aaaa2222-0000-4000-8000-000000010405', 'tarjeta de seguro', TRUE, 1, 'p1'),
  ('aaaa2222-0000-4000-8000-000000010405', 'copay', TRUE, 2, 'p2'),
  ('aaaa2222-0000-4000-8000-000000010405', 'copago', TRUE, 3, 'p2'),
  ('aaaa2222-0000-4000-8000-000000010405', 'signature', TRUE, 4, 'p3'),
  ('aaaa2222-0000-4000-8000-000000010405', 'firma', TRUE, 5, 'p3'),
  ('aaaa2222-0000-4000-8000-000000010405', 'appointment', TRUE, 6, 'p4'),
  ('aaaa2222-0000-4000-8000-000000010405', 'cita', TRUE, 7, 'p4')
ON CONFLICT DO NOTHING;

-- Lesson 1.5: Closing the Visit ------------------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('aaaa2222-0000-4000-8000-000000010501', 'aaaa1111-0000-4000-8000-000000000105', 'multiple_choice',
   'Which sentence best schedules a follow-up visit?', 'Let''s schedule a follow-up appointment in two weeks.',
   '"Follow-up appointment" is the standard term for a return visit.', '"Follow-up appointment" es el término estándar para una cita de control.', 'beginner', 10, 0,
   '{"shuffle_options": true}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000010502', 'aaaa1111-0000-4000-8000-000000000105', 'translation',
   'Translate to English: "Tome este medicamento dos veces al día con alimentos."', 'Take this medication twice a day with food.',
   '"Twice a day" is more natural than "two times per day" in patient instructions.', '"Twice a day" suena más natural que "two times per day" en indicaciones al paciente.', 'beginner', 10, 1,
   '{"source_language":"es","target_language":"en","source_text":"Tome este medicamento dos veces al día con alimentos.","acceptable_translations":["Take this medication twice a day with food.","Take this medicine twice a day with food.","Take this medication two times a day with food."],"key_terms":["twice a day","with food"]}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000010503', 'aaaa1111-0000-4000-8000-000000000105', 'fill_in_blank',
   'Complete: "I am sending your ____ to the pharmacy right now."', 'prescription',
   'A "prescription" is the written order for medication.', 'La "prescription" (receta) es la orden escrita del medicamento.', 'beginner', 10, 2,
   '{"acceptable_answers":["prescription"],"case_sensitive":false,"blank_position":"inline","word_bank":["prescription","recipe","receipt","referral"]}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000010504', 'aaaa1111-0000-4000-8000-000000000105', 'sentence_ordering',
   'Put the words in order to give a safety-netting instruction.', 'Call us if your symptoms get worse.',
   'Safety-netting tells the patient when to seek help again.', 'Esta indicación le dice al paciente cuándo volver a buscar atención.', 'beginner', 10, 3,
   '{"words":["Call","us","if","your","symptoms","get","worse."],"extra_words":["when","bad"],"show_punctuation":true}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000010505', 'aaaa1111-0000-4000-8000-000000000105', 'pronunciation',
   'Say this phrase aloud: "Do you have any questions for me?"', 'Do you have any questions for me?',
   'Always invite questions before the patient leaves. Stress "questions".', 'Siempre invita a preguntar antes de que el paciente se vaya. Acentúa "questions".', 'beginner', 10, 4,
   '{"word":"Do you have any questions for me?","phonetic":"/duː juː hæv ˈɛn.i ˈkwɛs.tʃənz fɔːr miː/","minimum_score":60,"common_mistakes":[{"mistake":"kestions","correction":"questions — pronounce the initial /kw/ sound"}],"definition_es":"¿Tiene alguna pregunta para mí?"}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000010506', 'aaaa1111-0000-4000-8000-000000000105', 'flashcard',
   'follow-up', 'seguimiento',
   'A later visit to check the patient''s progress.', 'Una consulta posterior para revisar la evolución del paciente.', 'beginner', 10, 5,
   '{"front":{"text":"follow-up","subtext":"/ˈfɒl.oʊ ʌp/"},"back":{"text":"seguimiento","explanation":"A return visit to check progress.","example":"We will see you at your follow-up in two weeks."},"show_pronunciation":true}'::jsonb, TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order, match_pair_id)
VALUES
  ('aaaa2222-0000-4000-8000-000000010501', 'Let''s schedule a follow-up appointment in two weeks.', TRUE, 0, NULL),
  ('aaaa2222-0000-4000-8000-000000010501', 'Come back when you want.', FALSE, 1, NULL),
  ('aaaa2222-0000-4000-8000-000000010501', 'You return here two weeks.', FALSE, 2, NULL),
  ('aaaa2222-0000-4000-8000-000000010501', 'See you, maybe later.', FALSE, 3, NULL)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- Exercises — Module 2: Anatomy & Body Systems
-- ============================================================================

-- Lesson 2.1: Head & Neck ------------------------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('aaaa2222-0000-4000-8000-000000020101', 'aaaa1111-0000-4000-8000-000000000201', 'multiple_choice',
   'Which English word means "garganta"?', 'throat',
   'The throat is the passage at the back of the mouth, examined in ENT exams.', 'La "throat" (garganta) es el conducto detrás de la boca que se explora en otorrinolaringología.', 'beginner', 10, 0,
   '{"shuffle_options": true}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000020102', 'aaaa1111-0000-4000-8000-000000000201', 'matching',
   'Match each English term with its Spanish translation.', 'brain = cerebro; jaw = mandíbula; neck = cuello; forehead = frente',
   'Core head and neck structures.', 'Estructuras básicas de cabeza y cuello.', 'beginner', 10, 1,
   '{"columns": 2}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000020103', 'aaaa1111-0000-4000-8000-000000000201', 'fill_in_blank',
   'Complete the exam instruction: "Open your ____ and say ah."', 'mouth',
   'This is the standard instruction for an oropharyngeal exam.', 'Es la instrucción estándar para explorar la orofaringe.', 'beginner', 10, 2,
   '{"acceptable_answers":["mouth"],"case_sensitive":false,"blank_position":"inline","word_bank":["mouth","nose","eyes","ears"]}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000020104', 'aaaa1111-0000-4000-8000-000000000201', 'flashcard',
   'scalp', 'cuero cabelludo',
   'The skin covering the top of the head.', 'La piel que cubre la parte superior de la cabeza.', 'beginner', 10, 3,
   '{"front":{"text":"scalp","subtext":"/skælp/"},"back":{"text":"cuero cabelludo","example":"I am going to examine your scalp for any lesions."},"show_pronunciation":true}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000020105', 'aaaa1111-0000-4000-8000-000000000201', 'pronunciation',
   'Say this word aloud: "throat"', 'throat',
   'The "th" is a soft sound with the tongue between the teeth, not a "t".', 'La "th" es un sonido suave con la lengua entre los dientes; no es una "t".', 'beginner', 10, 4,
   '{"word":"throat","phonetic":"/θroʊt/","minimum_score":60,"syllables":["throat"],"common_mistakes":[{"mistake":"trot","correction":"throat — start with the soft th sound /θ/"}],"definition_es":"garganta"}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000020106', 'aaaa1111-0000-4000-8000-000000000201', 'translation',
   'Translate to English: "Me duele la garganta desde ayer."', 'My throat has been hurting since yesterday.',
   'Present perfect continuous ("has been hurting") expresses a symptom that continues now.', 'El presente perfecto continuo ("has been hurting") expresa un síntoma que continúa ahora.', 'beginner', 10, 5,
   '{"source_language":"es","target_language":"en","source_text":"Me duele la garganta desde ayer.","acceptable_translations":["My throat has been hurting since yesterday.","I have had a sore throat since yesterday.","My throat has hurt since yesterday."],"key_terms":["throat","since yesterday"]}'::jsonb, TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order, match_pair_id)
VALUES
  ('aaaa2222-0000-4000-8000-000000020101', 'throat', TRUE, 0, NULL),
  ('aaaa2222-0000-4000-8000-000000020101', 'tongue', FALSE, 1, NULL),
  ('aaaa2222-0000-4000-8000-000000020101', 'thigh', FALSE, 2, NULL),
  ('aaaa2222-0000-4000-8000-000000020101', 'thumb', FALSE, 3, NULL),
  ('aaaa2222-0000-4000-8000-000000020102', 'brain', TRUE, 0, 'p1'),
  ('aaaa2222-0000-4000-8000-000000020102', 'cerebro', TRUE, 1, 'p1'),
  ('aaaa2222-0000-4000-8000-000000020102', 'jaw', TRUE, 2, 'p2'),
  ('aaaa2222-0000-4000-8000-000000020102', 'mandíbula', TRUE, 3, 'p2'),
  ('aaaa2222-0000-4000-8000-000000020102', 'neck', TRUE, 4, 'p3'),
  ('aaaa2222-0000-4000-8000-000000020102', 'cuello', TRUE, 5, 'p3'),
  ('aaaa2222-0000-4000-8000-000000020102', 'forehead', TRUE, 6, 'p4'),
  ('aaaa2222-0000-4000-8000-000000020102', 'frente', TRUE, 7, 'p4')
ON CONFLICT DO NOTHING;

-- Lesson 2.2: Chest, Heart & Lungs ----------------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('aaaa2222-0000-4000-8000-000000020201', 'aaaa1111-0000-4000-8000-000000000202', 'multiple_choice',
   'Which organ pumps blood through the body?', 'The heart',
   'The heart is the muscular pump of the cardiovascular system.', 'El corazón es la bomba muscular del sistema cardiovascular.', 'beginner', 10, 0,
   '{"shuffle_options": true}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000020202', 'aaaa1111-0000-4000-8000-000000000202', 'matching',
   'Match each English term with its Spanish translation.', 'lung = pulmón; rib = costilla; vein = vena; artery = arteria',
   'Core thoracic and vascular structures.', 'Estructuras torácicas y vasculares básicas.', 'beginner', 10, 1,
   '{"columns": 2}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000020203', 'aaaa1111-0000-4000-8000-000000000202', 'fill_in_blank',
   'Complete the exam instruction: "Take a deep ____ and hold it."', 'breath',
   '"Breath" is the noun; "breathe" is the verb.', '"Breath" es el sustantivo (respiración); "breathe" es el verbo (respirar).', 'beginner', 10, 2,
   '{"acceptable_answers":["breath"],"case_sensitive":false,"blank_position":"inline","word_bank":["breath","breathe","air","lung"]}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000020204', 'aaaa1111-0000-4000-8000-000000000202', 'sentence_ordering',
   'Put the words in order to announce the auscultation.', 'I am going to listen to your lungs.',
   'Announce each step of the exam before you do it.', 'Anuncia cada paso de la exploración antes de realizarlo.', 'beginner', 10, 3,
   '{"words":["I","am","going","to","listen","to","your","lungs."],"extra_words":["hear","chest"],"show_punctuation":true}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000020205', 'aaaa1111-0000-4000-8000-000000000202', 'flashcard',
   'diaphragm', 'diafragma',
   'The main muscle of breathing, below the lungs.', 'El músculo principal de la respiración, debajo de los pulmones.', 'beginner', 10, 4,
   '{"front":{"text":"diaphragm","subtext":"/ˈdaɪ.ə.fræm/"},"back":{"text":"diafragma","explanation":"The g is silent.","example":"The diaphragm contracts when you breathe in."},"show_pronunciation":true}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000020206', 'aaaa1111-0000-4000-8000-000000000202', 'pronunciation',
   'Say this phrase aloud: "Breathe in and out slowly."', 'Breathe in and out slowly.',
   '"Breathe" ends in a soft voiced th sound; do not say "brid".', '"Breathe" termina en un sonido "th" suave y sonoro; no digas "brid".', 'beginner', 10, 5,
   '{"word":"Breathe in and out slowly.","phonetic":"/briːð ɪn ænd aʊt ˈsloʊ.li/","minimum_score":60,"common_mistakes":[{"mistake":"breath in","correction":"breathe in — the verb has a final /ð/ sound"}],"definition_es":"Inhale y exhale lentamente."}'::jsonb, TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order, match_pair_id)
VALUES
  ('aaaa2222-0000-4000-8000-000000020201', 'The heart', TRUE, 0, NULL),
  ('aaaa2222-0000-4000-8000-000000020201', 'The lung', FALSE, 1, NULL),
  ('aaaa2222-0000-4000-8000-000000020201', 'The liver', FALSE, 2, NULL),
  ('aaaa2222-0000-4000-8000-000000020201', 'The kidney', FALSE, 3, NULL),
  ('aaaa2222-0000-4000-8000-000000020202', 'lung', TRUE, 0, 'p1'),
  ('aaaa2222-0000-4000-8000-000000020202', 'pulmón', TRUE, 1, 'p1'),
  ('aaaa2222-0000-4000-8000-000000020202', 'rib', TRUE, 2, 'p2'),
  ('aaaa2222-0000-4000-8000-000000020202', 'costilla', TRUE, 3, 'p2'),
  ('aaaa2222-0000-4000-8000-000000020202', 'vein', TRUE, 4, 'p3'),
  ('aaaa2222-0000-4000-8000-000000020202', 'vena', TRUE, 5, 'p3'),
  ('aaaa2222-0000-4000-8000-000000020202', 'artery', TRUE, 6, 'p4'),
  ('aaaa2222-0000-4000-8000-000000020202', 'arteria', TRUE, 7, 'p4')
ON CONFLICT DO NOTHING;

-- Lesson 2.3: Abdomen & Digestive System ----------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('aaaa2222-0000-4000-8000-000000020301', 'aaaa1111-0000-4000-8000-000000000203', 'multiple_choice',
   'Which organ produces bile?', 'The liver',
   'The liver produces bile; the gallbladder only stores and concentrates it.', 'El hígado produce la bilis; la vesícula biliar solo la almacena y concentra.', 'beginner', 10, 0,
   '{"shuffle_options": true}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000020302', 'aaaa1111-0000-4000-8000-000000000203', 'matching',
   'Match each English term with its Spanish translation.', 'stomach = estómago; kidney = riñón; bladder = vejiga; liver = hígado',
   'Core abdominal organs.', 'Órganos abdominales básicos.', 'beginner', 10, 1,
   '{"columns": 2}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000020303', 'aaaa1111-0000-4000-8000-000000000203', 'fill_in_blank',
   'Complete the exam question: "Does it hurt when I press on your ____?"', 'abdomen',
   'With patients, "abdomen", "stomach", or "belly" are all understood; "abdomen" is the clinical term.', 'Con pacientes se entiende "abdomen", "stomach" o "belly"; "abdomen" es el término clínico.', 'beginner', 10, 2,
   '{"acceptable_answers":["abdomen","stomach","belly"],"case_sensitive":false,"blank_position":"end","word_bank":["abdomen","chest","back","shoulder"]}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000020304', 'aaaa1111-0000-4000-8000-000000000203', 'typing',
   'How do you say "vesícula biliar" in English?', 'gallbladder',
   'One word in English: gallbladder. "Gall" is an old word for bile.', 'En inglés es una sola palabra: "gallbladder". "Gall" es una palabra antigua para bilis.', 'beginner', 10, 3,
   '{"acceptable_answers":["gallbladder","gall bladder"],"case_sensitive":false,"max_length":40,"placeholder":"Type the English term..."}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000020305', 'aaaa1111-0000-4000-8000-000000000203', 'flashcard',
   'esophagus', 'esófago',
   'The tube that carries food from the throat to the stomach.', 'El conducto que lleva el alimento de la garganta al estómago.', 'beginner', 10, 4,
   '{"front":{"text":"esophagus","subtext":"/ɪˈsɒf.ə.ɡəs/"},"back":{"text":"esófago","example":"Acid reflux irritates the esophagus."},"show_pronunciation":true}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000020306', 'aaaa1111-0000-4000-8000-000000000203', 'translation',
   'Translate to English: "¿Ha notado sangre en la orina?"', 'Have you noticed blood in your urine?',
   'Present perfect ("Have you noticed...?") is standard for symptom screening questions.', 'El presente perfecto ("Have you noticed...?") es estándar en preguntas de tamizaje de síntomas.', 'beginner', 10, 5,
   '{"source_language":"es","target_language":"en","source_text":"¿Ha notado sangre en la orina?","acceptable_translations":["Have you noticed blood in your urine?","Have you noticed any blood in your urine?","Have you seen blood in your urine?"],"key_terms":["blood","urine"]}'::jsonb, TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order, match_pair_id)
VALUES
  ('aaaa2222-0000-4000-8000-000000020301', 'The liver', TRUE, 0, NULL),
  ('aaaa2222-0000-4000-8000-000000020301', 'The gallbladder', FALSE, 1, NULL),
  ('aaaa2222-0000-4000-8000-000000020301', 'The pancreas', FALSE, 2, NULL),
  ('aaaa2222-0000-4000-8000-000000020301', 'The stomach', FALSE, 3, NULL),
  ('aaaa2222-0000-4000-8000-000000020302', 'stomach', TRUE, 0, 'p1'),
  ('aaaa2222-0000-4000-8000-000000020302', 'estómago', TRUE, 1, 'p1'),
  ('aaaa2222-0000-4000-8000-000000020302', 'kidney', TRUE, 2, 'p2'),
  ('aaaa2222-0000-4000-8000-000000020302', 'riñón', TRUE, 3, 'p2'),
  ('aaaa2222-0000-4000-8000-000000020302', 'bladder', TRUE, 4, 'p3'),
  ('aaaa2222-0000-4000-8000-000000020302', 'vejiga', TRUE, 5, 'p3'),
  ('aaaa2222-0000-4000-8000-000000020302', 'liver', TRUE, 6, 'p4'),
  ('aaaa2222-0000-4000-8000-000000020302', 'hígado', TRUE, 7, 'p4')
ON CONFLICT DO NOTHING;

-- Lesson 2.4: Muscles, Bones & Limbs --------------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('aaaa2222-0000-4000-8000-000000020401', 'aaaa1111-0000-4000-8000-000000000204', 'multiple_choice',
   'Which joint connects the foot to the leg?', 'The ankle',
   'The ankle joins the foot and the leg; the wrist joins the hand and the forearm.', 'El tobillo une el pie con la pierna; la muñeca une la mano con el antebrazo.', 'beginner', 10, 0,
   '{"shuffle_options": true}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000020402', 'aaaa1111-0000-4000-8000-000000000204', 'matching',
   'Match each English term with its Spanish translation.', 'shoulder = hombro; knee = rodilla; wrist = muñeca; hip = cadera',
   'The large joints you examine most often.', 'Las grandes articulaciones que se exploran con más frecuencia.', 'beginner', 10, 1,
   '{"columns": 2}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000020403', 'aaaa1111-0000-4000-8000-000000000204', 'fill_in_blank',
   'Complete the exam instruction: "Bend your ____ and touch your toes."', 'knees',
   '"Bend your knees" is a common instruction in musculoskeletal exams.', '"Bend your knees" (doble las rodillas) es una instrucción común en la exploración musculoesquelética.', 'beginner', 10, 2,
   '{"acceptable_answers":["knees","knee"],"case_sensitive":false,"blank_position":"inline","word_bank":["knees","elbows","wrists","ankles"]}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000020404', 'aaaa1111-0000-4000-8000-000000000204', 'sentence_ordering',
   'Put the words in order to test range of motion.', 'Can you raise your arm above your head?',
   '"Raise" is the transitive verb: you raise something.', '"Raise" es el verbo transitivo: uno levanta algo.', 'beginner', 10, 3,
   '{"words":["Can","you","raise","your","arm","above","your","head?"],"extra_words":["rise","up"],"show_punctuation":true}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000020405', 'aaaa1111-0000-4000-8000-000000000204', 'flashcard',
   'spine', 'columna vertebral',
   'The column of bones that protects the spinal cord.', 'La columna de huesos que protege la médula espinal.', 'beginner', 10, 4,
   '{"front":{"text":"spine","subtext":"/spaɪn/"},"back":{"text":"columna vertebral","explanation":"Also called the backbone.","example":"Keep your spine straight while I examine your back."},"show_pronunciation":true}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000020406', 'aaaa1111-0000-4000-8000-000000000204', 'pronunciation',
   'Say this word aloud: "shoulder"', 'shoulder',
   'The "sh" sound /ʃ/ is softer than the Spanish "ch".', 'El sonido "sh" /ʃ/ es más suave que la "ch" del español.', 'beginner', 10, 5,
   '{"word":"shoulder","phonetic":"/ˈʃoʊl.dər/","minimum_score":60,"syllables":["shoul","der"],"common_mistakes":[{"mistake":"choulder","correction":"shoulder — use the soft /ʃ/ sound, not /tʃ/"}],"definition_es":"hombro"}'::jsonb, TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order, match_pair_id)
VALUES
  ('aaaa2222-0000-4000-8000-000000020401', 'The ankle', TRUE, 0, NULL),
  ('aaaa2222-0000-4000-8000-000000020401', 'The wrist', FALSE, 1, NULL),
  ('aaaa2222-0000-4000-8000-000000020401', 'The elbow', FALSE, 2, NULL),
  ('aaaa2222-0000-4000-8000-000000020401', 'The hip', FALSE, 3, NULL),
  ('aaaa2222-0000-4000-8000-000000020402', 'shoulder', TRUE, 0, 'p1'),
  ('aaaa2222-0000-4000-8000-000000020402', 'hombro', TRUE, 1, 'p1'),
  ('aaaa2222-0000-4000-8000-000000020402', 'knee', TRUE, 2, 'p2'),
  ('aaaa2222-0000-4000-8000-000000020402', 'rodilla', TRUE, 3, 'p2'),
  ('aaaa2222-0000-4000-8000-000000020402', 'wrist', TRUE, 4, 'p3'),
  ('aaaa2222-0000-4000-8000-000000020402', 'muñeca', TRUE, 5, 'p3'),
  ('aaaa2222-0000-4000-8000-000000020402', 'hip', TRUE, 6, 'p4'),
  ('aaaa2222-0000-4000-8000-000000020402', 'cadera', TRUE, 7, 'p4')
ON CONFLICT DO NOTHING;

-- Lesson 2.5: Anatomy Review (review) -------------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('aaaa2222-0000-4000-8000-000000020501', 'aaaa1111-0000-4000-8000-000000000205', 'matching',
   'Review: match each English term with its Spanish translation.', 'organ = órgano; skin = piel; nerve = nervio; bone = hueso',
   'General anatomy terms that appear across all body systems.', 'Términos generales de anatomía presentes en todos los sistemas.', 'beginner', 10, 0,
   '{"columns": 2}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000020502', 'aaaa1111-0000-4000-8000-000000000205', 'multiple_choice',
   'Which term refers to any tube that carries blood through the body?', 'Blood vessel',
   'Arteries, veins, and capillaries are all blood vessels.', 'Arterias, venas y capilares son todos "blood vessels" (vasos sanguíneos).', 'beginner', 10, 1,
   '{"shuffle_options": true}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000020503', 'aaaa1111-0000-4000-8000-000000000205', 'flashcard',
   'blood vessel', 'vaso sanguíneo',
   'Any tube that carries blood: artery, vein, or capillary.', 'Cualquier conducto que transporta sangre: arteria, vena o capilar.', 'beginner', 10, 2,
   '{"front":{"text":"blood vessel","subtext":"/blʌd ˈvɛs.əl/"},"back":{"text":"vaso sanguíneo","example":"High blood pressure damages the blood vessels."},"show_pronunciation":true}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000020504', 'aaaa1111-0000-4000-8000-000000000205', 'typing',
   'Translate to English: "piel"', 'skin',
   'The skin is the largest organ of the body.', 'La piel ("skin") es el órgano más grande del cuerpo.', 'beginner', 10, 3,
   '{"acceptable_answers":["skin","the skin"],"case_sensitive":false,"max_length":30,"placeholder":"Type the English term..."}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000020505', 'aaaa1111-0000-4000-8000-000000000205', 'fill_in_blank',
   'Complete: "The ____ carry messages between the brain and the body."', 'nerves',
   'Nerves transmit signals between the brain, spinal cord, and body.', 'Los nervios ("nerves") transmiten señales entre el cerebro, la médula espinal y el cuerpo.', 'beginner', 10, 4,
   '{"acceptable_answers":["nerves"],"case_sensitive":false,"blank_position":"inline","word_bank":["nerves","veins","bones","muscles"]}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000020506', 'aaaa1111-0000-4000-8000-000000000205', 'translation',
   'Translate to English: "El corazón bombea sangre a todo el cuerpo."', 'The heart pumps blood to the whole body.',
   '"Pump" is the verb used for the heart''s action.', '"Pump" (bombear) es el verbo que describe la acción del corazón.', 'beginner', 10, 5,
   '{"source_language":"es","target_language":"en","source_text":"El corazón bombea sangre a todo el cuerpo.","acceptable_translations":["The heart pumps blood to the whole body.","The heart pumps blood to the entire body.","The heart pumps blood throughout the body."],"key_terms":["heart","pumps","blood"]}'::jsonb, TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order, match_pair_id)
VALUES
  ('aaaa2222-0000-4000-8000-000000020501', 'organ', TRUE, 0, 'p1'),
  ('aaaa2222-0000-4000-8000-000000020501', 'órgano', TRUE, 1, 'p1'),
  ('aaaa2222-0000-4000-8000-000000020501', 'skin', TRUE, 2, 'p2'),
  ('aaaa2222-0000-4000-8000-000000020501', 'piel', TRUE, 3, 'p2'),
  ('aaaa2222-0000-4000-8000-000000020501', 'nerve', TRUE, 4, 'p3'),
  ('aaaa2222-0000-4000-8000-000000020501', 'nervio', TRUE, 5, 'p3'),
  ('aaaa2222-0000-4000-8000-000000020501', 'bone', TRUE, 6, 'p4'),
  ('aaaa2222-0000-4000-8000-000000020501', 'hueso', TRUE, 7, 'p4'),
  ('aaaa2222-0000-4000-8000-000000020502', 'Blood vessel', TRUE, 0, NULL),
  ('aaaa2222-0000-4000-8000-000000020502', 'Blood cell', FALSE, 1, NULL),
  ('aaaa2222-0000-4000-8000-000000020502', 'Airway', FALSE, 2, NULL),
  ('aaaa2222-0000-4000-8000-000000020502', 'Tendon', FALSE, 3, NULL)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- Exercises — Module 3: Describing Symptoms & Pain
-- ============================================================================

-- Lesson 3.1: Describing Pain ---------------------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('aaaa2222-0000-4000-8000-000000030101', 'aaaa1111-0000-4000-8000-000000000301', 'multiple_choice',
   'A patient says the pain feels "like a knife". Which word best documents this quality?', 'Stabbing',
   '"Stabbing" pain is sudden and knife-like; "dull" is a low, constant ache.', 'El dolor "stabbing" (punzante, como puñalada) es súbito y agudo; "dull" es un dolor sordo y constante.', 'intermediate', 10, 0,
   '{"shuffle_options": true}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000030102', 'aaaa1111-0000-4000-8000-000000000301', 'matching',
   'Match each pain quality with its Spanish equivalent.', 'burning = ardoroso; throbbing = pulsátil; dull = sordo; cramping = tipo cólico',
   'Patients use these adjectives constantly; recognizing them guides your differential.', 'Los pacientes usan estos adjetivos constantemente; reconocerlos orienta tu diagnóstico diferencial.', 'intermediate', 10, 1,
   '{"columns": 2}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000030103', 'aaaa1111-0000-4000-8000-000000000301', 'fill_in_blank',
   'Complete: "The pain ____ down my left arm." (se irradia)', 'radiates',
   'Pain that "radiates" travels from its origin to another area — a red flag in chest pain.', 'El dolor que "radiates" (se irradia) viaja de su origen a otra zona — un dato de alarma en dolor torácico.', 'intermediate', 10, 2,
   '{"acceptable_answers":["radiates","shoots"],"case_sensitive":false,"blank_position":"inline","word_bank":["radiates","runs","burns","moves"]}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000030104', 'aaaa1111-0000-4000-8000-000000000301', 'translation',
   'Translate to English: "El dolor va y viene durante el día."', 'The pain comes and goes during the day.',
   '"Comes and goes" is the idiomatic way patients describe intermittent pain.', '"Comes and goes" es la forma idiomática en que los pacientes describen el dolor intermitente.', 'intermediate', 10, 3,
   '{"source_language":"es","target_language":"en","source_text":"El dolor va y viene durante el día.","acceptable_translations":["The pain comes and goes during the day.","The pain comes and goes throughout the day."],"key_terms":["comes and goes"]}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000030105', 'aaaa1111-0000-4000-8000-000000000301', 'flashcard',
   'tenderness', 'dolor a la palpación',
   'Pain felt when an area is touched or pressed during the exam.', 'Dolor que se siente al tocar o presionar una zona durante la exploración.', 'intermediate', 10, 4,
   '{"front":{"text":"tenderness","subtext":"/ˈtɛn.dər.nəs/"},"back":{"text":"dolor a la palpación","explanation":"Documented as \"tender to palpation\".","example":"There is tenderness in the right lower quadrant."},"show_pronunciation":true}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000030106', 'aaaa1111-0000-4000-8000-000000000301', 'pronunciation',
   'Say this question aloud: "Where does it hurt?"', 'Where does it hurt?',
   'The essential first question of any pain assessment.', 'La pregunta esencial para iniciar cualquier evaluación del dolor.', 'intermediate', 10, 5,
   '{"word":"Where does it hurt?","phonetic":"/wɛər dʌz ɪt hɜːrt/","minimum_score":60,"common_mistakes":[{"mistake":"hurts","correction":"hurt — after \"does\", use the base form of the verb"}],"definition_es":"¿Dónde le duele?"}'::jsonb, TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order, match_pair_id)
VALUES
  ('aaaa2222-0000-4000-8000-000000030101', 'Stabbing', TRUE, 0, NULL),
  ('aaaa2222-0000-4000-8000-000000030101', 'Dull', FALSE, 1, NULL),
  ('aaaa2222-0000-4000-8000-000000030101', 'Itching', FALSE, 2, NULL),
  ('aaaa2222-0000-4000-8000-000000030101', 'Numb', FALSE, 3, NULL),
  ('aaaa2222-0000-4000-8000-000000030102', 'burning', TRUE, 0, 'p1'),
  ('aaaa2222-0000-4000-8000-000000030102', 'ardoroso', TRUE, 1, 'p1'),
  ('aaaa2222-0000-4000-8000-000000030102', 'throbbing', TRUE, 2, 'p2'),
  ('aaaa2222-0000-4000-8000-000000030102', 'pulsátil', TRUE, 3, 'p2'),
  ('aaaa2222-0000-4000-8000-000000030102', 'dull', TRUE, 4, 'p3'),
  ('aaaa2222-0000-4000-8000-000000030102', 'sordo', TRUE, 5, 'p3'),
  ('aaaa2222-0000-4000-8000-000000030102', 'cramping', TRUE, 6, 'p4'),
  ('aaaa2222-0000-4000-8000-000000030102', 'tipo cólico', TRUE, 7, 'p4')
ON CONFLICT DO NOTHING;

-- Lesson 3.2: Pain Scales & OPQRST ------------------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('aaaa2222-0000-4000-8000-000000030201', 'aaaa1111-0000-4000-8000-000000000302', 'multiple_choice',
   'Which question assesses pain severity?', 'On a scale from zero to ten, how bad is your pain?',
   'The 0–10 numeric rating scale is the standard severity question (the S in OPQRST).', 'La escala numérica de 0 a 10 es la pregunta estándar de intensidad (la S de OPQRST).', 'intermediate', 10, 0,
   '{"shuffle_options": true}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000030202', 'aaaa1111-0000-4000-8000-000000000302', 'sentence_ordering',
   'Put the words in order to ask about severity.', 'How would you rate your pain right now?',
   '"Rate" asks the patient to assign a number to the pain.', '"Rate" pide al paciente asignar un número al dolor.', 'intermediate', 10, 1,
   '{"words":["How","would","you","rate","your","pain","right","now?"],"extra_words":["feel","much"],"show_punctuation":true}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000030203', 'aaaa1111-0000-4000-8000-000000000302', 'fill_in_blank',
   'Complete the provocation question: "What makes the pain better or ____?"', 'worse',
   'This is the P (provocation/palliation) of OPQRST.', 'Es la P (provocación/paliación) de OPQRST.', 'intermediate', 10, 2,
   '{"acceptable_answers":["worse"],"case_sensitive":false,"blank_position":"end","word_bank":["worse","worst","bad","stronger"]}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000030204', 'aaaa1111-0000-4000-8000-000000000302', 'typing',
   'Ask when the pain started, in English.', 'When did the pain start?',
   'Simple past ("did... start") asks about onset — the O of OPQRST.', 'El pasado simple ("did... start") pregunta por el inicio — la O de OPQRST.', 'intermediate', 10, 3,
   '{"acceptable_answers":["When did the pain start?","When did the pain begin?","When did your pain start?","When did it start?"],"case_sensitive":false,"max_length":60,"placeholder":"Type your question..."}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000030205', 'aaaa1111-0000-4000-8000-000000000302', 'matching',
   'Match each assessment term with its Spanish equivalent.', 'onset = inicio; severity = intensidad; relief = alivio; trigger = desencadenante',
   'These four concepts structure every pain history.', 'Estos cuatro conceptos estructuran toda historia del dolor.', 'intermediate', 10, 4,
   '{"columns": 2}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000030206', 'aaaa1111-0000-4000-8000-000000000302', 'flashcard',
   'intermittent', 'intermitente',
   'Occurring at intervals; not constant.', 'Que ocurre por intervalos; no es constante.', 'intermediate', 10, 5,
   '{"front":{"text":"intermittent","subtext":"/ˌɪn.tərˈmɪt.ənt/"},"back":{"text":"intermitente","explanation":"Opposite of constant.","example":"She reports intermittent abdominal pain after meals."},"show_pronunciation":true}'::jsonb, TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order, match_pair_id)
VALUES
  ('aaaa2222-0000-4000-8000-000000030201', 'On a scale from zero to ten, how bad is your pain?', TRUE, 0, NULL),
  ('aaaa2222-0000-4000-8000-000000030201', 'Where does it hurt?', FALSE, 1, NULL),
  ('aaaa2222-0000-4000-8000-000000030201', 'When did the pain start?', FALSE, 2, NULL),
  ('aaaa2222-0000-4000-8000-000000030201', 'Does the pain move anywhere?', FALSE, 3, NULL),
  ('aaaa2222-0000-4000-8000-000000030205', 'onset', TRUE, 0, 'p1'),
  ('aaaa2222-0000-4000-8000-000000030205', 'inicio', TRUE, 1, 'p1'),
  ('aaaa2222-0000-4000-8000-000000030205', 'severity', TRUE, 2, 'p2'),
  ('aaaa2222-0000-4000-8000-000000030205', 'intensidad', TRUE, 3, 'p2'),
  ('aaaa2222-0000-4000-8000-000000030205', 'relief', TRUE, 4, 'p3'),
  ('aaaa2222-0000-4000-8000-000000030205', 'alivio', TRUE, 5, 'p3'),
  ('aaaa2222-0000-4000-8000-000000030205', 'trigger', TRUE, 6, 'p4'),
  ('aaaa2222-0000-4000-8000-000000030205', 'desencadenante', TRUE, 7, 'p4')
ON CONFLICT DO NOTHING;

-- Lesson 3.3: Common Symptoms ------------------------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('aaaa2222-0000-4000-8000-000000030301', 'aaaa1111-0000-4000-8000-000000000303', 'multiple_choice',
   'A patient says: "I feel like the room is spinning." Which symptom is this?', 'Dizziness',
   'A spinning sensation is dizziness (specifically vertigo).', 'La sensación de que todo gira es "dizziness" (mareo; específicamente vértigo).', 'intermediate', 10, 0,
   '{"shuffle_options": true}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000030302', 'aaaa1111-0000-4000-8000-000000000303', 'matching',
   'Match each symptom with its Spanish equivalent.', 'nausea = náuseas; swelling = hinchazón; rash = sarpullido; chills = escalofríos',
   'Four of the most frequently reported symptoms in primary care.', 'Cuatro de los síntomas más frecuentes en atención primaria.', 'intermediate', 10, 1,
   '{"columns": 2}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000030303', 'aaaa1111-0000-4000-8000-000000000303', 'fill_in_blank',
   'Complete the screening question: "Have you had any shortness of ____?"', 'breath',
   '"Shortness of breath" (dyspnea) is a key cardiopulmonary symptom.', '"Shortness of breath" (disnea o falta de aire) es un síntoma cardiopulmonar clave.', 'intermediate', 10, 2,
   '{"acceptable_answers":["breath"],"case_sensitive":false,"blank_position":"end","word_bank":["breath","air","lungs","breathing"]}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000030304', 'aaaa1111-0000-4000-8000-000000000303', 'translation',
   'Translate to English: "He tenido náuseas y vómito desde anoche."', 'I have had nausea and vomiting since last night.',
   'Present perfect ("have had") connects a past onset with the present.', 'El presente perfecto ("have had") conecta un inicio en el pasado con el presente.', 'intermediate', 10, 3,
   '{"source_language":"es","target_language":"en","source_text":"He tenido náuseas y vómito desde anoche.","acceptable_translations":["I have had nausea and vomiting since last night.","I''ve had nausea and vomiting since last night.","I have been nauseous and vomiting since last night."],"key_terms":["nausea","vomiting","since last night"]}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000030305', 'aaaa1111-0000-4000-8000-000000000303', 'pronunciation',
   'Say this word aloud: "dizziness"', 'dizziness',
   'Three syllables: DIZ-zi-ness, with stress on the first.', 'Tres sílabas: DIZ-zi-ness, con acento en la primera.', 'intermediate', 10, 4,
   '{"word":"dizziness","phonetic":"/ˈdɪz.i.nəs/","minimum_score":60,"syllables":["diz","zi","ness"],"common_mistakes":[{"mistake":"diseases","correction":"dizziness — short i sounds, stress on the first syllable"}],"definition_es":"mareo"}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000030306', 'aaaa1111-0000-4000-8000-000000000303', 'flashcard',
   'shortness of breath', 'falta de aire',
   'Difficulty breathing or feeling unable to get enough air (dyspnea).', 'Dificultad para respirar o sensación de no poder tomar suficiente aire (disnea).', 'intermediate', 10, 5,
   '{"front":{"text":"shortness of breath","subtext":"/ˈʃɔːrt.nəs əv brɛθ/"},"back":{"text":"falta de aire","explanation":"Clinical term: dyspnea. Often abbreviated SOB in notes.","example":"Do you get shortness of breath when you climb stairs?"},"show_pronunciation":true}'::jsonb, TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order, match_pair_id)
VALUES
  ('aaaa2222-0000-4000-8000-000000030301', 'Dizziness', TRUE, 0, NULL),
  ('aaaa2222-0000-4000-8000-000000030301', 'Fatigue', FALSE, 1, NULL),
  ('aaaa2222-0000-4000-8000-000000030301', 'Nausea', FALSE, 2, NULL),
  ('aaaa2222-0000-4000-8000-000000030301', 'Numbness', FALSE, 3, NULL),
  ('aaaa2222-0000-4000-8000-000000030302', 'nausea', TRUE, 0, 'p1'),
  ('aaaa2222-0000-4000-8000-000000030302', 'náuseas', TRUE, 1, 'p1'),
  ('aaaa2222-0000-4000-8000-000000030302', 'swelling', TRUE, 2, 'p2'),
  ('aaaa2222-0000-4000-8000-000000030302', 'hinchazón', TRUE, 3, 'p2'),
  ('aaaa2222-0000-4000-8000-000000030302', 'rash', TRUE, 4, 'p3'),
  ('aaaa2222-0000-4000-8000-000000030302', 'sarpullido', TRUE, 5, 'p3'),
  ('aaaa2222-0000-4000-8000-000000030302', 'chills', TRUE, 6, 'p4'),
  ('aaaa2222-0000-4000-8000-000000030302', 'escalofríos', TRUE, 7, 'p4')
ON CONFLICT DO NOTHING;

-- Lesson 3.4: Onset, Duration & Frequency --------------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('aaaa2222-0000-4000-8000-000000030401', 'aaaa1111-0000-4000-8000-000000000304', 'multiple_choice',
   'Which term describes a condition that lasts a long time?', 'Chronic',
   '"Chronic" means long-lasting; "acute" means recent and often sudden onset.', '"Chronic" (crónico) significa de larga duración; "acute" (agudo) significa de inicio reciente y a menudo súbito.', 'intermediate', 10, 0,
   '{"shuffle_options": true}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000030402', 'aaaa1111-0000-4000-8000-000000000304', 'fill_in_blank',
   'Complete the frequency question: "How ____ does the headache happen — every day or once a week?"', 'often',
   '"How often" asks about frequency.', '"How often" pregunta por la frecuencia.', 'intermediate', 10, 1,
   '{"acceptable_answers":["often","frequently"],"case_sensitive":false,"blank_position":"inline","word_bank":["often","long","much","many"]}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000030403', 'aaaa1111-0000-4000-8000-000000000304', 'typing',
   'Ask how long the patient has had these symptoms, in English.', 'How long have you had these symptoms?',
   '"How long have you had...?" asks about duration up to now (present perfect).', '"How long have you had...?" pregunta por la duración hasta ahora (presente perfecto).', 'intermediate', 10, 2,
   '{"acceptable_answers":["How long have you had these symptoms?","How long have you had the symptoms?","How long have you had this?"],"case_sensitive":false,"max_length":80,"placeholder":"Type your question..."}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000030404', 'aaaa1111-0000-4000-8000-000000000304', 'sentence_ordering',
   'Put the words in order to ask about onset.', 'When did you first notice the pain?',
   '"First notice" pinpoints the exact onset of a symptom.', '"First notice" precisa el momento exacto de inicio del síntoma.', 'intermediate', 10, 3,
   '{"words":["When","did","you","first","notice","the","pain?"],"extra_words":["feel","start"],"show_punctuation":true}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000030405', 'aaaa1111-0000-4000-8000-000000000304', 'matching',
   'Match each timing term with its Spanish equivalent.', 'sudden = repentino; recurring = recurrente; persistent = persistente; episode = episodio',
   'Timing vocabulary lets you document a precise symptom history.', 'El vocabulario de temporalidad permite documentar una historia clínica precisa.', 'intermediate', 10, 4,
   '{"columns": 2}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000030406', 'aaaa1111-0000-4000-8000-000000000304', 'flashcard',
   'flare-up', 'exacerbación',
   'A sudden worsening of a chronic condition.', 'Un empeoramiento súbito de una enfermedad crónica.', 'intermediate', 10, 5,
   '{"front":{"text":"flare-up","subtext":"/ˈflɛər ʌp/"},"back":{"text":"exacerbación","explanation":"Common in asthma, arthritis, and eczema.","example":"She came in because of an asthma flare-up."},"show_pronunciation":true}'::jsonb, TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order, match_pair_id)
VALUES
  ('aaaa2222-0000-4000-8000-000000030401', 'Chronic', TRUE, 0, NULL),
  ('aaaa2222-0000-4000-8000-000000030401', 'Acute', FALSE, 1, NULL),
  ('aaaa2222-0000-4000-8000-000000030401', 'Sudden', FALSE, 2, NULL),
  ('aaaa2222-0000-4000-8000-000000030401', 'Brief', FALSE, 3, NULL),
  ('aaaa2222-0000-4000-8000-000000030405', 'sudden', TRUE, 0, 'p1'),
  ('aaaa2222-0000-4000-8000-000000030405', 'repentino', TRUE, 1, 'p1'),
  ('aaaa2222-0000-4000-8000-000000030405', 'recurring', TRUE, 2, 'p2'),
  ('aaaa2222-0000-4000-8000-000000030405', 'recurrente', TRUE, 3, 'p2'),
  ('aaaa2222-0000-4000-8000-000000030405', 'persistent', TRUE, 4, 'p3'),
  ('aaaa2222-0000-4000-8000-000000030405', 'persistente', TRUE, 5, 'p3'),
  ('aaaa2222-0000-4000-8000-000000030405', 'episode', TRUE, 6, 'p4'),
  ('aaaa2222-0000-4000-8000-000000030405', 'episodio', TRUE, 7, 'p4')
ON CONFLICT DO NOTHING;

-- Lesson 3.5: Symptoms Review (review) ------------------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('aaaa2222-0000-4000-8000-000000030501', 'aaaa1111-0000-4000-8000-000000000305', 'matching',
   'Review: match each term with its Spanish equivalent.', 'mild = leve; severe = intenso; constant = constante; worsening = empeoramiento',
   'Severity and course descriptors used in every progress note.', 'Descriptores de intensidad y evolución presentes en toda nota clínica.', 'intermediate', 10, 0,
   '{"columns": 2}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000030502', 'aaaa1111-0000-4000-8000-000000000305', 'multiple_choice',
   'The patient''s pain is intermittent. What does this mean?', 'It comes and goes.',
   'Intermittent means occurring at intervals, not continuously.', '"Intermittent" (intermitente) significa que ocurre por intervalos, no de forma continua.', 'intermediate', 10, 1,
   '{"shuffle_options": true}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000030503', 'aaaa1111-0000-4000-8000-000000000305', 'translation',
   'Translate to English: "El dolor empeora cuando camino y mejora cuando descanso."', 'The pain gets worse when I walk and better when I rest.',
   '"Gets worse / gets better" is how patients naturally describe provoking and relieving factors.', '"Gets worse / gets better" es como los pacientes describen naturalmente los factores que agravan o alivian.', 'intermediate', 10, 2,
   '{"source_language":"es","target_language":"en","source_text":"El dolor empeora cuando camino y mejora cuando descanso.","acceptable_translations":["The pain gets worse when I walk and better when I rest.","The pain gets worse when I walk and gets better when I rest.","The pain worsens when I walk and improves when I rest."],"key_terms":["gets worse","rest"]}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000030504', 'aaaa1111-0000-4000-8000-000000000305', 'fill_in_blank',
   'Complete: "Is the pain constant, or does it come and ____?"', 'go',
   '"Come and go" is the fixed expression for intermittent symptoms.', '"Come and go" es la expresión fija para síntomas intermitentes.', 'intermediate', 10, 3,
   '{"acceptable_answers":["go"],"case_sensitive":false,"blank_position":"end","word_bank":["go","leave","stop","return"]}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000030505', 'aaaa1111-0000-4000-8000-000000000305', 'typing',
   'Translate to English: "síntoma"', 'symptom',
   'Note the spelling: symptom, with a silent p before the t? No — the p is pronounced lightly: /ˈsɪmp.təm/.', 'Ojo con la ortografía: "symptom" se pronuncia /ˈsɪmp.təm/.', 'intermediate', 10, 4,
   '{"acceptable_answers":["symptom","a symptom"],"case_sensitive":false,"max_length":30,"placeholder":"Type the English term..."}'::jsonb, TRUE),
  ('aaaa2222-0000-4000-8000-000000030506', 'aaaa1111-0000-4000-8000-000000000305', 'pronunciation',
   'Say this question aloud: "Can you describe the pain for me?"', 'Can you describe the pain for me?',
   'An open question that invites the patient''s own words — the Q of OPQRST.', 'Una pregunta abierta que invita al paciente a usar sus propias palabras — la Q de OPQRST.', 'intermediate', 10, 5,
   '{"word":"Can you describe the pain for me?","phonetic":"/kæn juː dɪˈskraɪb ðə peɪn fɔːr miː/","minimum_score":60,"common_mistakes":[{"mistake":"describe-eh","correction":"describe — the final e is silent"}],"definition_es":"¿Puede describirme el dolor?"}'::jsonb, TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order, match_pair_id)
VALUES
  ('aaaa2222-0000-4000-8000-000000030501', 'mild', TRUE, 0, 'p1'),
  ('aaaa2222-0000-4000-8000-000000030501', 'leve', TRUE, 1, 'p1'),
  ('aaaa2222-0000-4000-8000-000000030501', 'severe', TRUE, 2, 'p2'),
  ('aaaa2222-0000-4000-8000-000000030501', 'intenso', TRUE, 3, 'p2'),
  ('aaaa2222-0000-4000-8000-000000030501', 'constant', TRUE, 4, 'p3'),
  ('aaaa2222-0000-4000-8000-000000030501', 'constante', TRUE, 5, 'p3'),
  ('aaaa2222-0000-4000-8000-000000030501', 'worsening', TRUE, 6, 'p4'),
  ('aaaa2222-0000-4000-8000-000000030501', 'empeoramiento', TRUE, 7, 'p4'),
  ('aaaa2222-0000-4000-8000-000000030502', 'It comes and goes.', TRUE, 0, NULL),
  ('aaaa2222-0000-4000-8000-000000030502', 'It never stops.', FALSE, 1, NULL),
  ('aaaa2222-0000-4000-8000-000000030502', 'It is getting worse.', FALSE, 2, NULL),
  ('aaaa2222-0000-4000-8000-000000030502', 'It is very mild.', FALSE, 3, NULL)
ON CONFLICT DO NOTHING;

-- Vocabulary -----------------------------------------------------------------
-- Anatomy (Module 2) + Symptoms & Pain (Module 3). AI-drafted, published for
-- MVP; physician validation pending. UUIDs start 'aaaa9' to avoid collisions.
INSERT INTO vocabulary (id, word, phonetic, translation_es, definition_en, definition_es, example_en, example_es, category, difficulty, tags, is_published)
VALUES
  ('aaaa9000-0000-4000-8000-000000000201', 'skull', '/skʌl/', 'cráneo',
   'The bony structure of the head that protects the brain.', 'Estructura ósea de la cabeza que protege el cerebro.',
   'The X-ray showed no fracture of the skull.', 'La radiografía no mostró fractura del cráneo.', 'anatomy', 'beginner', ARRAY['head'], TRUE),
  ('aaaa9000-0000-4000-8000-000000000202', 'jaw', '/dʒɔː/', 'mandíbula',
   'The lower bony part of the face that holds the teeth.', 'Parte ósea inferior de la cara que sostiene los dientes.',
   'Does it hurt when you open your jaw?', '¿Le duele al abrir la mandíbula?', 'anatomy', 'beginner', ARRAY['head'], TRUE),
  ('aaaa9000-0000-4000-8000-000000000203', 'throat', '/θroʊt/', 'garganta',
   'The passage from the mouth to the esophagus and airway.', 'Conducto de la boca al esófago y la vía aérea.',
   'Your throat looks red and inflamed.', 'Su garganta se ve roja e inflamada.', 'anatomy', 'beginner', ARRAY['neck'], TRUE),
  ('aaaa9000-0000-4000-8000-000000000204', 'chest', '/tʃɛst/', 'pecho / tórax',
   'The front of the body between the neck and the abdomen.', 'Parte frontal del cuerpo entre el cuello y el abdomen.',
   'Do you feel any pain in your chest?', '¿Siente algún dolor en el pecho?', 'anatomy', 'beginner', ARRAY['thorax'], TRUE),
  ('aaaa9000-0000-4000-8000-000000000205', 'lung', '/lʌŋ/', 'pulmón',
   'One of the two organs used for breathing.', 'Uno de los dos órganos usados para respirar.',
   'I am going to listen to your lungs now.', 'Voy a auscultar sus pulmones ahora.', 'anatomy', 'beginner', ARRAY['respiratory'], TRUE),
  ('aaaa9000-0000-4000-8000-000000000206', 'heart', '/hɑːrt/', 'corazón',
   'The muscular organ that pumps blood through the body.', 'Órgano muscular que bombea sangre por el cuerpo.',
   'Your heart rate is normal.', 'Su frecuencia cardíaca es normal.', 'anatomy', 'beginner', ARRAY['cardiovascular'], TRUE),
  ('aaaa9000-0000-4000-8000-000000000207', 'rib', '/rɪb/', 'costilla',
   'One of the curved bones that protect the chest.', 'Uno de los huesos curvos que protegen el tórax.',
   'You may have bruised a rib.', 'Puede que se haya lastimado una costilla.', 'anatomy', 'beginner', ARRAY['thorax'], TRUE),
  ('aaaa9000-0000-4000-8000-000000000208', 'abdomen', '/ˈæb.də.mən/', 'abdomen',
   'The part of the body containing the digestive organs.', 'Parte del cuerpo que contiene los órganos digestivos.',
   'I will press on your abdomen; tell me if it hurts.', 'Voy a presionar su abdomen; dígame si le duele.', 'anatomy', 'beginner', ARRAY['abdomen'], TRUE),
  ('aaaa9000-0000-4000-8000-000000000209', 'stomach', '/ˈstʌm.ək/', 'estómago',
   'The organ where food is digested after swallowing.', 'Órgano donde se digiere el alimento tras tragar.',
   'Do you feel pain in your stomach after eating?', '¿Siente dolor en el estómago después de comer?', 'anatomy', 'beginner', ARRAY['digestive'], TRUE),
  ('aaaa9000-0000-4000-8000-000000000210', 'liver', '/ˈlɪv.ər/', 'hígado',
   'The large organ that filters blood and processes nutrients.', 'Órgano grande que filtra la sangre y procesa nutrientes.',
   'Your liver function tests are normal.', 'Sus pruebas de función hepática son normales.', 'anatomy', 'intermediate', ARRAY['digestive'], TRUE),
  ('aaaa9000-0000-4000-8000-000000000211', 'kidney', '/ˈkɪd.ni/', 'riñón',
   'One of two organs that filter waste and produce urine.', 'Uno de dos órganos que filtran desechos y producen orina.',
   'The stone is located in your left kidney.', 'La piedra está en su riñón izquierdo.', 'anatomy', 'intermediate', ARRAY['urinary'], TRUE),
  ('aaaa9000-0000-4000-8000-000000000212', 'spine', '/spaɪn/', 'columna vertebral',
   'The column of bones that supports the back.', 'Columna de huesos que sostiene la espalda.',
   'Please keep your spine straight.', 'Por favor mantenga la columna recta.', 'anatomy', 'intermediate', ARRAY['musculoskeletal'], TRUE),
  ('aaaa9000-0000-4000-8000-000000000213', 'joint', '/dʒɔɪnt/', 'articulación',
   'The place where two bones meet and allow movement.', 'Lugar donde se unen dos huesos y permiten el movimiento.',
   'Which joint is swollen?', '¿Qué articulación está inflamada?', 'anatomy', 'beginner', ARRAY['musculoskeletal'], TRUE),
  ('aaaa9000-0000-4000-8000-000000000214', 'muscle', '/ˈmʌs.əl/', 'músculo',
   'Tissue that contracts to produce movement.', 'Tejido que se contrae para producir movimiento.',
   'You may have strained a muscle in your back.', 'Puede que se haya distendido un músculo de la espalda.', 'anatomy', 'beginner', ARRAY['musculoskeletal'], TRUE),
  ('aaaa9000-0000-4000-8000-000000000301', 'sharp', '/ʃɑːrp/', 'agudo / punzante',
   'A sudden, intense, well-localized type of pain.', 'Dolor súbito, intenso y bien localizado.',
   'Is the pain sharp or dull?', '¿El dolor es punzante o sordo?', 'general', 'intermediate', ARRAY['pain'], TRUE),
  ('aaaa9000-0000-4000-8000-000000000302', 'dull', '/dʌl/', 'sordo',
   'A vague, aching type of pain that is hard to localize.', 'Dolor vago y molesto, difícil de localizar.',
   'She described a dull ache in her lower back.', 'Describió un dolor sordo en la zona lumbar.', 'general', 'intermediate', ARRAY['pain'], TRUE),
  ('aaaa9000-0000-4000-8000-000000000303', 'throbbing', '/ˈθrɒb.ɪŋ/', 'pulsátil',
   'Pain that beats in a rhythm, like a pulse.', 'Dolor que late con un ritmo, como el pulso.',
   'The headache is throbbing behind my eyes.', 'El dolor de cabeza es pulsátil detrás de los ojos.', 'general', 'intermediate', ARRAY['pain'], TRUE),
  ('aaaa9000-0000-4000-8000-000000000304', 'burning', '/ˈbɜːrn.ɪŋ/', 'ardor / quemante',
   'A hot, stinging type of pain.', 'Dolor caliente y punzante, como quemadura.',
   'Patients with reflux often report a burning sensation.', 'Los pacientes con reflujo suelen referir ardor.', 'general', 'intermediate', ARRAY['pain'], TRUE),
  ('aaaa9000-0000-4000-8000-000000000305', 'radiating', '/ˈreɪ.di.eɪ.tɪŋ/', 'irradiado',
   'Pain that spreads from one area to another.', 'Dolor que se extiende de una zona a otra.',
   'The chest pain is radiating to your left arm.', 'El dolor de pecho se irradia al brazo izquierdo.', 'general', 'advanced', ARRAY['pain'], TRUE),
  ('aaaa9000-0000-4000-8000-000000000306', 'tender', '/ˈtɛn.dər/', 'sensible / doloroso al tacto',
   'Painful when touched or pressed.', 'Que duele al tocar o presionar.',
   'Your abdomen is tender in the lower right area.', 'Su abdomen está sensible en la zona inferior derecha.', 'general', 'intermediate', ARRAY['pain'], TRUE),
  ('aaaa9000-0000-4000-8000-000000000307', 'swelling', '/ˈswɛl.ɪŋ/', 'hinchazón / edema',
   'An abnormal enlargement of a body part.', 'Aumento anormal del tamaño de una parte del cuerpo.',
   'When did the swelling in your ankle begin?', '¿Cuándo comenzó la hinchazón en su tobillo?', 'pathology', 'intermediate', ARRAY['symptom'], TRUE),
  ('aaaa9000-0000-4000-8000-000000000308', 'dizziness', '/ˈdɪz.i.nəs/', 'mareo',
   'A feeling of being unsteady or lightheaded.', 'Sensación de inestabilidad o aturdimiento.',
   'Do you have any dizziness when you stand up?', '¿Tiene mareo al ponerse de pie?', 'general', 'beginner', ARRAY['symptom'], TRUE),
  ('aaaa9000-0000-4000-8000-000000000309', 'nausea', '/ˈnɔː.zi.ə/', 'náusea',
   'The feeling of wanting to vomit.', 'Sensación de querer vomitar.',
   'Have you had any nausea or vomiting?', '¿Ha tenido náuseas o vómitos?', 'general', 'beginner', ARRAY['symptom'], TRUE),
  ('aaaa9000-0000-4000-8000-000000000310', 'shortness of breath', '/ˈʃɔːrt.nəs əv brɛθ/', 'falta de aire / disnea',
   'Difficulty breathing or feeling unable to get enough air.', 'Dificultad para respirar o sensación de falta de aire.',
   'Do you have shortness of breath when you climb stairs?', '¿Tiene falta de aire al subir escaleras?', 'general', 'intermediate', ARRAY['symptom'], TRUE),
  ('aaaa9000-0000-4000-8000-000000000311', 'fatigue', '/fəˈtiːɡ/', 'fatiga / cansancio',
   'Extreme tiredness that does not improve with rest.', 'Cansancio extremo que no mejora con el descanso.',
   'The fatigue has lasted for several weeks.', 'La fatiga ha durado varias semanas.', 'general', 'intermediate', ARRAY['symptom'], TRUE),
  ('aaaa9000-0000-4000-8000-000000000312', 'fever', '/ˈfiː.vər/', 'fiebre',
   'A body temperature that is higher than normal.', 'Temperatura corporal más alta de lo normal.',
   'Have you had a fever in the last few days?', '¿Ha tenido fiebre en los últimos días?', 'general', 'beginner', ARRAY['symptom'], TRUE)
ON CONFLICT (id) DO NOTHING;

-- Lesson ↔ vocabulary links ---------------------------------------------------
INSERT INTO lesson_vocabulary (lesson_id, vocabulary_id, sort_order)
VALUES
  ('aaaa1111-0000-4000-8000-000000000201', 'aaaa9000-0000-4000-8000-000000000201', 0),
  ('aaaa1111-0000-4000-8000-000000000201', 'aaaa9000-0000-4000-8000-000000000202', 1),
  ('aaaa1111-0000-4000-8000-000000000201', 'aaaa9000-0000-4000-8000-000000000203', 2),
  ('aaaa1111-0000-4000-8000-000000000202', 'aaaa9000-0000-4000-8000-000000000204', 0),
  ('aaaa1111-0000-4000-8000-000000000202', 'aaaa9000-0000-4000-8000-000000000205', 1),
  ('aaaa1111-0000-4000-8000-000000000202', 'aaaa9000-0000-4000-8000-000000000206', 2),
  ('aaaa1111-0000-4000-8000-000000000202', 'aaaa9000-0000-4000-8000-000000000207', 3),
  ('aaaa1111-0000-4000-8000-000000000203', 'aaaa9000-0000-4000-8000-000000000208', 0),
  ('aaaa1111-0000-4000-8000-000000000203', 'aaaa9000-0000-4000-8000-000000000209', 1),
  ('aaaa1111-0000-4000-8000-000000000203', 'aaaa9000-0000-4000-8000-000000000210', 2),
  ('aaaa1111-0000-4000-8000-000000000203', 'aaaa9000-0000-4000-8000-000000000211', 3),
  ('aaaa1111-0000-4000-8000-000000000204', 'aaaa9000-0000-4000-8000-000000000212', 0),
  ('aaaa1111-0000-4000-8000-000000000204', 'aaaa9000-0000-4000-8000-000000000213', 1),
  ('aaaa1111-0000-4000-8000-000000000204', 'aaaa9000-0000-4000-8000-000000000214', 2),
  ('aaaa1111-0000-4000-8000-000000000301', 'aaaa9000-0000-4000-8000-000000000301', 0),
  ('aaaa1111-0000-4000-8000-000000000301', 'aaaa9000-0000-4000-8000-000000000302', 1),
  ('aaaa1111-0000-4000-8000-000000000301', 'aaaa9000-0000-4000-8000-000000000303', 2),
  ('aaaa1111-0000-4000-8000-000000000301', 'aaaa9000-0000-4000-8000-000000000304', 3),
  ('aaaa1111-0000-4000-8000-000000000301', 'aaaa9000-0000-4000-8000-000000000305', 4),
  ('aaaa1111-0000-4000-8000-000000000302', 'aaaa9000-0000-4000-8000-000000000306', 0),
  ('aaaa1111-0000-4000-8000-000000000303', 'aaaa9000-0000-4000-8000-000000000307', 0),
  ('aaaa1111-0000-4000-8000-000000000303', 'aaaa9000-0000-4000-8000-000000000308', 1),
  ('aaaa1111-0000-4000-8000-000000000303', 'aaaa9000-0000-4000-8000-000000000309', 2),
  ('aaaa1111-0000-4000-8000-000000000303', 'aaaa9000-0000-4000-8000-000000000310', 3),
  ('aaaa1111-0000-4000-8000-000000000303', 'aaaa9000-0000-4000-8000-000000000311', 4),
  ('aaaa1111-0000-4000-8000-000000000303', 'aaaa9000-0000-4000-8000-000000000312', 5)
ON CONFLICT DO NOTHING;

-- ---- from 02_modules_4_6.sql ----
-- ============================================================================
-- MediLingo — Seed: Modules 4-6 for course 'medical-english-essentials'
-- AI-drafted content — pending physician validation (content pipeline:
-- AI draft → physician validates → publish).
-- Module 4: Taking a Medical History
-- Module 5: The Physical Examination
-- Module 6: Medications & Pharmacy
-- All UUIDs minted here start with 'bbbb' (parallel-author collision avoidance).
-- ============================================================================

-- Modules --------------------------------------------------------------------
INSERT INTO modules (id, course_id, slug, title, description, sort_order, is_published)
VALUES
  ('bbbb0000-0000-4000-8000-000000000004', '11111111-1111-1111-1111-111111111111',
   'medical-history', 'Taking a Medical History',
   'Past medical history, family history, social history, allergies, and the review of systems.',
   3, TRUE),
  ('bbbb0000-0000-4000-8000-000000000005', '11111111-1111-1111-1111-111111111111',
   'physical-examination', 'The Physical Examination',
   'Giving exam instructions and describing findings from head to toe.',
   4, TRUE),
  ('bbbb0000-0000-4000-8000-000000000006', '11111111-1111-1111-1111-111111111111',
   'medications-pharmacy', 'Medications & Pharmacy',
   'Drug names and classes, dosage, prescriptions, side effects, and patient counseling.',
   5, TRUE)
ON CONFLICT (id) DO NOTHING;

-- Lessons: Module 4 — Taking a Medical History --------------------------------
INSERT INTO lessons (id, module_id, slug, title, description, lesson_type, difficulty, estimated_minutes, xp_reward, sort_order, is_published, intro_text, completion_text)
VALUES
  ('bbbb0401-0000-4000-8000-000000000000', 'bbbb0000-0000-4000-8000-000000000004', 'past-medical-history',
   'Past Medical History', 'Ask about previous illnesses, surgeries, and hospitalizations.', 'standard', 'beginner', 6, 50, 0, TRUE,
   'Learn to ask about a patient''s previous illnesses, surgeries, and hospitalizations.',
   'Excellent! You can now take a past medical history in English.'),
  ('bbbb0402-0000-4000-8000-000000000000', 'bbbb0000-0000-4000-8000-000000000004', 'family-history',
   'Family History', 'Ask about hereditary conditions and the health of relatives.', 'standard', 'beginner', 5, 50, 1, TRUE,
   'Learn to ask about hereditary conditions and the health of the patient''s relatives.',
   'Well done! You can now explore a patient''s family history.'),
  ('bbbb0403-0000-4000-8000-000000000000', 'bbbb0000-0000-4000-8000-000000000004', 'social-history',
   'Social History', 'Ask about occupation, lifestyle, and living situation.', 'standard', 'beginner', 6, 50, 2, TRUE,
   'Learn to ask about occupation, lifestyle, and living situation with sensitivity.',
   'Great job! You can now take a social history in English.'),
  ('bbbb0404-0000-4000-8000-000000000000', 'bbbb0000-0000-4000-8000-000000000004', 'allergies-and-habits',
   'Allergies & Habits', 'Ask about drug allergies, smoking, alcohol, and other habits.', 'standard', 'intermediate', 7, 50, 3, TRUE,
   'Learn to ask about drug allergies and habits such as smoking and alcohol use.',
   'Excellent! You can now screen for allergies and habits safely.'),
  ('bbbb0405-0000-4000-8000-000000000000', 'bbbb0000-0000-4000-8000-000000000004', 'review-of-systems',
   'Review of Systems', 'Screen for symptoms in each body system.', 'standard', 'intermediate', 8, 50, 4, TRUE,
   'Learn the questions of the review of systems, screening each body system for symptoms.',
   'Outstanding! You can now complete a full medical history in English.')
ON CONFLICT (id) DO NOTHING;

-- Lessons: Module 5 — The Physical Examination --------------------------------
INSERT INTO lessons (id, module_id, slug, title, description, lesson_type, difficulty, estimated_minutes, xp_reward, sort_order, is_published, intro_text, completion_text)
VALUES
  ('bbbb0501-0000-4000-8000-000000000000', 'bbbb0000-0000-4000-8000-000000000005', 'exam-instructions',
   'Giving Exam Instructions', 'Direct the patient clearly and politely during the exam.', 'standard', 'beginner', 6, 50, 0, TRUE,
   'Learn to give clear, polite instructions during the physical examination.',
   'Great work! Your patients will always know what to do next.'),
  ('bbbb0502-0000-4000-8000-000000000000', 'bbbb0000-0000-4000-8000-000000000005', 'head-and-neck',
   'Head & Neck Exam', 'Vocabulary and phrases for examining the head and neck.', 'standard', 'beginner', 6, 50, 1, TRUE,
   'Learn the vocabulary and phrases for the head and neck examination.',
   'Well done! You can now examine the head and neck in English.'),
  ('bbbb0503-0000-4000-8000-000000000000', 'bbbb0000-0000-4000-8000-000000000005', 'chest-and-lungs',
   'Chest & Lungs', 'Auscultation, percussion, and describing breath sounds.', 'standard', 'intermediate', 7, 50, 2, TRUE,
   'Learn to guide a chest exam and describe breath sounds in English.',
   'Excellent! You can now perform a chest exam in English.'),
  ('bbbb0504-0000-4000-8000-000000000000', 'bbbb0000-0000-4000-8000-000000000005', 'abdomen',
   'Examining the Abdomen', 'Palpation, tenderness, and abdominal findings.', 'standard', 'intermediate', 7, 50, 3, TRUE,
   'Learn the language of the abdominal exam: palpation, tenderness, and findings.',
   'Great job! You can now examine the abdomen in English.'),
  ('bbbb0505-0000-4000-8000-000000000000', 'bbbb0000-0000-4000-8000-000000000005', 'neuro-basics',
   'Neuro Exam Basics', 'Reflexes, sensation, coordination, and gait.', 'standard', 'intermediate', 8, 50, 4, TRUE,
   'Learn to test reflexes, sensation, coordination, and gait in English.',
   'Outstanding! You can now run a basic neurological exam in English.')
ON CONFLICT (id) DO NOTHING;

-- Lessons: Module 6 — Medications & Pharmacy ----------------------------------
INSERT INTO lessons (id, module_id, slug, title, description, lesson_type, difficulty, estimated_minutes, xp_reward, sort_order, is_published, intro_text, completion_text)
VALUES
  ('bbbb0601-0000-4000-8000-000000000000', 'bbbb0000-0000-4000-8000-000000000006', 'drug-names-and-classes',
   'Drug Names & Classes', 'Generic vs. brand names and the major drug classes.', 'standard', 'beginner', 6, 50, 0, TRUE,
   'Learn generic vs. brand names and the major drug classes in English.',
   'Great work! You can now talk about drug names and classes.'),
  ('bbbb0602-0000-4000-8000-000000000000', 'bbbb0000-0000-4000-8000-000000000006', 'dosage-and-frequency',
   'Dosage & Frequency', 'Doses, routes, and how often to take a medication.', 'standard', 'intermediate', 6, 50, 1, TRUE,
   'Learn to state doses and dosing frequency, including common Latin abbreviations.',
   'Well done! You can now give clear dosing instructions.'),
  ('bbbb0603-0000-4000-8000-000000000000', 'bbbb0000-0000-4000-8000-000000000006', 'prescriptions',
   'Prescriptions & Refills', 'Writing, filling, and refilling prescriptions.', 'standard', 'intermediate', 7, 50, 2, TRUE,
   'Learn the language of prescriptions, refills, and the pharmacy counter.',
   'Excellent! You can now handle prescriptions in English.'),
  ('bbbb0604-0000-4000-8000-000000000000', 'bbbb0000-0000-4000-8000-000000000006', 'side-effects',
   'Side Effects', 'Warning patients about common and serious side effects.', 'standard', 'intermediate', 7, 50, 3, TRUE,
   'Learn to explain common and serious side effects to your patients.',
   'Great job! You can now counsel patients about side effects.'),
  ('bbbb0605-0000-4000-8000-000000000000', 'bbbb0000-0000-4000-8000-000000000006', 'patient-counseling',
   'Patient Counseling', 'Teach-back, adherence, and safe medication use.', 'standard', 'intermediate', 8, 50, 4, TRUE,
   'Learn counseling phrases: teach-back, adherence, and safe medication use.',
   'Outstanding! You can now counsel patients on their medications in English.')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- Module 4 exercises
-- ============================================================================

-- Lesson 4.1: Past Medical History --------------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, xp_reward, sort_order, metadata, is_published)
VALUES
  ('bbbb0401-0001-4000-8000-000000000000', 'bbbb0401-0000-4000-8000-000000000000', 'multiple_choice',
   'Which question best asks about a patient''s past medical history?',
   'Have you ever been diagnosed with any medical conditions?',
   '"Have you ever been diagnosed with...?" uses the present perfect to ask about the patient''s entire life up to now.',
   '"Have you ever been diagnosed with...?" usa el presente perfecto para preguntar sobre toda la vida del paciente hasta ahora.',
   10, 0, '{"shuffle_options": true}'::jsonb, TRUE),
  ('bbbb0401-0002-4000-8000-000000000000', 'bbbb0401-0000-4000-8000-000000000000', 'translation',
   'Translate to English: "¿Alguna vez lo han hospitalizado?"',
   'Have you ever been hospitalized?',
   'The passive present perfect ("have you ever been...") is the natural form for asking about past hospitalizations.',
   'El presente perfecto en voz pasiva ("have you ever been...") es la forma natural de preguntar por hospitalizaciones previas.',
   10, 1,
   '{"source_language": "es", "target_language": "en", "source_text": "¿Alguna vez lo han hospitalizado?", "acceptable_translations": ["Have you ever been hospitalized?", "Have you ever been admitted to the hospital?"], "key_terms": ["hospitalized"]}'::jsonb, TRUE),
  ('bbbb0401-0003-4000-8000-000000000000', 'bbbb0401-0000-4000-8000-000000000000', 'fill_in_blank',
   'Complete: "Have you ever had any ____ or operations?"',
   'surgeries',
   '"Surgeries" and "operations" are near-synonyms; asking with both makes the question clear to every patient.',
   '"Surgeries" y "operations" son casi sinónimos; preguntar con ambos hace la pregunta clara para cualquier paciente.',
   10, 2,
   '{"acceptable_answers": ["surgeries", "surgery"], "case_sensitive": false, "blank_position": "inline"}'::jsonb, TRUE),
  ('bbbb0401-0004-4000-8000-000000000000', 'bbbb0401-0000-4000-8000-000000000000', 'matching',
   'Match the English conditions with their Spanish translations.',
   'hypertension—hipertensión; diabetes—diabetes; asthma—asma; surgery—cirugía',
   'These chronic conditions appear constantly in the past medical history.',
   'Estas enfermedades crónicas aparecen constantemente en los antecedentes médicos.',
   10, 3, '{"columns": 2}'::jsonb, TRUE),
  ('bbbb0401-0005-4000-8000-000000000000', 'bbbb0401-0000-4000-8000-000000000000', 'flashcard',
   'chronic condition', 'enfermedad crónica',
   'A health problem that lasts a long time, often for the rest of the patient''s life.',
   'Un problema de salud que dura mucho tiempo, a menudo por el resto de la vida del paciente.',
   10, 4,
   '{"front": {"text": "chronic condition", "subtext": "/ˈkrɒnɪk kənˈdɪʃən/"}, "back": {"text": "enfermedad crónica", "translation": "enfermedad crónica", "example": "Diabetes is a chronic condition that requires daily management."}}'::jsonb, TRUE),
  ('bbbb0401-0006-4000-8000-000000000000', 'bbbb0401-0000-4000-8000-000000000000', 'pronunciation',
   'Say: "Have you ever been hospitalized?"',
   'Have you ever been hospitalized?',
   'Stress the third syllable of "HOS-pi-ta-lized" and link "been" and "hospitalized" smoothly.',
   'Acentúa la primera sílaba de "HOS-pi-ta-lized" y enlaza "been" con "hospitalized" con fluidez.',
   10, 5,
   '{"word": "Have you ever been hospitalized?", "phonetic": "/hæv juː ˈevər bɪn ˈhɑːspɪtəlaɪzd/", "minimum_score": 60, "common_mistakes": [{"mistake": "hospitalisated", "correction": "hospitalized"}]}'::jsonb, TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('bbbb0401-0001-4000-8000-000000000000', 'Have you ever been diagnosed with any medical conditions?', TRUE, 0),
  ('bbbb0401-0001-4000-8000-000000000000', 'Do you have sickness before?', FALSE, 1),
  ('bbbb0401-0001-4000-8000-000000000000', 'What diseases you got in the past?', FALSE, 2),
  ('bbbb0401-0001-4000-8000-000000000000', 'Are you a sick person historically?', FALSE, 3)
ON CONFLICT DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, match_pair_id, sort_order)
VALUES
  ('bbbb0401-0004-4000-8000-000000000000', 'hypertension', 'pair1', 0),
  ('bbbb0401-0004-4000-8000-000000000000', 'hipertensión', 'pair1', 1),
  ('bbbb0401-0004-4000-8000-000000000000', 'diabetes', 'pair2', 2),
  ('bbbb0401-0004-4000-8000-000000000000', 'diabetes (enfermedad)', 'pair2', 3),
  ('bbbb0401-0004-4000-8000-000000000000', 'asthma', 'pair3', 4),
  ('bbbb0401-0004-4000-8000-000000000000', 'asma', 'pair3', 5),
  ('bbbb0401-0004-4000-8000-000000000000', 'surgery', 'pair4', 6),
  ('bbbb0401-0004-4000-8000-000000000000', 'cirugía', 'pair4', 7)
ON CONFLICT DO NOTHING;

-- Lesson 4.2: Family History ---------------------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, xp_reward, sort_order, metadata, is_published)
VALUES
  ('bbbb0402-0001-4000-8000-000000000000', 'bbbb0402-0000-4000-8000-000000000000', 'multiple_choice',
   'Which question best opens the family history?',
   'Does anyone in your family have any serious medical conditions?',
   'An open question about the whole family lets the patient mention any relevant relative before you ask about specific diseases.',
   'Una pregunta abierta sobre toda la familia permite que el paciente mencione a cualquier familiar relevante antes de preguntar por enfermedades específicas.',
   10, 0, '{"shuffle_options": true}'::jsonb, TRUE),
  ('bbbb0402-0002-4000-8000-000000000000', 'bbbb0402-0000-4000-8000-000000000000', 'fill_in_blank',
   'Complete: "Is there any family ____ of cancer?"',
   'history',
   '"Family history of..." is the standard collocation for hereditary risk.',
   '"Family history of..." es la colocación estándar para el riesgo hereditario.',
   10, 1,
   '{"acceptable_answers": ["history"], "case_sensitive": false, "blank_position": "inline"}'::jsonb, TRUE),
  ('bbbb0402-0003-4000-8000-000000000000', 'bbbb0402-0000-4000-8000-000000000000', 'sentence_ordering',
   'Put the words in order to ask about the patient''s father.',
   'Does your father have high blood pressure?',
   'English questions with "does" keep the main verb ("have") in its base form.',
   'Las preguntas con "does" mantienen el verbo principal ("have") en su forma base.',
   10, 2,
   '{"words": ["Does", "your", "father", "have", "high", "blood", "pressure?"], "show_punctuation": true}'::jsonb, TRUE),
  ('bbbb0402-0004-4000-8000-000000000000', 'bbbb0402-0000-4000-8000-000000000000', 'typing',
   'Type the English word for "hereditario".',
   'hereditary',
   '"Hereditary" describes conditions passed from parents to children through genes.',
   '"Hereditary" describe enfermedades que pasan de padres a hijos a través de los genes.',
   10, 3,
   '{"acceptable_answers": ["hereditary"], "case_sensitive": false, "placeholder": "Type your answer..."}'::jsonb, TRUE),
  ('bbbb0402-0005-4000-8000-000000000000', 'bbbb0402-0000-4000-8000-000000000000', 'flashcard',
   'first-degree relative', 'familiar de primer grado',
   'A parent, sibling, or child — the relatives who share the most genetic risk.',
   'Padre, madre, hermano o hijo: los familiares que comparten mayor riesgo genético.',
   10, 4,
   '{"front": {"text": "first-degree relative", "subtext": "/fɜːrst dɪˈɡriː ˈrelətɪv/"}, "back": {"text": "familiar de primer grado", "translation": "familiar de primer grado", "example": "Do any of your first-degree relatives have diabetes?"}}'::jsonb, TRUE),
  ('bbbb0402-0006-4000-8000-000000000000', 'bbbb0402-0000-4000-8000-000000000000', 'translation',
   'Translate to English: "Mi madre falleció de un derrame cerebral."',
   'My mother passed away from a stroke.',
   '"Passed away" is the gentle, professional way to say "died"; "stroke" is the everyday word for "derrame cerebral".',
   '"Passed away" es la forma delicada y profesional de decir "died"; "stroke" es la palabra común para "derrame cerebral".',
   10, 5,
   '{"source_language": "es", "target_language": "en", "source_text": "Mi madre falleció de un derrame cerebral.", "acceptable_translations": ["My mother passed away from a stroke.", "My mother died of a stroke.", "My mother died from a stroke."], "key_terms": ["passed away", "stroke"]}'::jsonb, TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('bbbb0402-0001-4000-8000-000000000000', 'Does anyone in your family have any serious medical conditions?', TRUE, 0),
  ('bbbb0402-0001-4000-8000-000000000000', 'Is your family sick a lot?', FALSE, 1),
  ('bbbb0402-0001-4000-8000-000000000000', 'Tell me the diseases of all your relatives now.', FALSE, 2),
  ('bbbb0402-0001-4000-8000-000000000000', 'Your family has problems, yes?', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Lesson 4.3: Social History ---------------------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, xp_reward, sort_order, metadata, is_published)
VALUES
  ('bbbb0403-0001-4000-8000-000000000000', 'bbbb0403-0000-4000-8000-000000000000', 'multiple_choice',
   'Which question politely asks about a patient''s occupation?',
   'What do you do for a living?',
   '"What do you do for a living?" is the natural, neutral way to ask about someone''s job.',
   '"What do you do for a living?" es la forma natural y neutral de preguntar por el trabajo de alguien.',
   10, 0, '{"shuffle_options": true}'::jsonb, TRUE),
  ('bbbb0403-0002-4000-8000-000000000000', 'bbbb0403-0000-4000-8000-000000000000', 'matching',
   'Match the English social history terms with their Spanish translations.',
   'occupation—ocupación; lifestyle—estilo de vida; retirement—jubilación; stress—estrés',
   'These terms structure the social history interview.',
   'Estos términos estructuran la entrevista de historia social.',
   10, 1, '{"columns": 2}'::jsonb, TRUE),
  ('bbbb0403-0003-4000-8000-000000000000', 'bbbb0403-0000-4000-8000-000000000000', 'translation',
   'Translate to English: "¿Con quién vive usted?"',
   'Who do you live with?',
   'Ending with the preposition ("live with") is completely natural in spoken English.',
   'Terminar con la preposición ("live with") es completamente natural en el inglés hablado.',
   10, 2,
   '{"source_language": "es", "target_language": "en", "source_text": "¿Con quién vive usted?", "acceptable_translations": ["Who do you live with?", "With whom do you live?"], "key_terms": ["live with"]}'::jsonb, TRUE),
  ('bbbb0403-0004-4000-8000-000000000000', 'bbbb0403-0000-4000-8000-000000000000', 'sentence_ordering',
   'Put the words in order to ask about exercise habits.',
   'How often do you exercise?',
   '"How often" asks about frequency; it is the key phrase for lifestyle questions.',
   '"How often" pregunta por la frecuencia; es la frase clave para preguntas de estilo de vida.',
   10, 3,
   '{"words": ["How", "often", "do", "you", "exercise?"], "show_punctuation": true}'::jsonb, TRUE),
  ('bbbb0403-0005-4000-8000-000000000000', 'bbbb0403-0000-4000-8000-000000000000', 'pronunciation',
   'Say: "What do you do for a living?"',
   'What do you do for a living?',
   'In natural speech "What do you" often reduces to "Whaddaya"; keep the stress on "do" and "living".',
   'En el habla natural "What do you" suele reducirse a "Whaddaya"; mantén el acento en "do" y "living".',
   10, 4,
   '{"word": "What do you do for a living?", "phonetic": "/wʌt duː juː duː fər ə ˈlɪvɪŋ/", "minimum_score": 60, "common_mistakes": [{"mistake": "leaving", "correction": "living"}]}'::jsonb, TRUE),
  ('bbbb0403-0006-4000-8000-000000000000', 'bbbb0403-0000-4000-8000-000000000000', 'fill_in_blank',
   'Complete: "Do you have a good support ____ at home?"',
   'system',
   'A "support system" is the network of family and friends who help the patient.',
   'Un "support system" es la red de familiares y amigos que apoyan al paciente.',
   10, 5,
   '{"acceptable_answers": ["system"], "case_sensitive": false, "blank_position": "inline"}'::jsonb, TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('bbbb0403-0001-4000-8000-000000000000', 'What do you do for a living?', TRUE, 0),
  ('bbbb0403-0001-4000-8000-000000000000', 'How much money do you make?', FALSE, 1),
  ('bbbb0403-0001-4000-8000-000000000000', 'Do you even have a job?', FALSE, 2),
  ('bbbb0403-0001-4000-8000-000000000000', 'Where is your work at?', FALSE, 3)
ON CONFLICT DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, match_pair_id, sort_order)
VALUES
  ('bbbb0403-0002-4000-8000-000000000000', 'occupation', 'pair1', 0),
  ('bbbb0403-0002-4000-8000-000000000000', 'ocupación', 'pair1', 1),
  ('bbbb0403-0002-4000-8000-000000000000', 'lifestyle', 'pair2', 2),
  ('bbbb0403-0002-4000-8000-000000000000', 'estilo de vida', 'pair2', 3),
  ('bbbb0403-0002-4000-8000-000000000000', 'retirement', 'pair3', 4),
  ('bbbb0403-0002-4000-8000-000000000000', 'jubilación', 'pair3', 5),
  ('bbbb0403-0002-4000-8000-000000000000', 'stress', 'pair4', 6),
  ('bbbb0403-0002-4000-8000-000000000000', 'estrés', 'pair4', 7)
ON CONFLICT DO NOTHING;

-- Lesson 4.4: Allergies & Habits ------------------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, xp_reward, sort_order, metadata, is_published)
VALUES
  ('bbbb0404-0001-4000-8000-000000000000', 'bbbb0404-0000-4000-8000-000000000000', 'multiple_choice',
   'A patient says: "I break out in hives when I take penicillin." What are hives?',
   'Itchy, raised welts on the skin',
   'Hives (urticaria) are itchy, raised welts — a classic sign of an allergic reaction.',
   'Las "hives" (urticaria o ronchas) son ronchas elevadas que dan comezón: un signo clásico de reacción alérgica.',
   10, 0, '{"shuffle_options": true}'::jsonb, TRUE),
  ('bbbb0404-0002-4000-8000-000000000000', 'bbbb0404-0000-4000-8000-000000000000', 'translation',
   'Translate to English: "¿Es usted alérgico a algún medicamento?"',
   'Are you allergic to any medications?',
   'Note the preposition: "allergic TO", never "allergic of" or "allergic at".',
   'Ojo con la preposición: "allergic TO", nunca "allergic of" ni "allergic at".',
   10, 1,
   '{"source_language": "es", "target_language": "en", "source_text": "¿Es usted alérgico a algún medicamento?", "acceptable_translations": ["Are you allergic to any medications?", "Are you allergic to any medication?", "Do you have any drug allergies?"], "key_terms": ["allergic to"]}'::jsonb, TRUE),
  ('bbbb0404-0003-4000-8000-000000000000', 'bbbb0404-0000-4000-8000-000000000000', 'fill_in_blank',
   'Complete: "How many cigarettes do you ____ per day?"',
   'smoke',
   'Quantifying tobacco use ("how many per day") is more useful clinically than a yes/no question.',
   'Cuantificar el tabaquismo ("how many per day") es clínicamente más útil que una pregunta de sí o no.',
   10, 2,
   '{"acceptable_answers": ["smoke"], "case_sensitive": false, "blank_position": "inline"}'::jsonb, TRUE),
  ('bbbb0404-0004-4000-8000-000000000000', 'bbbb0404-0000-4000-8000-000000000000', 'matching',
   'Match the English allergy and habit terms with their Spanish translations.',
   'allergy—alergia; rash—sarpullido; hives—ronchas; smoking—tabaquismo',
   'Distinguishing "rash" from "hives" helps you document allergic reactions precisely.',
   'Distinguir "rash" de "hives" te ayuda a documentar las reacciones alérgicas con precisión.',
   10, 3, '{"columns": 2}'::jsonb, TRUE),
  ('bbbb0404-0005-4000-8000-000000000000', 'bbbb0404-0000-4000-8000-000000000000', 'flashcard',
   'anaphylaxis', 'anafilaxia',
   'A severe, life-threatening allergic reaction with airway swelling and low blood pressure.',
   'Una reacción alérgica grave que pone en peligro la vida, con edema de la vía aérea e hipotensión.',
   10, 4,
   '{"front": {"text": "anaphylaxis", "subtext": "/ˌænəfəˈlæksɪs/"}, "back": {"text": "anafilaxia", "translation": "anafilaxia", "example": "Penicillin can cause anaphylaxis in allergic patients."}}'::jsonb, TRUE),
  ('bbbb0404-0006-4000-8000-000000000000', 'bbbb0404-0000-4000-8000-000000000000', 'pronunciation',
   'Say: "Are you allergic to any medications?"',
   'Are you allergic to any medications?',
   'Stress the second syllable of "a-LLER-gic" and the third of "me-di-CA-tions".',
   'Acentúa la segunda sílaba de "a-LLER-gic" y la sílaba "CA" de "medications".',
   10, 5,
   '{"word": "Are you allergic to any medications?", "phonetic": "/ɑːr juː əˈlɜːrdʒɪk tuː ˈeni ˌmedɪˈkeɪʃənz/", "minimum_score": 60, "common_mistakes": [{"mistake": "alergic (three syllables, flat stress)", "correction": "a-LLER-gic /əˈlɜːrdʒɪk/"}]}'::jsonb, TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('bbbb0404-0001-4000-8000-000000000000', 'Itchy, raised welts on the skin', TRUE, 0),
  ('bbbb0404-0001-4000-8000-000000000000', 'A type of dry cough', FALSE, 1),
  ('bbbb0404-0001-4000-8000-000000000000', 'Severe stomach cramps', FALSE, 2),
  ('bbbb0404-0001-4000-8000-000000000000', 'Swelling of the ankles', FALSE, 3)
ON CONFLICT DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, match_pair_id, sort_order)
VALUES
  ('bbbb0404-0004-4000-8000-000000000000', 'allergy', 'pair1', 0),
  ('bbbb0404-0004-4000-8000-000000000000', 'alergia', 'pair1', 1),
  ('bbbb0404-0004-4000-8000-000000000000', 'rash', 'pair2', 2),
  ('bbbb0404-0004-4000-8000-000000000000', 'sarpullido', 'pair2', 3),
  ('bbbb0404-0004-4000-8000-000000000000', 'hives', 'pair3', 4),
  ('bbbb0404-0004-4000-8000-000000000000', 'ronchas', 'pair3', 5),
  ('bbbb0404-0004-4000-8000-000000000000', 'smoking', 'pair4', 6),
  ('bbbb0404-0004-4000-8000-000000000000', 'tabaquismo', 'pair4', 7)
ON CONFLICT DO NOTHING;

-- Lesson 4.5: Review of Systems -------------------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, xp_reward, sort_order, metadata, is_published)
VALUES
  ('bbbb0405-0001-4000-8000-000000000000', 'bbbb0405-0000-4000-8000-000000000000', 'multiple_choice',
   'What is the purpose of the review of systems (ROS)?',
   'To screen for symptoms in each body system',
   'The ROS is a head-to-toe symptom checklist that catches problems the patient did not mention spontaneously.',
   'El ROS es una lista de síntomas de pies a cabeza que detecta problemas que el paciente no mencionó espontáneamente.',
   10, 0, '{"shuffle_options": true}'::jsonb, TRUE),
  ('bbbb0405-0002-4000-8000-000000000000', 'bbbb0405-0000-4000-8000-000000000000', 'fill_in_blank',
   'Complete: "Have you had any fever, chills, or night ____?"',
   'sweats',
   '"Fever, chills, and night sweats" is the classic constitutional-symptoms trio.',
   '"Fever, chills, and night sweats" es el trío clásico de síntomas constitucionales.',
   10, 1,
   '{"acceptable_answers": ["sweats"], "case_sensitive": false, "blank_position": "end"}'::jsonb, TRUE),
  ('bbbb0405-0003-4000-8000-000000000000', 'bbbb0405-0000-4000-8000-000000000000', 'sentence_ordering',
   'Put the words in order to ask about weight change.',
   'Have you noticed any weight loss recently?',
   '"Have you noticed any...?" is the standard soft opener for each ROS question.',
   '"Have you noticed any...?" es la apertura suave estándar para cada pregunta del ROS.',
   10, 2,
   '{"words": ["Have", "you", "noticed", "any", "weight", "loss", "recently?"], "show_punctuation": true}'::jsonb, TRUE),
  ('bbbb0405-0004-4000-8000-000000000000', 'bbbb0405-0000-4000-8000-000000000000', 'typing',
   'Type the English term for "dificultad para respirar" (two common words, not "dyspnea").',
   'shortness of breath',
   '"Shortness of breath" is the everyday term; "dyspnea" is the technical one. Use the everyday term with patients.',
   '"Shortness of breath" es el término cotidiano; "dyspnea" es el técnico. Usa el término cotidiano con los pacientes.',
   10, 3,
   '{"acceptable_answers": ["shortness of breath"], "case_sensitive": false, "max_length": 60}'::jsonb, TRUE),
  ('bbbb0405-0005-4000-8000-000000000000', 'bbbb0405-0000-4000-8000-000000000000', 'flashcard',
   'palpitations', 'palpitaciones',
   'The feeling that your heart is racing, pounding, or skipping beats.',
   'La sensación de que el corazón late muy rápido, muy fuerte o se salta latidos.',
   10, 4,
   '{"front": {"text": "palpitations", "subtext": "/ˌpælpɪˈteɪʃənz/"}, "back": {"text": "palpitaciones", "translation": "palpitaciones", "example": "Have you had any palpitations or chest pain?"}}'::jsonb, TRUE),
  ('bbbb0405-0006-4000-8000-000000000000', 'bbbb0405-0000-4000-8000-000000000000', 'translation',
   'Translate to English: "¿Ha tenido mareos o dolores de cabeza?"',
   'Have you had any dizziness or headaches?',
   'Adding "any" after "Have you had" makes the screening question sound natural.',
   'Agregar "any" después de "Have you had" hace que la pregunta de tamizaje suene natural.',
   10, 5,
   '{"source_language": "es", "target_language": "en", "source_text": "¿Ha tenido mareos o dolores de cabeza?", "acceptable_translations": ["Have you had any dizziness or headaches?", "Have you had dizziness or headaches?", "Have you experienced any dizziness or headaches?"], "key_terms": ["dizziness", "headaches"]}'::jsonb, TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('bbbb0405-0001-4000-8000-000000000000', 'To screen for symptoms in each body system', TRUE, 0),
  ('bbbb0405-0001-4000-8000-000000000000', 'To review the hospital''s computer systems', FALSE, 1),
  ('bbbb0405-0001-4000-8000-000000000000', 'To confirm the patient''s insurance coverage', FALSE, 2),
  ('bbbb0405-0001-4000-8000-000000000000', 'To plan the surgical approach', FALSE, 3)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- Module 5 exercises
-- ============================================================================

-- Lesson 5.1: Giving Exam Instructions -----------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, xp_reward, sort_order, metadata, is_published)
VALUES
  ('bbbb0501-0001-4000-8000-000000000000', 'bbbb0501-0000-4000-8000-000000000000', 'multiple_choice',
   'Which instruction asks the patient to inhale?',
   'Take a deep breath in.',
   '"Take a deep breath in" (or "breathe in") tells the patient to inhale; "breathe out" means exhale.',
   '"Take a deep breath in" (o "breathe in") indica inhalar; "breathe out" significa exhalar.',
   10, 0, '{"shuffle_options": true}'::jsonb, TRUE),
  ('bbbb0501-0002-4000-8000-000000000000', 'bbbb0501-0000-4000-8000-000000000000', 'translation',
   'Translate to English: "Recuéstese en la camilla, por favor."',
   'Please lie down on the examination table.',
   'Use "lie down" (not "lay down" for yourself) and "examination table" for "camilla" in the clinic.',
   'Usa "lie down" (no "lay down" para uno mismo) y "examination table" para "camilla" en el consultorio.',
   10, 1,
   '{"source_language": "es", "target_language": "en", "source_text": "Recuéstese en la camilla, por favor.", "acceptable_translations": ["Please lie down on the examination table.", "Lie down on the exam table, please.", "Please lie down on the exam table."], "key_terms": ["lie down", "examination table"]}'::jsonb, TRUE),
  ('bbbb0501-0003-4000-8000-000000000000', 'bbbb0501-0000-4000-8000-000000000000', 'fill_in_blank',
   'Complete: "Take a deep breath and ____ it."',
   'hold',
   '"Hold your breath" means to stop breathing for a moment — essential during auscultation and imaging.',
   '"Hold your breath" significa aguantar la respiración un momento: esencial durante la auscultación y los estudios de imagen.',
   10, 2,
   '{"acceptable_answers": ["hold"], "case_sensitive": false, "blank_position": "inline"}'::jsonb, TRUE),
  ('bbbb0501-0004-4000-8000-000000000000', 'bbbb0501-0000-4000-8000-000000000000', 'matching',
   'Match the English exam instructions with their Spanish equivalents.',
   'lie down—recuéstese; sit up—incorpórese; roll over—voltéese; relax—relájese',
   'These four commands cover most position changes during a physical exam.',
   'Estas cuatro indicaciones cubren la mayoría de los cambios de posición durante la exploración física.',
   10, 3, '{"columns": 2}'::jsonb, TRUE),
  ('bbbb0501-0005-4000-8000-000000000000', 'bbbb0501-0000-4000-8000-000000000000', 'flashcard',
   'stethoscope', 'estetoscopio',
   'The instrument used to listen to the heart, lungs, and bowel sounds.',
   'El instrumento que se usa para escuchar el corazón, los pulmones y los ruidos intestinales.',
   10, 4,
   '{"front": {"text": "stethoscope", "subtext": "/ˈsteθəskoʊp/"}, "back": {"text": "estetoscopio", "translation": "estetoscopio", "example": "This might feel cold — it''s just my stethoscope."}}'::jsonb, TRUE),
  ('bbbb0501-0006-4000-8000-000000000000', 'bbbb0501-0000-4000-8000-000000000000', 'pronunciation',
   'Say: "Take a deep breath and hold it."',
   'Take a deep breath and hold it.',
   '"Breath" (noun) ends in the unvoiced /θ/ sound; do not confuse it with the verb "breathe" /briːð/.',
   '"Breath" (sustantivo) termina en el sonido sordo /θ/; no lo confundas con el verbo "breathe" /briːð/.',
   10, 5,
   '{"word": "Take a deep breath and hold it.", "phonetic": "/teɪk ə diːp breθ ənd hoʊld ɪt/", "minimum_score": 60, "common_mistakes": [{"mistake": "breathe /briːð/ (verb)", "correction": "breath /breθ/ (noun)"}]}'::jsonb, TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('bbbb0501-0001-4000-8000-000000000000', 'Take a deep breath in.', TRUE, 0),
  ('bbbb0501-0001-4000-8000-000000000000', 'Hold still, please.', FALSE, 1),
  ('bbbb0501-0001-4000-8000-000000000000', 'Look at my finger.', FALSE, 2),
  ('bbbb0501-0001-4000-8000-000000000000', 'Bend your knees.', FALSE, 3)
ON CONFLICT DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, match_pair_id, sort_order)
VALUES
  ('bbbb0501-0004-4000-8000-000000000000', 'lie down', 'pair1', 0),
  ('bbbb0501-0004-4000-8000-000000000000', 'recuéstese', 'pair1', 1),
  ('bbbb0501-0004-4000-8000-000000000000', 'sit up', 'pair2', 2),
  ('bbbb0501-0004-4000-8000-000000000000', 'incorpórese', 'pair2', 3),
  ('bbbb0501-0004-4000-8000-000000000000', 'roll over', 'pair3', 4),
  ('bbbb0501-0004-4000-8000-000000000000', 'voltéese', 'pair3', 5),
  ('bbbb0501-0004-4000-8000-000000000000', 'relax', 'pair4', 6),
  ('bbbb0501-0004-4000-8000-000000000000', 'relájese', 'pair4', 7)
ON CONFLICT DO NOTHING;

-- Lesson 5.2: Head & Neck Exam ---------------------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, xp_reward, sort_order, metadata, is_published)
VALUES
  ('bbbb0502-0001-4000-8000-000000000000', 'bbbb0502-0000-4000-8000-000000000000', 'multiple_choice',
   'Which structure do you examine with an otoscope?',
   'The eardrum',
   'The otoscope lets you see the ear canal and the eardrum (tympanic membrane).',
   'El otoscopio permite ver el conducto auditivo y el tímpano (membrana timpánica).',
   10, 0, '{"shuffle_options": true}'::jsonb, TRUE),
  ('bbbb0502-0002-4000-8000-000000000000', 'bbbb0502-0000-4000-8000-000000000000', 'fill_in_blank',
   'Complete: "Open your mouth and say ''ah'' so I can see your ____."',
   'throat',
   'Saying "ah" lowers the tongue so you can inspect the throat and tonsils.',
   'Decir "ah" baja la lengua para poder inspeccionar la garganta y las amígdalas.',
   10, 1,
   '{"acceptable_answers": ["throat"], "case_sensitive": false, "blank_position": "end"}'::jsonb, TRUE),
  ('bbbb0502-0003-4000-8000-000000000000', 'bbbb0502-0000-4000-8000-000000000000', 'sentence_ordering',
   'Put the words in order to explain the next step of the exam.',
   'I am going to check your lymph nodes.',
   '"I am going to..." announces each exam step so the patient is never surprised.',
   '"I am going to..." anuncia cada paso de la exploración para que el paciente nunca se sorprenda.',
   10, 2,
   '{"words": ["I", "am", "going", "to", "check", "your", "lymph", "nodes."], "show_punctuation": true}'::jsonb, TRUE),
  ('bbbb0502-0004-4000-8000-000000000000', 'bbbb0502-0000-4000-8000-000000000000', 'typing',
   'Type the English word for "tiroides".',
   'thyroid',
   'The thyroid gland sits at the front of the neck; palpate it while the patient swallows.',
   'La glándula tiroides está en la parte anterior del cuello; se palpa mientras el paciente traga.',
   10, 3,
   '{"acceptable_answers": ["thyroid"], "case_sensitive": false}'::jsonb, TRUE),
  ('bbbb0502-0005-4000-8000-000000000000', 'bbbb0502-0000-4000-8000-000000000000', 'flashcard',
   'lymph node', 'ganglio linfático',
   'A small bean-shaped gland; swollen lymph nodes often indicate infection.',
   'Una pequeña glándula en forma de frijol; los ganglios inflamados suelen indicar infección.',
   10, 4,
   '{"front": {"text": "lymph node", "subtext": "/lɪmf noʊd/"}, "back": {"text": "ganglio linfático", "translation": "ganglio linfático", "example": "Your lymph nodes are slightly swollen."}}'::jsonb, TRUE),
  ('bbbb0502-0006-4000-8000-000000000000', 'bbbb0502-0000-4000-8000-000000000000', 'translation',
   'Translate to English: "Siga mi dedo con los ojos sin mover la cabeza."',
   'Follow my finger with your eyes without moving your head.',
   'This is the standard instruction for testing extraocular movements.',
   'Esta es la instrucción estándar para evaluar los movimientos extraoculares.',
   10, 5,
   '{"source_language": "es", "target_language": "en", "source_text": "Siga mi dedo con los ojos sin mover la cabeza.", "acceptable_translations": ["Follow my finger with your eyes without moving your head.", "Follow my finger with your eyes, but don''t move your head."], "key_terms": ["follow my finger"]}'::jsonb, TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('bbbb0502-0001-4000-8000-000000000000', 'The eardrum', TRUE, 0),
  ('bbbb0502-0001-4000-8000-000000000000', 'The pupil', FALSE, 1),
  ('bbbb0502-0001-4000-8000-000000000000', 'The thyroid', FALSE, 2),
  ('bbbb0502-0001-4000-8000-000000000000', 'The tonsils', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Lesson 5.3: Chest & Lungs -------------------------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, xp_reward, sort_order, metadata, is_published)
VALUES
  ('bbbb0503-0001-4000-8000-000000000000', 'bbbb0503-0000-4000-8000-000000000000', 'multiple_choice',
   'What does "auscultation" mean?',
   'Listening to body sounds with a stethoscope',
   'Auscultation is listening to the heart, lungs, or bowel with a stethoscope; percussion is tapping.',
   'La auscultación es escuchar el corazón, los pulmones o el intestino con estetoscopio; la percusión es golpetear.',
   10, 0, '{"shuffle_options": true}'::jsonb, TRUE),
  ('bbbb0503-0002-4000-8000-000000000000', 'bbbb0503-0000-4000-8000-000000000000', 'matching',
   'Match the English respiratory terms with their Spanish translations.',
   'wheeze—sibilancia; crackles—estertores; cough—tos; breath sounds—ruidos respiratorios',
   'Wheezes suggest airway narrowing; crackles suggest fluid in the small airways.',
   'Las sibilancias sugieren estrechamiento de la vía aérea; los estertores sugieren líquido en las vías pequeñas.',
   10, 1, '{"columns": 2}'::jsonb, TRUE),
  ('bbbb0503-0003-4000-8000-000000000000', 'bbbb0503-0000-4000-8000-000000000000', 'translation',
   'Translate to English: "Respire profundo por la boca, por favor."',
   'Please breathe deeply through your mouth.',
   'Use the verb "breathe" /briːð/ with a final voiced sound — not the noun "breath".',
   'Usa el verbo "breathe" /briːð/ con sonido final sonoro, no el sustantivo "breath".',
   10, 2,
   '{"source_language": "es", "target_language": "en", "source_text": "Respire profundo por la boca, por favor.", "acceptable_translations": ["Please breathe deeply through your mouth.", "Breathe deeply through your mouth, please.", "Please take deep breaths through your mouth."], "key_terms": ["breathe", "through your mouth"]}'::jsonb, TRUE),
  ('bbbb0503-0004-4000-8000-000000000000', 'bbbb0503-0000-4000-8000-000000000000', 'sentence_ordering',
   'Put the words in order to announce lung auscultation.',
   'I am going to listen to your lungs.',
   '"Listen TO your lungs" — the preposition "to" is required after "listen".',
   '"Listen TO your lungs": la preposición "to" es obligatoria después de "listen".',
   10, 3,
   '{"words": ["I", "am", "going", "to", "listen", "to", "your", "lungs."], "show_punctuation": true}'::jsonb, TRUE),
  ('bbbb0503-0005-4000-8000-000000000000', 'bbbb0503-0000-4000-8000-000000000000', 'pronunciation',
   'Say: "Breathe in deeply through your mouth."',
   'Breathe in deeply through your mouth.',
   'Both "breathe" /ð/ and "through" /θ/ use "th" sounds — voiced in the first, unvoiced in the second.',
   'Tanto "breathe" /ð/ como "through" /θ/ usan sonidos "th": sonoro en la primera, sordo en la segunda.',
   10, 4,
   '{"word": "Breathe in deeply through your mouth.", "phonetic": "/briːð ɪn ˈdiːpli θruː jɔːr maʊθ/", "minimum_score": 60, "common_mistakes": [{"mistake": "trough or tru for through", "correction": "through /θruː/"}]}'::jsonb, TRUE),
  ('bbbb0503-0006-4000-8000-000000000000', 'bbbb0503-0000-4000-8000-000000000000', 'fill_in_blank',
   'Complete: "I hear a ____ when you exhale, which suggests airway narrowing."',
   'wheeze',
   'A wheeze is a high-pitched whistling sound, typical of asthma and COPD.',
   'Una sibilancia es un silbido agudo, típico del asma y la EPOC.',
   10, 5,
   '{"acceptable_answers": ["wheeze", "wheezing"], "case_sensitive": false, "blank_position": "inline"}'::jsonb, TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('bbbb0503-0001-4000-8000-000000000000', 'Listening to body sounds with a stethoscope', TRUE, 0),
  ('bbbb0503-0001-4000-8000-000000000000', 'Tapping the chest to assess resonance', FALSE, 1),
  ('bbbb0503-0001-4000-8000-000000000000', 'Pressing the abdomen with the hands', FALSE, 2),
  ('bbbb0503-0001-4000-8000-000000000000', 'Measuring the oxygen saturation', FALSE, 3)
ON CONFLICT DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, match_pair_id, sort_order)
VALUES
  ('bbbb0503-0002-4000-8000-000000000000', 'wheeze', 'pair1', 0),
  ('bbbb0503-0002-4000-8000-000000000000', 'sibilancia', 'pair1', 1),
  ('bbbb0503-0002-4000-8000-000000000000', 'crackles', 'pair2', 2),
  ('bbbb0503-0002-4000-8000-000000000000', 'estertores', 'pair2', 3),
  ('bbbb0503-0002-4000-8000-000000000000', 'cough', 'pair3', 4),
  ('bbbb0503-0002-4000-8000-000000000000', 'tos', 'pair3', 5),
  ('bbbb0503-0002-4000-8000-000000000000', 'breath sounds', 'pair4', 6),
  ('bbbb0503-0002-4000-8000-000000000000', 'ruidos respiratorios', 'pair4', 7)
ON CONFLICT DO NOTHING;

-- Lesson 5.4: Examining the Abdomen -----------------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, xp_reward, sort_order, metadata, is_published)
VALUES
  ('bbbb0504-0001-4000-8000-000000000000', 'bbbb0504-0000-4000-8000-000000000000', 'multiple_choice',
   'What is "palpation"?',
   'Examining the body by pressing with the hands',
   'Palpation means feeling with the hands to assess organs, masses, and tenderness.',
   'La palpación consiste en explorar con las manos para valorar órganos, masas y dolor.',
   10, 0, '{"shuffle_options": true}'::jsonb, TRUE),
  ('bbbb0504-0002-4000-8000-000000000000', 'bbbb0504-0000-4000-8000-000000000000', 'translation',
   'Translate to English: "¿Le duele cuando presiono aquí?"',
   'Does it hurt when I press here?',
   '"Does it hurt when I press here?" is the key question during abdominal palpation.',
   '"Does it hurt when I press here?" es la pregunta clave durante la palpación abdominal.',
   10, 1,
   '{"source_language": "es", "target_language": "en", "source_text": "¿Le duele cuando presiono aquí?", "acceptable_translations": ["Does it hurt when I press here?", "Does this hurt when I press here?", "Does it hurt when I push here?"], "key_terms": ["hurt", "press"]}'::jsonb, TRUE),
  ('bbbb0504-0003-4000-8000-000000000000', 'bbbb0504-0000-4000-8000-000000000000', 'fill_in_blank',
   'Complete: "I am going to listen to your bowel ____."',
   'sounds',
   'Bowel sounds are auscultated before palpation so palpation does not alter them.',
   'Los ruidos intestinales se auscultan antes de palpar para que la palpación no los altere.',
   10, 2,
   '{"acceptable_answers": ["sounds"], "case_sensitive": false, "blank_position": "end"}'::jsonb, TRUE),
  ('bbbb0504-0004-4000-8000-000000000000', 'bbbb0504-0000-4000-8000-000000000000', 'matching',
   'Match the English abdominal terms with their Spanish translations.',
   'tenderness—dolor a la palpación; liver—hígado; spleen—bazo; bowel sounds—ruidos intestinales',
   '"Tenderness" is pain elicited by touch — different from spontaneous pain.',
   '"Tenderness" es dolor provocado por el tacto, distinto del dolor espontáneo.',
   10, 3, '{"columns": 2}'::jsonb, TRUE),
  ('bbbb0504-0005-4000-8000-000000000000', 'bbbb0504-0000-4000-8000-000000000000', 'flashcard',
   'guarding', 'defensa muscular',
   'Involuntary tensing of the abdominal muscles over an inflamed area.',
   'Tensión involuntaria de los músculos abdominales sobre una zona inflamada.',
   10, 4,
   '{"front": {"text": "guarding", "subtext": "/ˈɡɑːrdɪŋ/"}, "back": {"text": "defensa muscular", "translation": "defensa muscular", "example": "There is guarding in the right lower quadrant."}}'::jsonb, TRUE),
  ('bbbb0504-0006-4000-8000-000000000000', 'bbbb0504-0000-4000-8000-000000000000', 'pronunciation',
   'Say: "Does it hurt when I press here?"',
   'Does it hurt when I press here?',
   'Link "does it" into "duzit" and keep "hurt" with a strong American /ɜːr/ vowel.',
   'Enlaza "does it" como "duzit" y pronuncia "hurt" con la vocal /ɜːr/ fuerte del inglés americano.',
   10, 5,
   '{"word": "Does it hurt when I press here?", "phonetic": "/dʌz ɪt hɜːrt wen aɪ pres hɪr/", "minimum_score": 60, "common_mistakes": [{"mistake": "heart /hɑːrt/", "correction": "hurt /hɜːrt/"}]}'::jsonb, TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('bbbb0504-0001-4000-8000-000000000000', 'Examining the body by pressing with the hands', TRUE, 0),
  ('bbbb0504-0001-4000-8000-000000000000', 'Listening with a stethoscope', FALSE, 1),
  ('bbbb0504-0001-4000-8000-000000000000', 'Looking at the skin for rashes', FALSE, 2),
  ('bbbb0504-0001-4000-8000-000000000000', 'Measuring blood pressure with a cuff', FALSE, 3)
ON CONFLICT DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, match_pair_id, sort_order)
VALUES
  ('bbbb0504-0004-4000-8000-000000000000', 'tenderness', 'pair1', 0),
  ('bbbb0504-0004-4000-8000-000000000000', 'dolor a la palpación', 'pair1', 1),
  ('bbbb0504-0004-4000-8000-000000000000', 'liver', 'pair2', 2),
  ('bbbb0504-0004-4000-8000-000000000000', 'hígado', 'pair2', 3),
  ('bbbb0504-0004-4000-8000-000000000000', 'spleen', 'pair3', 4),
  ('bbbb0504-0004-4000-8000-000000000000', 'bazo', 'pair3', 5),
  ('bbbb0504-0004-4000-8000-000000000000', 'bowel sounds', 'pair4', 6),
  ('bbbb0504-0004-4000-8000-000000000000', 'ruidos intestinales', 'pair4', 7)
ON CONFLICT DO NOTHING;

-- Lesson 5.5: Neuro Exam Basics ------------------------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, xp_reward, sort_order, metadata, is_published)
VALUES
  ('bbbb0505-0001-4000-8000-000000000000', 'bbbb0505-0000-4000-8000-000000000000', 'multiple_choice',
   'Which instruction tests coordination?',
   'Touch your nose with your finger, then touch my finger.',
   'The finger-to-nose test evaluates cerebellar coordination.',
   'La prueba dedo-nariz evalúa la coordinación cerebelosa.',
   10, 0, '{"shuffle_options": true}'::jsonb, TRUE),
  ('bbbb0505-0002-4000-8000-000000000000', 'bbbb0505-0000-4000-8000-000000000000', 'fill_in_blank',
   'Complete: "I am going to test your ____ with this small hammer."',
   'reflexes',
   'Deep tendon reflexes are tested with a reflex hammer at the knee, ankle, and elbow.',
   'Los reflejos osteotendinosos se exploran con un martillo de reflejos en rodilla, tobillo y codo.',
   10, 1,
   '{"acceptable_answers": ["reflexes"], "case_sensitive": false, "blank_position": "inline"}'::jsonb, TRUE),
  ('bbbb0505-0003-4000-8000-000000000000', 'bbbb0505-0000-4000-8000-000000000000', 'sentence_ordering',
   'Put the words in order to test sensation.',
   'Can you feel me touching your foot?',
   '"Can you feel...?" is the standard opener for sensory testing.',
   '"Can you feel...?" es la frase estándar para explorar la sensibilidad.',
   10, 2,
   '{"words": ["Can", "you", "feel", "me", "touching", "your", "foot?"], "show_punctuation": true}'::jsonb, TRUE),
  ('bbbb0505-0004-4000-8000-000000000000', 'bbbb0505-0000-4000-8000-000000000000', 'typing',
   'Type the English word for "entumecimiento" (loss of feeling).',
   'numbness',
   '"Numbness" is loss of feeling; "tingling" is the pins-and-needles sensation.',
   '"Numbness" es la pérdida de sensibilidad; "tingling" es la sensación de hormigueo.',
   10, 3,
   '{"acceptable_answers": ["numbness"], "case_sensitive": false}'::jsonb, TRUE),
  ('bbbb0505-0005-4000-8000-000000000000', 'bbbb0505-0000-4000-8000-000000000000', 'flashcard',
   'gait', 'marcha',
   'The way a person walks; observed to assess balance and neurological function.',
   'La forma de caminar de una persona; se observa para valorar el equilibrio y la función neurológica.',
   10, 4,
   '{"front": {"text": "gait", "subtext": "/ɡeɪt/"}, "back": {"text": "marcha", "translation": "marcha", "example": "The patient has an unsteady gait."}}'::jsonb, TRUE),
  ('bbbb0505-0006-4000-8000-000000000000', 'bbbb0505-0000-4000-8000-000000000000', 'translation',
   'Translate to English: "Camine en línea recta, un pie delante del otro."',
   'Walk in a straight line, one foot in front of the other.',
   'This instruction describes tandem gait, used to assess balance.',
   'Esta instrucción describe la marcha en tándem, usada para valorar el equilibrio.',
   10, 5,
   '{"source_language": "es", "target_language": "en", "source_text": "Camine en línea recta, un pie delante del otro.", "acceptable_translations": ["Walk in a straight line, one foot in front of the other.", "Walk in a straight line, placing one foot in front of the other."], "key_terms": ["straight line", "one foot in front of the other"]}'::jsonb, TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('bbbb0505-0001-4000-8000-000000000000', 'Touch your nose with your finger, then touch my finger.', TRUE, 0),
  ('bbbb0505-0001-4000-8000-000000000000', 'Squeeze my hands as hard as you can.', FALSE, 1),
  ('bbbb0505-0001-4000-8000-000000000000', 'Follow the light with your eyes.', FALSE, 2),
  ('bbbb0505-0001-4000-8000-000000000000', 'Say "ah" while I look at your throat.', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Vocabulary -----------------------------------------------------------------
-- Medical History (M4), Physical Examination (M5), Medications (M6).
-- AI-drafted, published for MVP; physician validation pending.
INSERT INTO vocabulary (id, word, phonetic, translation_es, definition_en, definition_es, example_en, example_es, category, difficulty, tags, is_published)
VALUES
  ('bbbb9000-0000-4000-8000-000000000401', 'allergy', '/ˈæl.ər.dʒi/', 'alergia',
   'A harmful immune reaction to a substance.', 'Reacción inmunitaria dañina a una sustancia.',
   'Do you have any drug allergies?', '¿Tiene alguna alergia a medicamentos?', 'pathology', 'beginner', ARRAY['history'], TRUE),
  ('bbbb9000-0000-4000-8000-000000000402', 'chronic', '/ˈkrɒn.ɪk/', 'crónico',
   'A condition that lasts a long time or recurs.', 'Afección que dura mucho tiempo o recurre.',
   'Do you have any chronic illnesses?', '¿Tiene alguna enfermedad crónica?', 'general', 'intermediate', ARRAY['history'], TRUE),
  ('bbbb9000-0000-4000-8000-000000000403', 'surgery', '/ˈsɜːr.dʒər.i/', 'cirugía / operación',
   'A medical procedure involving an incision.', 'Procedimiento médico que implica una incisión.',
   'Have you ever had surgery?', '¿Ha tenido alguna cirugía?', 'surgery', 'beginner', ARRAY['history'], TRUE),
  ('bbbb9000-0000-4000-8000-000000000404', 'diabetes', '/ˌdaɪ.əˈbiː.tiːz/', 'diabetes',
   'A disease of high blood sugar levels.', 'Enfermedad con niveles altos de azúcar en sangre.',
   'Is there any diabetes in your family?', '¿Hay diabetes en su familia?', 'pathology', 'intermediate', ARRAY['history'], TRUE),
  ('bbbb9000-0000-4000-8000-000000000405', 'hypertension', '/ˌhaɪ.pərˈtɛn.ʃən/', 'hipertensión',
   'Abnormally high blood pressure.', 'Presión arterial anormalmente alta.',
   'He has a history of hypertension.', 'Tiene antecedentes de hipertensión.', 'cardiology', 'advanced', ARRAY['history'], TRUE),
  ('bbbb9000-0000-4000-8000-000000000406', 'smoking', '/ˈsmoʊ.kɪŋ/', 'tabaquismo / fumar',
   'The habit of inhaling tobacco smoke.', 'Hábito de inhalar humo de tabaco.',
   'How long have you had a smoking habit?', '¿Desde hace cuánto tiene el hábito de fumar?', 'general', 'beginner', ARRAY['social-history'], TRUE),
  ('bbbb9000-0000-4000-8000-000000000407', 'family history', '/ˈfæm.əl.i ˈhɪs.tər.i/', 'antecedentes familiares',
   'Health conditions that run in a patient''s family.', 'Enfermedades presentes en la familia del paciente.',
   'Let us review your family history.', 'Revisemos sus antecedentes familiares.', 'general', 'intermediate', ARRAY['history'], TRUE),
  ('bbbb9000-0000-4000-8000-000000000408', 'palpate', '/ˈpæl.peɪt/', 'palpar',
   'To examine by touching and pressing with the hands.', 'Examinar tocando y presionando con las manos.',
   'I am going to palpate your abdomen now.', 'Voy a palpar su abdomen ahora.', 'procedures', 'advanced', ARRAY['exam'], TRUE),
  ('bbbb9000-0000-4000-8000-000000000501', 'auscultate', '/ˈɔː.skəl.teɪt/', 'auscultar',
   'To listen to internal sounds with a stethoscope.', 'Escuchar sonidos internos con un estetoscopio.',
   'I will auscultate your heart and lungs.', 'Voy a auscultar su corazón y pulmones.', 'procedures', 'advanced', ARRAY['exam'], TRUE),
  ('bbbb9000-0000-4000-8000-000000000502', 'inspect', '/ɪnˈspɛkt/', 'inspeccionar',
   'To examine something carefully by looking.', 'Examinar algo con cuidado mirándolo.',
   'First I will inspect the wound.', 'Primero voy a inspeccionar la herida.', 'procedures', 'intermediate', ARRAY['exam'], TRUE),
  ('bbbb9000-0000-4000-8000-000000000503', 'reflex', '/ˈriː.flɛks/', 'reflejo',
   'An automatic response to a stimulus.', 'Respuesta automática a un estímulo.',
   'I am going to test your reflexes.', 'Voy a evaluar sus reflejos.', 'physiology', 'intermediate', ARRAY['exam','neuro'], TRUE),
  ('bbbb9000-0000-4000-8000-000000000504', 'deep breath', '/diːp brɛθ/', 'respiración profunda',
   'A full inhalation, often requested during an exam.', 'Inhalación completa, solicitada durante el examen.',
   'Take a deep breath and hold it.', 'Respire profundo y aguante.', 'procedures', 'beginner', ARRAY['exam'], TRUE),
  ('bbbb9000-0000-4000-8000-000000000505', 'wince', '/wɪns/', 'gesto de dolor',
   'To flinch or grimace from sudden pain.', 'Contraer el rostro por un dolor súbito.',
   'The patient winced when I pressed the area.', 'El paciente hizo un gesto de dolor al presionar la zona.', 'general', 'advanced', ARRAY['exam'], TRUE),
  ('bbbb9000-0000-4000-8000-000000000601', 'dose', '/doʊs/', 'dosis',
   'The amount of medication taken at one time.', 'Cantidad de medicamento tomada de una vez.',
   'The usual dose is one tablet.', 'La dosis habitual es una tableta.', 'pharmacology', 'beginner', ARRAY['medication'], TRUE),
  ('bbbb9000-0000-4000-8000-000000000602', 'prescription', '/prɪˈskrɪp.ʃən/', 'receta',
   'A written order for a medication.', 'Orden escrita para un medicamento.',
   'I will send the prescription to your pharmacy.', 'Enviaré la receta a su farmacia.', 'pharmacology', 'beginner', ARRAY['medication'], TRUE),
  ('bbbb9000-0000-4000-8000-000000000603', 'tablet', '/ˈtæb.lət/', 'tableta / pastilla',
   'A solid dose of medicine to be swallowed.', 'Dosis sólida de medicina para tragar.',
   'Take one tablet with food.', 'Tome una tableta con alimento.', 'pharmacology', 'beginner', ARRAY['medication'], TRUE),
  ('bbbb9000-0000-4000-8000-000000000604', 'side effect', '/saɪd ɪˈfɛkt/', 'efecto secundario',
   'An unintended effect of a medication.', 'Efecto no deseado de un medicamento.',
   'A common side effect is drowsiness.', 'Un efecto secundario común es la somnolencia.', 'pharmacology', 'intermediate', ARRAY['medication'], TRUE),
  ('bbbb9000-0000-4000-8000-000000000605', 'twice daily', '/twaɪs ˈdeɪ.li/', 'dos veces al día',
   'Two times each day (b.i.d.).', 'Dos veces cada día (c/12 h).',
   'Take this medication twice daily.', 'Tome este medicamento dos veces al día.', 'pharmacology', 'beginner', ARRAY['dosage'], TRUE),
  ('bbbb9000-0000-4000-8000-000000000606', 'refill', '/ˈriː.fɪl/', 'resurtido / renovación',
   'A repeat supply of a prescribed medication.', 'Nuevo suministro de un medicamento recetado.',
   'You have two refills remaining.', 'Le quedan dos resurtidos.', 'pharmacology', 'intermediate', ARRAY['medication'], TRUE),
  ('bbbb9000-0000-4000-8000-000000000607', 'antibiotic', '/ˌæn.ti.baɪˈɒt.ɪk/', 'antibiótico',
   'A drug that treats bacterial infections.', 'Fármaco que trata infecciones bacterianas.',
   'Finish the full course of the antibiotic.', 'Complete todo el ciclo del antibiótico.', 'pharmacology', 'intermediate', ARRAY['drug-class'], TRUE),
  ('bbbb9000-0000-4000-8000-000000000608', 'painkiller', '/ˈpeɪnˌkɪl.ər/', 'analgésico',
   'A medication that relieves pain.', 'Medicamento que alivia el dolor.',
   'You can take a painkiller if needed.', 'Puede tomar un analgésico si lo necesita.', 'pharmacology', 'beginner', ARRAY['drug-class'], TRUE)
ON CONFLICT (id) DO NOTHING;

-- Lesson ↔ vocabulary links ---------------------------------------------------
INSERT INTO lesson_vocabulary (lesson_id, vocabulary_id, sort_order)
VALUES
  ('bbbb0401-0000-4000-8000-000000000000', 'bbbb9000-0000-4000-8000-000000000402', 0),
  ('bbbb0401-0000-4000-8000-000000000000', 'bbbb9000-0000-4000-8000-000000000403', 1),
  ('bbbb0401-0000-4000-8000-000000000000', 'bbbb9000-0000-4000-8000-000000000405', 2),
  ('bbbb0402-0000-4000-8000-000000000000', 'bbbb9000-0000-4000-8000-000000000407', 0),
  ('bbbb0402-0000-4000-8000-000000000000', 'bbbb9000-0000-4000-8000-000000000404', 1),
  ('bbbb0403-0000-4000-8000-000000000000', 'bbbb9000-0000-4000-8000-000000000406', 0),
  ('bbbb0404-0000-4000-8000-000000000000', 'bbbb9000-0000-4000-8000-000000000401', 0),
  ('bbbb0501-0000-4000-8000-000000000000', 'bbbb9000-0000-4000-8000-000000000504', 0),
  ('bbbb0501-0000-4000-8000-000000000000', 'bbbb9000-0000-4000-8000-000000000502', 1),
  ('bbbb0502-0000-4000-8000-000000000000', 'bbbb9000-0000-4000-8000-000000000408', 0),
  ('bbbb0503-0000-4000-8000-000000000000', 'bbbb9000-0000-4000-8000-000000000501', 0),
  ('bbbb0504-0000-4000-8000-000000000000', 'bbbb9000-0000-4000-8000-000000000408', 0),
  ('bbbb0504-0000-4000-8000-000000000000', 'bbbb9000-0000-4000-8000-000000000505', 1),
  ('bbbb0505-0000-4000-8000-000000000000', 'bbbb9000-0000-4000-8000-000000000503', 0),
  ('bbbb0601-0000-4000-8000-000000000000', 'bbbb9000-0000-4000-8000-000000000607', 0),
  ('bbbb0601-0000-4000-8000-000000000000', 'bbbb9000-0000-4000-8000-000000000608', 1),
  ('bbbb0602-0000-4000-8000-000000000000', 'bbbb9000-0000-4000-8000-000000000601', 0),
  ('bbbb0602-0000-4000-8000-000000000000', 'bbbb9000-0000-4000-8000-000000000605', 1),
  ('bbbb0603-0000-4000-8000-000000000000', 'bbbb9000-0000-4000-8000-000000000602', 0),
  ('bbbb0603-0000-4000-8000-000000000000', 'bbbb9000-0000-4000-8000-000000000603', 1),
  ('bbbb0603-0000-4000-8000-000000000000', 'bbbb9000-0000-4000-8000-000000000606', 2),
  ('bbbb0604-0000-4000-8000-000000000000', 'bbbb9000-0000-4000-8000-000000000604', 0),
  ('bbbb0605-0000-4000-8000-000000000000', 'bbbb9000-0000-4000-8000-000000000605', 0)
ON CONFLICT DO NOTHING;

-- ---- from 03_modules_7_10.sql ----
-- ============================================================================
-- MediLingo — Seed: Modules 7–10 for course 'medical-english-essentials'
-- AI-drafted content — pending physician validation (content pipeline:
-- AI draft → physician validates → publish).
--
-- Course: 11111111-1111-1111-1111-111111111111 (medical-english-essentials)
-- Module 7  (cccc0007): Emergency & Urgent Care
-- Module 8  (cccc0008): Lab Tests & Imaging
-- Module 9  (cccc0009): Diagnosis & Treatment Plans
-- Module 10 (cccc0010): Clinical Cases & Course Review
-- All UUIDs minted here start with 'cccc' (collision avoidance with aaaa/bbbb).
-- ============================================================================

-- Modules --------------------------------------------------------------------
INSERT INTO modules (id, course_id, slug, title, description, sort_order, is_published)
VALUES
  ('cccc0007-0000-4000-8000-000000000000', '11111111-1111-1111-1111-111111111111',
   'emergency-room', 'Emergency & Urgent Care',
   'Triage, emergency phrases, trauma, and chest-pain protocols under time pressure.',
   6, TRUE),
  ('cccc0008-0000-4000-8000-000000000000', '11111111-1111-1111-1111-111111111111',
   'lab-tests-imaging', 'Lab Tests & Imaging',
   'Blood work, urinalysis, X-ray, CT and MRI — ordering tests and explaining results.',
   7, TRUE),
  ('cccc0009-0000-4000-8000-000000000000', '11111111-1111-1111-1111-111111111111',
   'giving-diagnosis-treatment', 'Diagnosis & Treatment Plans',
   'Delivering a diagnosis, explaining prognosis and treatment options, informed consent.',
   8, TRUE),
  ('cccc0010-0000-4000-8000-000000000000', '11111111-1111-1111-1111-111111111111',
   'clinical-cases-review', 'Clinical Cases & Course Review',
   'Integrated clinical-case dialogues and a full review of the course.',
   9, TRUE)
ON CONFLICT (id) DO NOTHING;

-- Lessons --------------------------------------------------------------------
-- Module 7: Emergency & Urgent Care
INSERT INTO lessons (id, module_id, slug, title, description, lesson_type, difficulty, estimated_minutes, xp_reward, sort_order, is_published, intro_text, completion_text)
VALUES
  ('cccc0701-0000-4000-8000-000000000000', 'cccc0007-0000-4000-8000-000000000000', 'triage',
   'Triage & Priorities', 'Assess acuity and sort patients: emergent, urgent, and non-urgent.', 'standard', 'intermediate', 7, 50, 0, TRUE,
   'Learn the English of triage: acuity levels, vital signs, and rapid questions.',
   'Excellent! You can now triage patients in English.'),
  ('cccc0702-0000-4000-8000-000000000000', 'cccc0007-0000-4000-8000-000000000000', 'emergency-phrases',
   'Emergency Phrases', 'High-frequency commands and questions for the resuscitation bay.', 'standard', 'intermediate', 7, 50, 1, TRUE,
   'Learn the short, direct phrases used during an emergency.',
   'Well done! You can now give clear emergency instructions in English.'),
  ('cccc0703-0000-4000-8000-000000000000', 'cccc0007-0000-4000-8000-000000000000', 'chest-pain',
   'Chest Pain Protocol', 'Assess chest pain: onset, radiation, associated symptoms, and red flags.', 'standard', 'intermediate', 8, 50, 2, TRUE,
   'Learn how to work up chest pain in English, step by step.',
   'Great job! You can now assess chest pain in English.'),
  ('cccc0704-0000-4000-8000-000000000000', 'cccc0007-0000-4000-8000-000000000000', 'trauma-basics',
   'Trauma Basics', 'The primary survey: airway, breathing, circulation, disability, exposure.', 'standard', 'advanced', 8, 50, 3, TRUE,
   'Learn the ABCDE trauma vocabulary in English.',
   'Outstanding! You can now run a primary survey in English.'),
  ('cccc0705-0000-4000-8000-000000000000', 'cccc0007-0000-4000-8000-000000000000', 'emergency-review',
   'Emergency Review', 'Consolidate the emergency and urgent-care vocabulary from this module.', 'review', 'intermediate', 5, 50, 4, TRUE,
   'Time to review the emergency vocabulary you have learned.',
   'You have mastered the core emergency-care vocabulary of this module.')
ON CONFLICT (id) DO NOTHING;

-- Module 8: Lab Tests & Imaging
INSERT INTO lessons (id, module_id, slug, title, description, lesson_type, difficulty, estimated_minutes, xp_reward, sort_order, is_published, intro_text, completion_text)
VALUES
  ('cccc0801-0000-4000-8000-000000000000', 'cccc0008-0000-4000-8000-000000000000', 'blood-work',
   'Blood Work', 'Order and explain a CBC, metabolic panel, and common blood tests.', 'standard', 'intermediate', 7, 50, 0, TRUE,
   'Learn the English names of common blood tests and how to explain them.',
   'Excellent! You can now discuss blood work in English.'),
  ('cccc0802-0000-4000-8000-000000000000', 'cccc0008-0000-4000-8000-000000000000', 'urinalysis',
   'Urinalysis & Samples', 'Request urine and other samples and explain how to collect them.', 'standard', 'intermediate', 6, 50, 1, TRUE,
   'Learn how to request a sample and give clear collection instructions.',
   'Well done! You can now request and explain lab samples in English.'),
  ('cccc0803-0000-4000-8000-000000000000', 'cccc0008-0000-4000-8000-000000000000', 'x-ray-ct-mri',
   'X-ray, CT & MRI', 'Explain imaging studies, contrast, and safety questions.', 'standard', 'intermediate', 7, 50, 2, TRUE,
   'Learn the vocabulary of medical imaging in English.',
   'Great job! You can now explain imaging studies in English.'),
  ('cccc0804-0000-4000-8000-000000000000', 'cccc0008-0000-4000-8000-000000000000', 'explaining-results',
   'Explaining Results', 'Communicate normal and abnormal results clearly and kindly.', 'standard', 'advanced', 7, 50, 3, TRUE,
   'Learn how to explain test results to a patient in plain English.',
   'Excellent! You can now explain lab and imaging results in English.'),
  ('cccc0805-0000-4000-8000-000000000000', 'cccc0008-0000-4000-8000-000000000000', 'labs-review',
   'Labs & Imaging Review', 'Consolidate the lab and imaging vocabulary from this module.', 'review', 'intermediate', 5, 50, 4, TRUE,
   'Time to review the lab and imaging vocabulary you have learned.',
   'You have mastered the core lab and imaging vocabulary of this module.')
ON CONFLICT (id) DO NOTHING;

-- Module 9: Diagnosis & Treatment Plans
INSERT INTO lessons (id, module_id, slug, title, description, lesson_type, difficulty, estimated_minutes, xp_reward, sort_order, is_published, intro_text, completion_text)
VALUES
  ('cccc0901-0000-4000-8000-000000000000', 'cccc0009-0000-4000-8000-000000000000', 'giving-diagnosis',
   'Giving a Diagnosis', 'Deliver a diagnosis clearly, check understanding, and answer questions.', 'standard', 'advanced', 7, 50, 0, TRUE,
   'Learn how to deliver a diagnosis in clear, compassionate English.',
   'Excellent! You can now give a diagnosis in English.'),
  ('cccc0902-0000-4000-8000-000000000000', 'cccc0009-0000-4000-8000-000000000000', 'explaining-prognosis',
   'Explaining Prognosis', 'Talk about likely outcomes and timelines honestly and clearly.', 'standard', 'advanced', 7, 50, 1, TRUE,
   'Learn the English for discussing prognosis with a patient.',
   'Well done! You can now discuss prognosis in English.'),
  ('cccc0903-0000-4000-8000-000000000000', 'cccc0009-0000-4000-8000-000000000000', 'treatment-options',
   'Treatment Options', 'Present treatment options, benefits, and risks for shared decisions.', 'standard', 'advanced', 8, 50, 2, TRUE,
   'Learn how to present treatment options in English.',
   'Great job! You can now discuss treatment options in English.'),
  ('cccc0904-0000-4000-8000-000000000000', 'cccc0009-0000-4000-8000-000000000000', 'informed-consent',
   'Informed Consent', 'Explain a procedure, its risks, and obtain informed consent.', 'standard', 'advanced', 8, 50, 3, TRUE,
   'Learn the language of informed consent in English.',
   'Outstanding! You can now obtain informed consent in English.'),
  ('cccc0905-0000-4000-8000-000000000000', 'cccc0009-0000-4000-8000-000000000000', 'diagnosis-review',
   'Diagnosis & Treatment Review', 'Consolidate the diagnosis and treatment vocabulary from this module.', 'review', 'advanced', 5, 50, 4, TRUE,
   'Time to review the diagnosis and treatment vocabulary you have learned.',
   'You have mastered the core diagnosis and treatment vocabulary of this module.')
ON CONFLICT (id) DO NOTHING;

-- Module 10: Clinical Cases & Course Review
INSERT INTO lessons (id, module_id, slug, title, description, lesson_type, difficulty, estimated_minutes, xp_reward, sort_order, is_published, intro_text, completion_text)
VALUES
  ('cccc1001-0000-4000-8000-000000000000', 'cccc0010-0000-4000-8000-000000000000', 'case-abdominal-pain',
   'Case: Abdominal Pain', 'Work through a full clinical encounter for acute abdominal pain.', 'clinical_case', 'advanced', 8, 50, 0, TRUE,
   'Put it all together: a complete encounter for abdominal pain in English.',
   'Excellent! You handled a full abdominal-pain case in English.'),
  ('cccc1002-0000-4000-8000-000000000000', 'cccc0010-0000-4000-8000-000000000000', 'case-shortness-of-breath',
   'Case: Shortness of Breath', 'Work through a full clinical encounter for dyspnea.', 'clinical_case', 'advanced', 8, 50, 1, TRUE,
   'Put it all together: a complete encounter for shortness of breath.',
   'Well done! You handled a full dyspnea case in English.'),
  ('cccc1003-0000-4000-8000-000000000000', 'cccc0010-0000-4000-8000-000000000000', 'case-diabetes-followup',
   'Case: Diabetes Follow-up', 'Work through a chronic-disease follow-up visit for diabetes.', 'clinical_case', 'advanced', 7, 50, 2, TRUE,
   'Put it all together: a diabetes follow-up visit in English.',
   'Great job! You handled a full diabetes follow-up in English.'),
  ('cccc1004-0000-4000-8000-000000000000', 'cccc0010-0000-4000-8000-000000000000', 'course-review-1',
   'Course Review: Communication', 'Review core communication vocabulary from the whole course.', 'review', 'intermediate', 6, 50, 3, TRUE,
   'Review the essential communication vocabulary of the course.',
   'Outstanding! You have reviewed the core communication vocabulary.'),
  ('cccc1005-0000-4000-8000-000000000000', 'cccc0010-0000-4000-8000-000000000000', 'course-final',
   'Course Final Review', 'A final review across all ten modules of the course.', 'test', 'advanced', 8, 50, 4, TRUE,
   'The final review: everything you have learned across the course.',
   'Congratulations! You have completed Medical English Essentials.')
ON CONFLICT (id) DO NOTHING;

-- Exercises ------------------------------------------------------------------
-- Module 7, Lesson 1: Triage
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, xp_reward, sort_order, metadata, is_published)
VALUES
  ('cccc0701-0001-4000-8000-000000000000', 'cccc0701-0000-4000-8000-000000000000', 'multiple_choice',
   'A patient arrives with severe difficulty breathing. What triage level is this?',
   'Emergent — needs immediate care',
   'Severe respiratory distress is emergent and must be seen immediately.',
   'La dificultad respiratoria grave es emergente y debe atenderse de inmediato.',
   10, 0, '{"shuffle_options": true}'::jsonb, TRUE),
  ('cccc0701-0002-4000-8000-000000000000', 'cccc0701-0000-4000-8000-000000000000', 'translation',
   'Translate to English: "¿Cuándo comenzaron los síntomas?"',
   'When did the symptoms start?',
   'A rapid onset question is essential during triage.',
   'Preguntar por el inicio de los síntomas es esencial en el triaje.',
   10, 1, '{"source_language": "es", "target_language": "en", "source_text": "¿Cuándo comenzaron los síntomas?", "acceptable_translations": ["When did the symptoms start?", "When did the symptoms begin?"], "key_terms": ["symptoms", "start"]}'::jsonb, TRUE),
  ('cccc0701-0003-4000-8000-000000000000', 'cccc0701-0000-4000-8000-000000000000', 'fill_in_blank',
   'Complete: "On a scale of one to ten, how would you rate your ____?"',
   'pain',
   'The 0–10 pain scale is a core triage question.',
   'La escala de dolor 0–10 es una pregunta central del triaje.',
   10, 2, '{"acceptable_answers": ["pain"], "case_sensitive": false, "blank_position": "inline"}'::jsonb, TRUE),
  ('cccc0701-0004-4000-8000-000000000000', 'cccc0701-0000-4000-8000-000000000000', 'matching',
   'Match the triage level with its meaning.',
   'emergent—immediate; urgent—soon; non-urgent—can wait',
   'Triage sorts patients by how quickly they must be seen.',
   'El triaje clasifica a los pacientes por la rapidez con que deben ser vistos.',
   10, 3, '{"columns": 2}'::jsonb, TRUE),
  ('cccc0701-0005-4000-8000-000000000000', 'cccc0701-0000-4000-8000-000000000000', 'sentence_ordering',
   'Put the words in order to ask about allergies quickly.',
   'Are you allergic to any medications?',
   'A fast allergy check protects the patient before any treatment.',
   'Una verificación rápida de alergias protege al paciente antes de cualquier tratamiento.',
   10, 4, '{"words": ["Are", "you", "allergic", "to", "any", "medications?"], "show_punctuation": true}'::jsonb, TRUE),
-- Module 7, Lesson 2: Emergency Phrases
  ('cccc0702-0001-4000-8000-000000000000', 'cccc0702-0000-4000-8000-000000000000', 'multiple_choice',
   'Which phrase tells a team member to start chest compressions?',
   'Start compressions now.',
   'Short, direct commands prevent confusion during a resuscitation.',
   'Las órdenes cortas y directas evitan la confusión durante una reanimación.',
   10, 0, '{"shuffle_options": true}'::jsonb, TRUE),
  ('cccc0702-0002-4000-8000-000000000000', 'cccc0702-0000-4000-8000-000000000000', 'fill_in_blank',
   'Complete the command: "We need to ____ an IV line."',
   'start',
   '"Start an IV line" is the standard phrase for gaining venous access.',
   '"Start an IV line" es la frase estándar para obtener un acceso venoso.',
   10, 1, '{"acceptable_answers": ["start", "place", "insert"], "case_sensitive": false, "blank_position": "inline"}'::jsonb, TRUE),
  ('cccc0702-0003-4000-8000-000000000000', 'cccc0702-0000-4000-8000-000000000000', 'translation',
   'Translate to English: "Necesitamos oxígeno ahora."',
   'We need oxygen now.',
   'Requesting oxygen quickly and clearly is a common emergency phrase.',
   'Pedir oxígeno de forma rápida y clara es una frase de emergencia común.',
   10, 2, '{"source_language": "es", "target_language": "en", "source_text": "Necesitamos oxígeno ahora.", "acceptable_translations": ["We need oxygen now.", "We need oxygen right now."], "key_terms": ["oxygen"]}'::jsonb, TRUE),
  ('cccc0702-0004-4000-8000-000000000000', 'cccc0702-0000-4000-8000-000000000000', 'sentence_ordering',
   'Put the words in order to reassure the patient.',
   'Stay with me, help is coming.',
   'Calm reassurance keeps the patient cooperative during an emergency.',
   'Una reassurance tranquila mantiene al paciente cooperativo durante una emergencia.',
   10, 3, '{"words": ["Stay", "with", "me,", "help", "is", "coming."], "show_punctuation": true}'::jsonb, TRUE),
-- Module 7, Lesson 3: Chest Pain
  ('cccc0703-0001-4000-8000-000000000000', 'cccc0703-0000-4000-8000-000000000000', 'multiple_choice',
   'Which question checks whether chest pain is radiating?',
   'Does the pain spread to your arm or jaw?',
   'Radiation to the arm or jaw is a classic cardiac red flag.',
   'La irradiación al brazo o la mandíbula es una señal de alarma cardíaca clásica.',
   10, 0, '{"shuffle_options": true}'::jsonb, TRUE),
  ('cccc0703-0002-4000-8000-000000000000', 'cccc0703-0000-4000-8000-000000000000', 'fill_in_blank',
   'Complete: "Does anything make the pain ____ or worse?"',
   'better',
   'Asking about relieving and aggravating factors follows the OPQRST method.',
   'Preguntar por factores que alivian y agravan sigue el método OPQRST.',
   10, 1, '{"acceptable_answers": ["better"], "case_sensitive": false, "blank_position": "inline"}'::jsonb, TRUE),
  ('cccc0703-0003-4000-8000-000000000000', 'cccc0703-0000-4000-8000-000000000000', 'translation',
   'Translate to English: "¿El dolor le da falta de aire?"',
   'Does the pain give you shortness of breath?',
   'Associated dyspnea raises concern for a cardiac or pulmonary cause.',
   'La disnea asociada aumenta la sospecha de una causa cardíaca o pulmonar.',
   10, 2, '{"source_language": "es", "target_language": "en", "source_text": "¿El dolor le da falta de aire?", "acceptable_translations": ["Does the pain give you shortness of breath?", "Do you have shortness of breath with the pain?"], "key_terms": ["shortness of breath"]}'::jsonb, TRUE),
-- Module 7, Lesson 4: Trauma Basics
  ('cccc0704-0001-4000-8000-000000000000', 'cccc0704-0000-4000-8000-000000000000', 'multiple_choice',
   'In the ABCDE primary survey, what does "A" stand for?',
   'Airway',
   'ABCDE begins with Airway, then Breathing, Circulation, Disability, and Exposure.',
   'ABCDE comienza con la vía aérea (Airway), luego respiración, circulación, discapacidad y exposición.',
   10, 0, '{"shuffle_options": true}'::jsonb, TRUE),
  ('cccc0704-0002-4000-8000-000000000000', 'cccc0704-0000-4000-8000-000000000000', 'matching',
   'Match each ABCDE letter with its meaning.',
   'A—airway; B—breathing; C—circulation; D—disability',
   'The ABCDE sequence orders the trauma primary survey.',
   'La secuencia ABCDE ordena la evaluación primaria del trauma.',
   10, 1, '{"columns": 2}'::jsonb, TRUE),
  ('cccc0704-0003-4000-8000-000000000000', 'cccc0704-0000-4000-8000-000000000000', 'fill_in_blank',
   'Complete: "We need to control the ____." (heavy external bleeding)',
   'bleeding',
   'Controlling major bleeding is part of Circulation in the primary survey.',
   'Controlar el sangrado mayor es parte de la Circulación en la evaluación primaria.',
   10, 2, '{"acceptable_answers": ["bleeding", "hemorrhage"], "case_sensitive": false, "blank_position": "inline"}'::jsonb, TRUE),
-- Module 7, Lesson 5: Review
  ('cccc0705-0001-4000-8000-000000000000', 'cccc0705-0000-4000-8000-000000000000', 'translation',
   'Translate to English: "Vamos a estabilizarlo."',
   'We are going to stabilize you.',
   'Stabilization is the goal of the initial emergency response.',
   'La estabilización es el objetivo de la respuesta inicial de emergencia.',
   10, 0, '{"source_language": "es", "target_language": "en", "source_text": "Vamos a estabilizarlo.", "acceptable_translations": ["We are going to stabilize you.", "We will stabilize you."], "key_terms": ["stabilize"]}'::jsonb, TRUE),
  ('cccc0705-0002-4000-8000-000000000000', 'cccc0705-0000-4000-8000-000000000000', 'multiple_choice',
   'Which sign is a red flag with chest pain?',
   'Pain radiating to the left arm',
   'Radiation to the left arm suggests a possible cardiac event.',
   'La irradiación al brazo izquierdo sugiere un posible evento cardíaco.',
   10, 1, '{"shuffle_options": true}'::jsonb, TRUE),
  ('cccc0705-0003-4000-8000-000000000000', 'cccc0705-0000-4000-8000-000000000000', 'fill_in_blank',
   'Complete: "The patient is in respiratory ____." (severe breathing difficulty)',
   'distress',
   '"Respiratory distress" describes severe difficulty breathing.',
   '"Respiratory distress" describe una dificultad respiratoria grave.',
   10, 2, '{"acceptable_answers": ["distress"], "case_sensitive": false, "blank_position": "inline"}'::jsonb, TRUE),

-- Module 8, Lesson 1: Blood Work
  ('cccc0801-0001-4000-8000-000000000000', 'cccc0801-0000-4000-8000-000000000000', 'multiple_choice',
   'What does a CBC measure?',
   'Blood cells — red cells, white cells, and platelets',
   'A complete blood count (CBC) measures the cellular components of blood.',
   'Una biometría hemática (CBC) mide los componentes celulares de la sangre.',
   10, 0, '{"shuffle_options": true}'::jsonb, TRUE),
  ('cccc0801-0002-4000-8000-000000000000', 'cccc0801-0000-4000-8000-000000000000', 'translation',
   'Translate to English: "Necesitamos sacarle sangre."',
   'We need to draw your blood.',
   '"Draw blood" is the standard phrasal verb for taking a blood sample.',
   '"Draw blood" es el verbo estándar para tomar una muestra de sangre.',
   10, 1, '{"source_language": "es", "target_language": "en", "source_text": "Necesitamos sacarle sangre.", "acceptable_translations": ["We need to draw your blood.", "We need to take a blood sample."], "key_terms": ["draw", "blood"]}'::jsonb, TRUE),
  ('cccc0801-0003-4000-8000-000000000000', 'cccc0801-0000-4000-8000-000000000000', 'fill_in_blank',
   'Complete: "You may need to ____ for eight hours before the test." (no food)',
   'fast',
   'Many metabolic tests require the patient to fast beforehand.',
   'Muchas pruebas metabólicas requieren que el paciente ayune antes.',
   10, 2, '{"acceptable_answers": ["fast"], "case_sensitive": false, "blank_position": "inline"}'::jsonb, TRUE),
  ('cccc0801-0004-4000-8000-000000000000', 'cccc0801-0000-4000-8000-000000000000', 'matching',
   'Match each blood test with what it checks.',
   'CBC—blood cells; glucose—blood sugar; creatinine—kidney function',
   'Each common test targets a specific part of the body''s status.',
   'Cada prueba común evalúa un aspecto específico del estado del cuerpo.',
   10, 3, '{"columns": 2}'::jsonb, TRUE),
  ('cccc0801-0005-4000-8000-000000000000', 'cccc0801-0000-4000-8000-000000000000', 'sentence_ordering',
   'Put the words in order to warn about the needle.',
   'You will feel a small pinch.',
   'Warning the patient about a small pinch reduces anxiety.',
   'Avisar al paciente de un pequeño piquete reduce la ansiedad.',
   10, 4, '{"words": ["You", "will", "feel", "a", "small", "pinch."], "show_punctuation": true}'::jsonb, TRUE),
-- Module 8, Lesson 2: Urinalysis
  ('cccc0802-0001-4000-8000-000000000000', 'cccc0802-0000-4000-8000-000000000000', 'multiple_choice',
   'Which instruction describes a clean-catch urine sample?',
   'Clean first, then collect midstream urine',
   'A clean-catch midstream sample reduces contamination.',
   'Una muestra de chorro medio con limpieza previa reduce la contaminación.',
   10, 0, '{"shuffle_options": true}'::jsonb, TRUE),
  ('cccc0802-0002-4000-8000-000000000000', 'cccc0802-0000-4000-8000-000000000000', 'translation',
   'Translate to English: "Necesito una muestra de orina."',
   'I need a urine sample.',
   '"Urine sample" is the everyday clinical term.',
   '"Urine sample" es el término clínico cotidiano.',
   10, 1, '{"source_language": "es", "target_language": "en", "source_text": "Necesito una muestra de orina.", "acceptable_translations": ["I need a urine sample.", "I need a sample of urine."], "key_terms": ["urine sample"]}'::jsonb, TRUE),
  ('cccc0802-0003-4000-8000-000000000000', 'cccc0802-0000-4000-8000-000000000000', 'fill_in_blank',
   'Complete: "Please collect the sample in this sterile ____."',
   'cup',
   'A sterile cup or container is used to collect the sample.',
   'Se usa un vaso o recipiente estéril para recolectar la muestra.',
   10, 2, '{"acceptable_answers": ["cup", "container"], "case_sensitive": false, "blank_position": "inline"}'::jsonb, TRUE),
-- Module 8, Lesson 3: Imaging
  ('cccc0803-0001-4000-8000-000000000000', 'cccc0803-0000-4000-8000-000000000000', 'multiple_choice',
   'Which imaging study uses a strong magnetic field, not radiation?',
   'MRI',
   'An MRI uses magnetic fields; X-ray and CT use ionizing radiation.',
   'La resonancia magnética usa campos magnéticos; la radiografía y la TC usan radiación ionizante.',
   10, 0, '{"shuffle_options": true}'::jsonb, TRUE),
  ('cccc0803-0002-4000-8000-000000000000', 'cccc0803-0000-4000-8000-000000000000', 'translation',
   'Translate to English: "¿Es alérgico al contraste?"',
   'Are you allergic to contrast?',
   'Checking for a contrast allergy is essential before contrast imaging.',
   'Verificar la alergia al contraste es esencial antes de una imagen con contraste.',
   10, 1, '{"source_language": "es", "target_language": "en", "source_text": "¿Es alérgico al contraste?", "acceptable_translations": ["Are you allergic to contrast?", "Do you have a contrast allergy?"], "key_terms": ["contrast", "allergic"]}'::jsonb, TRUE),
  ('cccc0803-0003-4000-8000-000000000000', 'cccc0803-0000-4000-8000-000000000000', 'fill_in_blank',
   'Complete: "Please stay ____ during the scan." (do not move)',
   'still',
   'Staying still keeps the images sharp.',
   'Quedarse quieto mantiene las imágenes nítidas.',
   10, 2, '{"acceptable_answers": ["still"], "case_sensitive": false, "blank_position": "inline"}'::jsonb, TRUE),
-- Module 8, Lesson 4: Explaining Results
  ('cccc0804-0001-4000-8000-000000000000', 'cccc0804-0000-4000-8000-000000000000', 'multiple_choice',
   'Which sentence explains a normal result kindly?',
   'Your results came back normal — everything looks good.',
   'Plain, reassuring language helps the patient understand a normal result.',
   'Un lenguaje sencillo y tranquilizador ayuda al paciente a entender un resultado normal.',
   10, 0, '{"shuffle_options": true}'::jsonb, TRUE),
  ('cccc0804-0002-4000-8000-000000000000', 'cccc0804-0000-4000-8000-000000000000', 'translation',
   'Translate to English: "Sus resultados están un poco elevados."',
   'Your results are slightly elevated.',
   '"Slightly elevated" softens the delivery of an abnormal value.',
   '"Slightly elevated" suaviza la comunicación de un valor anormal.',
   10, 1, '{"source_language": "es", "target_language": "en", "source_text": "Sus resultados están un poco elevados.", "acceptable_translations": ["Your results are slightly elevated.", "Your results are a little high."], "key_terms": ["elevated"]}'::jsonb, TRUE),
  ('cccc0804-0003-4000-8000-000000000000', 'cccc0804-0000-4000-8000-000000000000', 'fill_in_blank',
   'Complete: "We will need to ____ this test in a few weeks." (do again)',
   'repeat',
   'Repeating a borderline test confirms a trend.',
   'Repetir una prueba limítrofe confirma una tendencia.',
   10, 2, '{"acceptable_answers": ["repeat", "recheck"], "case_sensitive": false, "blank_position": "inline"}'::jsonb, TRUE),
-- Module 8, Lesson 5: Review
  ('cccc0805-0001-4000-8000-000000000000', 'cccc0805-0000-4000-8000-000000000000', 'matching',
   'Match each study with the body area it images best.',
   'X-ray—bones; CT—internal organs; MRI—soft tissue',
   'Each imaging study has strengths for different tissues.',
   'Cada estudio de imagen tiene fortalezas para diferentes tejidos.',
   10, 0, '{"columns": 2}'::jsonb, TRUE),
  ('cccc0805-0002-4000-8000-000000000000', 'cccc0805-0000-4000-8000-000000000000', 'translation',
   'Translate to English: "Los resultados llegarán mañana."',
   'The results will be ready tomorrow.',
   'Setting a clear timeline reassures the patient.',
   'Establecer un plazo claro tranquiliza al paciente.',
   10, 1, '{"source_language": "es", "target_language": "en", "source_text": "Los resultados llegarán mañana.", "acceptable_translations": ["The results will be ready tomorrow.", "The results will come tomorrow."], "key_terms": ["results"]}'::jsonb, TRUE),
  ('cccc0805-0003-4000-8000-000000000000', 'cccc0805-0000-4000-8000-000000000000', 'fill_in_blank',
   'Complete: "This is a ____ test, so it is safe and painless." (no cutting)',
   'noninvasive',
   'A noninvasive test does not enter the body.',
   'Una prueba no invasiva no penetra el cuerpo.',
   10, 2, '{"acceptable_answers": ["noninvasive", "non-invasive"], "case_sensitive": false, "blank_position": "inline"}'::jsonb, TRUE),

-- Module 9, Lesson 1: Giving a Diagnosis
  ('cccc0901-0001-4000-8000-000000000000', 'cccc0901-0000-4000-8000-000000000000', 'multiple_choice',
   'Which phrase best begins delivering a diagnosis?',
   'I have your results, and I would like to talk about them.',
   'A warning shot prepares the patient before you share the diagnosis.',
   'Una frase de aviso prepara al paciente antes de compartir el diagnóstico.',
   10, 0, '{"shuffle_options": true}'::jsonb, TRUE),
  ('cccc0901-0002-4000-8000-000000000000', 'cccc0901-0000-4000-8000-000000000000', 'translation',
   'Translate to English: "El diagnóstico es diabetes tipo 2."',
   'The diagnosis is type 2 diabetes.',
   'Naming the diagnosis clearly avoids misunderstanding.',
   'Nombrar el diagnóstico con claridad evita malentendidos.',
   10, 1, '{"source_language": "es", "target_language": "en", "source_text": "El diagnóstico es diabetes tipo 2.", "acceptable_translations": ["The diagnosis is type 2 diabetes.", "The diagnosis is type two diabetes."], "key_terms": ["diagnosis", "diabetes"]}'::jsonb, TRUE),
  ('cccc0901-0003-4000-8000-000000000000', 'cccc0901-0000-4000-8000-000000000000', 'fill_in_blank',
   'Complete: "Do you have any ____ about the diagnosis?"',
   'questions',
   'Inviting questions checks the patient''s understanding.',
   'Invitar preguntas verifica la comprensión del paciente.',
   10, 2, '{"acceptable_answers": ["questions"], "case_sensitive": false, "blank_position": "inline"}'::jsonb, TRUE),
  ('cccc0901-0004-4000-8000-000000000000', 'cccc0901-0000-4000-8000-000000000000', 'sentence_ordering',
   'Put the words in order to check understanding.',
   'Can you tell me what you understood?',
   'Asking the patient to teach back confirms understanding.',
   'Pedir al paciente que repita con sus palabras confirma la comprensión.',
   10, 3, '{"words": ["Can", "you", "tell", "me", "what", "you", "understood?"], "show_punctuation": true}'::jsonb, TRUE),
  ('cccc0901-0005-4000-8000-000000000000', 'cccc0901-0000-4000-8000-000000000000', 'matching',
   'Match each phrase with its purpose.',
   'warning shot—prepare; teach-back—check understanding; pause—allow questions',
   'Structured phrases make hard conversations clearer.',
   'Las frases estructuradas hacen más claras las conversaciones difíciles.',
   10, 4, '{"columns": 2}'::jsonb, TRUE),
-- Module 9, Lesson 2: Prognosis
  ('cccc0902-0001-4000-8000-000000000000', 'cccc0902-0000-4000-8000-000000000000', 'multiple_choice',
   'Which sentence explains prognosis honestly but with hope?',
   'With treatment, most patients improve within a few weeks.',
   'Honest, specific language with a realistic timeline supports the patient.',
   'Un lenguaje honesto y específico con un plazo realista apoya al paciente.',
   10, 0, '{"shuffle_options": true}'::jsonb, TRUE),
  ('cccc0902-0002-4000-8000-000000000000', 'cccc0902-0000-4000-8000-000000000000', 'translation',
   'Translate to English: "Es una condición tratable."',
   'It is a treatable condition.',
   '"Treatable" gives the patient realistic hope.',
   '"Treatable" ofrece al paciente una esperanza realista.',
   10, 1, '{"source_language": "es", "target_language": "en", "source_text": "Es una condición tratable.", "acceptable_translations": ["It is a treatable condition.", "This is a treatable condition."], "key_terms": ["treatable"]}'::jsonb, TRUE),
  ('cccc0902-0003-4000-8000-000000000000', 'cccc0902-0000-4000-8000-000000000000', 'fill_in_blank',
   'Complete: "The ____ is good with proper treatment." (likely outcome)',
   'prognosis',
   '"Prognosis" is the expected course and outcome of a condition.',
   '"Prognosis" es el curso y desenlace esperados de una condición.',
   10, 2, '{"acceptable_answers": ["prognosis", "outlook"], "case_sensitive": false, "blank_position": "inline"}'::jsonb, TRUE),
-- Module 9, Lesson 3: Treatment Options
  ('cccc0903-0001-4000-8000-000000000000', 'cccc0903-0000-4000-8000-000000000000', 'multiple_choice',
   'Which sentence presents options for shared decision-making?',
   'There are two options; let us go over the benefits and risks of each.',
   'Presenting options with benefits and risks supports shared decisions.',
   'Presentar opciones con beneficios y riesgos apoya las decisiones compartidas.',
   10, 0, '{"shuffle_options": true}'::jsonb, TRUE),
  ('cccc0903-0002-4000-8000-000000000000', 'cccc0903-0000-4000-8000-000000000000', 'translation',
   'Translate to English: "Cada tratamiento tiene riesgos y beneficios."',
   'Each treatment has risks and benefits.',
   'Balancing risks and benefits is central to counseling.',
   'Equilibrar riesgos y beneficios es central en la consejería.',
   10, 1, '{"source_language": "es", "target_language": "en", "source_text": "Cada tratamiento tiene riesgos y beneficios.", "acceptable_translations": ["Each treatment has risks and benefits.", "Every treatment has risks and benefits."], "key_terms": ["risks", "benefits"]}'::jsonb, TRUE),
  ('cccc0903-0003-4000-8000-000000000000', 'cccc0903-0000-4000-8000-000000000000', 'fill_in_blank',
   'Complete: "Which option do you ____?" (choose)',
   'prefer',
   'Asking the patient''s preference invites shared decision-making.',
   'Preguntar la preferencia del paciente invita a la decisión compartida.',
   10, 2, '{"acceptable_answers": ["prefer", "choose"], "case_sensitive": false, "blank_position": "inline"}'::jsonb, TRUE),
-- Module 9, Lesson 4: Informed Consent
  ('cccc0904-0001-4000-8000-000000000000', 'cccc0904-0000-4000-8000-000000000000', 'multiple_choice',
   'What must informed consent include?',
   'The procedure, its risks, benefits, and alternatives',
   'Valid consent covers the procedure, risks, benefits, and alternatives.',
   'El consentimiento válido cubre el procedimiento, riesgos, beneficios y alternativas.',
   10, 0, '{"shuffle_options": true}'::jsonb, TRUE),
  ('cccc0904-0002-4000-8000-000000000000', 'cccc0904-0000-4000-8000-000000000000', 'translation',
   'Translate to English: "¿Tiene alguna pregunta antes de firmar?"',
   'Do you have any questions before you sign?',
   'Confirming understanding before signing is required for valid consent.',
   'Confirmar la comprensión antes de firmar es necesario para un consentimiento válido.',
   10, 1, '{"source_language": "es", "target_language": "en", "source_text": "¿Tiene alguna pregunta antes de firmar?", "acceptable_translations": ["Do you have any questions before you sign?", "Any questions before you sign?"], "key_terms": ["questions", "sign"]}'::jsonb, TRUE),
  ('cccc0904-0003-4000-8000-000000000000', 'cccc0904-0000-4000-8000-000000000000', 'fill_in_blank',
   'Complete: "You can ____ your consent at any time." (take back)',
   'withdraw',
   'Patients may withdraw consent at any point.',
   'Los pacientes pueden retirar el consentimiento en cualquier momento.',
   10, 2, '{"acceptable_answers": ["withdraw"], "case_sensitive": false, "blank_position": "inline"}'::jsonb, TRUE),
-- Module 9, Lesson 5: Review
  ('cccc0905-0001-4000-8000-000000000000', 'cccc0905-0000-4000-8000-000000000000', 'translation',
   'Translate to English: "Vamos a decidir juntos."',
   'We will decide together.',
   'Shared decision-making respects patient autonomy.',
   'La decisión compartida respeta la autonomía del paciente.',
   10, 0, '{"source_language": "es", "target_language": "en", "source_text": "Vamos a decidir juntos.", "acceptable_translations": ["We will decide together.", "Let us decide together."], "key_terms": ["decide together"]}'::jsonb, TRUE),
  ('cccc0905-0002-4000-8000-000000000000', 'cccc0905-0000-4000-8000-000000000000', 'multiple_choice',
   'Which word means the expected outcome of a condition?',
   'Prognosis',
   'Prognosis is the expected course and outcome.',
   'El pronóstico es el curso y desenlace esperados.',
   10, 1, '{"shuffle_options": true}'::jsonb, TRUE),
  ('cccc0905-0003-4000-8000-000000000000', 'cccc0905-0000-4000-8000-000000000000', 'fill_in_blank',
   'Complete: "Please sign this ____ form." (informed agreement)',
   'consent',
   'The consent form documents the patient''s informed agreement.',
   'El formulario de consentimiento documenta el acuerdo informado del paciente.',
   10, 2, '{"acceptable_answers": ["consent"], "case_sensitive": false, "blank_position": "inline"}'::jsonb, TRUE),

-- Module 10, Lesson 1: Case Abdominal Pain
  ('cccc1001-0001-4000-8000-000000000000', 'cccc1001-0000-4000-8000-000000000000', 'multiple_choice',
   'A patient reports sharp right-lower-quadrant pain. Which first question fits best?',
   'When did the pain start, and has it moved?',
   'Onset and migration help localize acute abdominal pain.',
   'El inicio y la migración ayudan a localizar el dolor abdominal agudo.',
   10, 0, '{"shuffle_options": true}'::jsonb, TRUE),
  ('cccc1001-0002-4000-8000-000000000000', 'cccc1001-0000-4000-8000-000000000000', 'translation',
   'Translate to English: "¿El dolor empeora al moverse?"',
   'Does the pain get worse when you move?',
   'Pain worsened by movement can suggest peritoneal irritation.',
   'El dolor que empeora con el movimiento puede sugerir irritación peritoneal.',
   10, 1, '{"source_language": "es", "target_language": "en", "source_text": "¿El dolor empeora al moverse?", "acceptable_translations": ["Does the pain get worse when you move?", "Does moving make the pain worse?"], "key_terms": ["worse", "move"]}'::jsonb, TRUE),
  ('cccc1001-0003-4000-8000-000000000000', 'cccc1001-0000-4000-8000-000000000000', 'fill_in_blank',
   'Complete: "I am going to ____ your abdomen; tell me if it hurts." (press)',
   'palpate',
   'Palpation of the abdomen localizes tenderness.',
   'La palpación del abdomen localiza la sensibilidad.',
   10, 2, '{"acceptable_answers": ["palpate", "press on", "examine"], "case_sensitive": false, "blank_position": "inline"}'::jsonb, TRUE),
  ('cccc1001-0004-4000-8000-000000000000', 'cccc1001-0000-4000-8000-000000000000', 'sentence_ordering',
   'Put the words in order to order a test.',
   'We will order some blood tests.',
   'Ordering blood tests is a common next step in the workup.',
   'Solicitar análisis de sangre es un siguiente paso común en el abordaje.',
   10, 3, '{"words": ["We", "will", "order", "some", "blood", "tests."], "show_punctuation": true}'::jsonb, TRUE),
-- Module 10, Lesson 2: Case Shortness of Breath
  ('cccc1002-0001-4000-8000-000000000000', 'cccc1002-0000-4000-8000-000000000000', 'multiple_choice',
   'A patient is short of breath. Which question screens for a cardiac cause?',
   'Do you have any chest pain or swelling in your legs?',
   'Chest pain and leg swelling point toward a cardiac cause of dyspnea.',
   'El dolor torácico y la hinchazón de piernas apuntan a una causa cardíaca de la disnea.',
   10, 0, '{"shuffle_options": true}'::jsonb, TRUE),
  ('cccc1002-0002-4000-8000-000000000000', 'cccc1002-0000-4000-8000-000000000000', 'translation',
   'Translate to English: "¿Desde cuándo le falta el aire?"',
   'How long have you had shortness of breath?',
   'Duration helps separate acute from chronic dyspnea.',
   'La duración ayuda a separar la disnea aguda de la crónica.',
   10, 1, '{"source_language": "es", "target_language": "en", "source_text": "¿Desde cuándo le falta el aire?", "acceptable_translations": ["How long have you had shortness of breath?", "How long have you been short of breath?"], "key_terms": ["shortness of breath"]}'::jsonb, TRUE),
  ('cccc1002-0003-4000-8000-000000000000', 'cccc1002-0000-4000-8000-000000000000', 'fill_in_blank',
   'Complete: "I am going to check your oxygen ____ with this device." (level)',
   'saturation',
   'Pulse oximetry measures oxygen saturation.',
   'La oximetría de pulso mide la saturación de oxígeno.',
   10, 2, '{"acceptable_answers": ["saturation", "level"], "case_sensitive": false, "blank_position": "inline"}'::jsonb, TRUE),
-- Module 10, Lesson 3: Case Diabetes Follow-up
  ('cccc1003-0001-4000-8000-000000000000', 'cccc1003-0000-4000-8000-000000000000', 'multiple_choice',
   'At a diabetes follow-up, which question checks control best?',
   'How have your blood sugar readings been at home?',
   'Home glucose readings reflect day-to-day control.',
   'Las lecturas de glucosa en casa reflejan el control diario.',
   10, 0, '{"shuffle_options": true}'::jsonb, TRUE),
  ('cccc1003-0002-4000-8000-000000000000', 'cccc1003-0000-4000-8000-000000000000', 'translation',
   'Translate to English: "¿Ha tenido bajones de azúcar?"',
   'Have you had any low blood sugar episodes?',
   'Screening for hypoglycemia is part of every diabetes visit.',
   'Detectar hipoglucemia es parte de toda visita por diabetes.',
   10, 1, '{"source_language": "es", "target_language": "en", "source_text": "¿Ha tenido bajones de azúcar?", "acceptable_translations": ["Have you had any low blood sugar episodes?", "Have you had any hypoglycemia?"], "key_terms": ["low blood sugar"]}'::jsonb, TRUE),
  ('cccc1003-0003-4000-8000-000000000000', 'cccc1003-0000-4000-8000-000000000000', 'fill_in_blank',
   'Complete: "We will check your A1C to see your ____ average." (three-month)',
   'three-month',
   'The A1C reflects the average blood sugar over about three months.',
   'La A1C refleja el promedio de azúcar en sangre de unos tres meses.',
   10, 2, '{"acceptable_answers": ["three-month", "3-month"], "case_sensitive": false, "blank_position": "inline"}'::jsonb, TRUE),
-- Module 10, Lesson 4: Course Review Communication
  ('cccc1004-0001-4000-8000-000000000000', 'cccc1004-0000-4000-8000-000000000000', 'matching',
   'Match each phrase with the moment it fits.',
   'chief complaint—intake; teach-back—diagnosis; follow-up—closing',
   'Each phrase belongs to a stage of the clinical encounter.',
   'Cada frase pertenece a una etapa del encuentro clínico.',
   10, 0, '{"columns": 2}'::jsonb, TRUE),
  ('cccc1004-0002-4000-8000-000000000000', 'cccc1004-0000-4000-8000-000000000000', 'translation',
   'Translate to English: "Nos vemos en dos semanas."',
   'I will see you in two weeks.',
   'Setting a follow-up interval closes the visit clearly.',
   'Fijar un intervalo de seguimiento cierra la visita con claridad.',
   10, 1, '{"source_language": "es", "target_language": "en", "source_text": "Nos vemos en dos semanas.", "acceptable_translations": ["I will see you in two weeks.", "See you in two weeks."], "key_terms": ["two weeks"]}'::jsonb, TRUE),
  ('cccc1004-0003-4000-8000-000000000000', 'cccc1004-0000-4000-8000-000000000000', 'fill_in_blank',
   'Complete: "What is the main ____ that brought you in today?" (reason)',
   'concern',
   'Asking the main concern opens the encounter.',
   'Preguntar la preocupación principal abre el encuentro.',
   10, 2, '{"acceptable_answers": ["concern", "problem", "reason"], "case_sensitive": false, "blank_position": "inline"}'::jsonb, TRUE),
-- Module 10, Lesson 5: Final
  ('cccc1005-0001-4000-8000-000000000000', 'cccc1005-0000-4000-8000-000000000000', 'multiple_choice',
   'Which sentence best closes a patient visit?',
   'Do you have any last questions before you go?',
   'Inviting final questions ensures the patient leaves informed.',
   'Invitar preguntas finales asegura que el paciente se vaya informado.',
   10, 0, '{"shuffle_options": true}'::jsonb, TRUE),
  ('cccc1005-0002-4000-8000-000000000000', 'cccc1005-0000-4000-8000-000000000000', 'translation',
   'Translate to English: "Cuídese mucho."',
   'Take good care of yourself.',
   'A warm closing builds rapport at the end of the visit.',
   'Un cierre cálido fortalece la relación al final de la visita.',
   10, 1, '{"source_language": "es", "target_language": "en", "source_text": "Cuídese mucho.", "acceptable_translations": ["Take good care of yourself.", "Take care of yourself."], "key_terms": ["take care"]}'::jsonb, TRUE),
  ('cccc1005-0003-4000-8000-000000000000', 'cccc1005-0000-4000-8000-000000000000', 'sentence_ordering',
   'Put the words in order to give discharge advice.',
   'Come back if the symptoms get worse.',
   'Clear return precautions keep the patient safe after discharge.',
   'Indicaciones de regreso claras mantienen al paciente seguro tras el alta.',
   10, 2, '{"words": ["Come", "back", "if", "the", "symptoms", "get", "worse."], "show_punctuation": true}'::jsonb, TRUE)
ON CONFLICT (id) DO NOTHING;

-- Exercise options (multiple_choice only) ------------------------------------
INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('cccc0701-0001-4000-8000-000000000000', 'Emergent — needs immediate care', TRUE, 0),
  ('cccc0701-0001-4000-8000-000000000000', 'Urgent — can wait a short while', FALSE, 1),
  ('cccc0701-0001-4000-8000-000000000000', 'Non-urgent — can wait', FALSE, 2),
  ('cccc0701-0001-4000-8000-000000000000', 'Routine — schedule later', FALSE, 3),
  ('cccc0702-0001-4000-8000-000000000000', 'Start compressions now.', TRUE, 0),
  ('cccc0702-0001-4000-8000-000000000000', 'Maybe we should think about it.', FALSE, 1),
  ('cccc0702-0001-4000-8000-000000000000', 'Please wait for the results.', FALSE, 2),
  ('cccc0702-0001-4000-8000-000000000000', 'Let us schedule an appointment.', FALSE, 3),
  ('cccc0703-0001-4000-8000-000000000000', 'Does the pain spread to your arm or jaw?', TRUE, 0),
  ('cccc0703-0001-4000-8000-000000000000', 'What did you eat today?', FALSE, 1),
  ('cccc0703-0001-4000-8000-000000000000', 'How is your family?', FALSE, 2),
  ('cccc0703-0001-4000-8000-000000000000', 'Do you exercise often?', FALSE, 3),
  ('cccc0704-0001-4000-8000-000000000000', 'Airway', TRUE, 0),
  ('cccc0704-0001-4000-8000-000000000000', 'Allergy', FALSE, 1),
  ('cccc0704-0001-4000-8000-000000000000', 'Abdomen', FALSE, 2),
  ('cccc0704-0001-4000-8000-000000000000', 'Assessment', FALSE, 3),
  ('cccc0705-0002-4000-8000-000000000000', 'Pain radiating to the left arm', TRUE, 0),
  ('cccc0705-0002-4000-8000-000000000000', 'Mild itching', FALSE, 1),
  ('cccc0705-0002-4000-8000-000000000000', 'A small bruise', FALSE, 2),
  ('cccc0705-0002-4000-8000-000000000000', 'Dry skin', FALSE, 3),
  ('cccc0801-0001-4000-8000-000000000000', 'Blood cells — red cells, white cells, and platelets', TRUE, 0),
  ('cccc0801-0001-4000-8000-000000000000', 'Only blood sugar', FALSE, 1),
  ('cccc0801-0001-4000-8000-000000000000', 'Only cholesterol', FALSE, 2),
  ('cccc0801-0001-4000-8000-000000000000', 'Kidney stones', FALSE, 3),
  ('cccc0802-0001-4000-8000-000000000000', 'Clean first, then collect midstream urine', TRUE, 0),
  ('cccc0802-0001-4000-8000-000000000000', 'Collect the first drops only', FALSE, 1),
  ('cccc0802-0001-4000-8000-000000000000', 'Collect it the next morning', FALSE, 2),
  ('cccc0802-0001-4000-8000-000000000000', 'Do not clean the area', FALSE, 3),
  ('cccc0803-0001-4000-8000-000000000000', 'MRI', TRUE, 0),
  ('cccc0803-0001-4000-8000-000000000000', 'X-ray', FALSE, 1),
  ('cccc0803-0001-4000-8000-000000000000', 'CT scan', FALSE, 2),
  ('cccc0803-0001-4000-8000-000000000000', 'Ultrasound', FALSE, 3),
  ('cccc0804-0001-4000-8000-000000000000', 'Your results came back normal — everything looks good.', TRUE, 0),
  ('cccc0804-0001-4000-8000-000000000000', 'I cannot tell you anything.', FALSE, 1),
  ('cccc0804-0001-4000-8000-000000000000', 'The numbers are just numbers.', FALSE, 2),
  ('cccc0804-0001-4000-8000-000000000000', 'You should not worry about it.', FALSE, 3),
  ('cccc0901-0001-4000-8000-000000000000', 'I have your results, and I would like to talk about them.', TRUE, 0),
  ('cccc0901-0001-4000-8000-000000000000', 'Nothing is wrong, goodbye.', FALSE, 1),
  ('cccc0901-0001-4000-8000-000000000000', 'You already know everything.', FALSE, 2),
  ('cccc0901-0001-4000-8000-000000000000', 'Let us skip the results.', FALSE, 3),
  ('cccc0902-0001-4000-8000-000000000000', 'With treatment, most patients improve within a few weeks.', TRUE, 0),
  ('cccc0902-0001-4000-8000-000000000000', 'There is no way to know anything.', FALSE, 1),
  ('cccc0902-0001-4000-8000-000000000000', 'You will be fine, do not ask.', FALSE, 2),
  ('cccc0902-0001-4000-8000-000000000000', 'It is impossible to treat.', FALSE, 3),
  ('cccc0903-0001-4000-8000-000000000000', 'There are two options; let us go over the benefits and risks of each.', TRUE, 0),
  ('cccc0903-0001-4000-8000-000000000000', 'There is only one choice, take it.', FALSE, 1),
  ('cccc0903-0001-4000-8000-000000000000', 'I will decide for you.', FALSE, 2),
  ('cccc0903-0001-4000-8000-000000000000', 'It does not matter what you think.', FALSE, 3),
  ('cccc0904-0001-4000-8000-000000000000', 'The procedure, its risks, benefits, and alternatives', TRUE, 0),
  ('cccc0904-0001-4000-8000-000000000000', 'Only the price', FALSE, 1),
  ('cccc0904-0001-4000-8000-000000000000', 'Only the date', FALSE, 2),
  ('cccc0904-0001-4000-8000-000000000000', 'Nothing at all', FALSE, 3),
  ('cccc0905-0002-4000-8000-000000000000', 'Prognosis', TRUE, 0),
  ('cccc0905-0002-4000-8000-000000000000', 'Dosage', FALSE, 1),
  ('cccc0905-0002-4000-8000-000000000000', 'Referral', FALSE, 2),
  ('cccc0905-0002-4000-8000-000000000000', 'Consent', FALSE, 3),
  ('cccc1001-0001-4000-8000-000000000000', 'When did the pain start, and has it moved?', TRUE, 0),
  ('cccc1001-0001-4000-8000-000000000000', 'What is your favorite food?', FALSE, 1),
  ('cccc1001-0001-4000-8000-000000000000', 'Do you like exercise?', FALSE, 2),
  ('cccc1001-0001-4000-8000-000000000000', 'How is the weather?', FALSE, 3),
  ('cccc1002-0001-4000-8000-000000000000', 'Do you have any chest pain or swelling in your legs?', TRUE, 0),
  ('cccc1002-0001-4000-8000-000000000000', 'What did you have for lunch?', FALSE, 1),
  ('cccc1002-0001-4000-8000-000000000000', 'Do you enjoy your work?', FALSE, 2),
  ('cccc1002-0001-4000-8000-000000000000', 'How many pets do you have?', FALSE, 3),
  ('cccc1003-0001-4000-8000-000000000000', 'How have your blood sugar readings been at home?', TRUE, 0),
  ('cccc1003-0001-4000-8000-000000000000', 'What time do you wake up?', FALSE, 1),
  ('cccc1003-0001-4000-8000-000000000000', 'Do you like your job?', FALSE, 2),
  ('cccc1003-0001-4000-8000-000000000000', 'How is traffic today?', FALSE, 3),
  ('cccc1005-0001-4000-8000-000000000000', 'Do you have any last questions before you go?', TRUE, 0),
  ('cccc1005-0001-4000-8000-000000000000', 'You should leave now.', FALSE, 1),
  ('cccc1005-0001-4000-8000-000000000000', 'I have nothing more to say.', FALSE, 2),
  ('cccc1005-0001-4000-8000-000000000000', 'Please do not ask anything.', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Vocabulary -----------------------------------------------------------------
INSERT INTO vocabulary (id, word, phonetic, translation_es, definition_en, definition_es, example_en, example_es, category, difficulty, tags, is_published)
VALUES
  -- Module 7: Emergency
  ('cccc9007-0000-4000-8000-000000000001', 'triage', '/ˈtriː.ɑːʒ/', 'triaje / clasificación',
   'Sorting patients by how urgently they need care.', 'Clasificar a los pacientes según la urgencia de atención.',
   'The nurse performs triage at the entrance.', 'La enfermera realiza el triaje en la entrada.', 'emergency', 'intermediate', ARRAY['triage'], TRUE),
  ('cccc9007-0000-4000-8000-000000000002', 'emergent', '/ɪˈmɜːr.dʒənt/', 'emergente',
   'Requiring immediate medical attention.', 'Que requiere atención médica inmediata.',
   'This is an emergent case; see the patient now.', 'Este es un caso emergente; vea al paciente ahora.', 'emergency', 'advanced', ARRAY['triage'], TRUE),
  ('cccc9007-0000-4000-8000-000000000003', 'resuscitation', '/rɪˌsʌs.ɪˈteɪ.ʃən/', 'reanimación',
   'Reviving someone from unconsciousness or near death.', 'Revivir a alguien de la inconsciencia o casi la muerte.',
   'The team began resuscitation immediately.', 'El equipo inició la reanimación de inmediato.', 'emergency', 'advanced', ARRAY['emergency'], TRUE),
  ('cccc9007-0000-4000-8000-000000000004', 'compressions', '/kəmˈprɛʃ.ənz/', 'compresiones',
   'Rhythmic pushes on the chest during CPR.', 'Empujes rítmicos en el pecho durante la RCP.',
   'Start chest compressions right away.', 'Inicie las compresiones torácicas de inmediato.', 'emergency', 'intermediate', ARRAY['cpr'], TRUE),
  ('cccc9007-0000-4000-8000-000000000005', 'airway', '/ˈɛər.weɪ/', 'vía aérea',
   'The passage through which air reaches the lungs.', 'El conducto por el que el aire llega a los pulmones.',
   'First, make sure the airway is clear.', 'Primero, asegúrese de que la vía aérea esté despejada.', 'emergency', 'intermediate', ARRAY['abcde'], TRUE),
  ('cccc9007-0000-4000-8000-000000000006', 'radiating', '/ˈreɪ.di.eɪ.tɪŋ/', 'irradiado',
   'Pain spreading from one area to another.', 'Dolor que se extiende de una zona a otra.',
   'The chest pain is radiating to the jaw.', 'El dolor de pecho se irradia a la mandíbula.', 'emergency', 'advanced', ARRAY['chest-pain'], TRUE),
  ('cccc9007-0000-4000-8000-000000000007', 'stabilize', '/ˈsteɪ.bɪ.laɪz/', 'estabilizar',
   'To make a patient''s condition stable and safe.', 'Hacer que la condición del paciente sea estable y segura.',
   'We need to stabilize the patient first.', 'Primero necesitamos estabilizar al paciente.', 'emergency', 'intermediate', ARRAY['emergency'], TRUE),
  ('cccc9007-0000-4000-8000-000000000008', 'bleeding', '/ˈbliː.dɪŋ/', 'sangrado / hemorragia',
   'Loss of blood from the body.', 'Pérdida de sangre del cuerpo.',
   'We must control the bleeding.', 'Debemos controlar el sangrado.', 'emergency', 'beginner', ARRAY['trauma'], TRUE),
  ('cccc9007-0000-4000-8000-000000000009', 'unconscious', '/ʌnˈkɒn.ʃəs/', 'inconsciente',
   'Not awake and not aware of surroundings.', 'Sin estar despierto ni consciente del entorno.',
   'The patient is unconscious but breathing.', 'El paciente está inconsciente pero respira.', 'emergency', 'intermediate', ARRAY['emergency'], TRUE),
  ('cccc9007-0000-4000-8000-000000000010', 'ambulance', '/ˈæm.bjə.ləns/', 'ambulancia',
   'A vehicle for transporting emergency patients.', 'Vehículo para transportar pacientes de emergencia.',
   'Call an ambulance immediately.', 'Llame a una ambulancia de inmediato.', 'emergency', 'beginner', ARRAY['emergency'], TRUE),
  ('cccc9007-0000-4000-8000-000000000011', 'distress', '/dɪˈstrɛs/', 'sufrimiento / dificultad',
   'Severe suffering, as in respiratory distress.', 'Sufrimiento intenso, como la dificultad respiratoria.',
   'The patient is in respiratory distress.', 'El paciente tiene dificultad respiratoria.', 'emergency', 'advanced', ARRAY['emergency'], TRUE),
  ('cccc9007-0000-4000-8000-000000000012', 'acuity', '/əˈkjuː.ɪ.ti/', 'gravedad / agudeza',
   'The severity or urgency of a patient''s condition.', 'La gravedad o urgencia de la condición de un paciente.',
   'Triage sorts patients by acuity.', 'El triaje clasifica a los pacientes por gravedad.', 'emergency', 'advanced', ARRAY['triage'], TRUE),
  -- Module 8: Labs & Imaging
  ('cccc9008-0000-4000-8000-000000000001', 'blood count', '/blʌd kaʊnt/', 'biometría hemática',
   'A test of the cells in the blood (CBC).', 'Prueba de las células de la sangre (biometría).',
   'The blood count showed a low white cell count.', 'La biometría mostró leucocitos bajos.', 'laboratory', 'intermediate', ARRAY['blood'], TRUE),
  ('cccc9008-0000-4000-8000-000000000002', 'draw blood', '/drɔː blʌd/', 'sacar sangre / extraer sangre',
   'To take a blood sample from a vein.', 'Tomar una muestra de sangre de una vena.',
   'The technician will draw your blood.', 'El técnico le sacará sangre.', 'laboratory', 'beginner', ARRAY['blood'], TRUE),
  ('cccc9008-0000-4000-8000-000000000003', 'fasting', '/ˈfɑːs.tɪŋ/', 'en ayunas',
   'Not eating before a test.', 'No comer antes de una prueba.',
   'This test requires fasting for eight hours.', 'Esta prueba requiere ayuno de ocho horas.', 'laboratory', 'intermediate', ARRAY['blood'], TRUE),
  ('cccc9008-0000-4000-8000-000000000004', 'urinalysis', '/ˌjʊə.rɪˈnæl.ə.sɪs/', 'análisis de orina',
   'Laboratory analysis of a urine sample.', 'Análisis de laboratorio de una muestra de orina.',
   'The urinalysis showed a urinary infection.', 'El análisis de orina mostró una infección urinaria.', 'laboratory', 'advanced', ARRAY['urine'], TRUE),
  ('cccc9008-0000-4000-8000-000000000005', 'sample', '/ˈsɑːm.pəl/', 'muestra',
   'A small amount taken for testing.', 'Pequeña cantidad tomada para análisis.',
   'I need a urine sample, please.', 'Necesito una muestra de orina, por favor.', 'laboratory', 'beginner', ARRAY['lab'], TRUE),
  ('cccc9008-0000-4000-8000-000000000006', 'X-ray', '/ˈɛks.reɪ/', 'radiografía',
   'An image of bones or organs made with radiation.', 'Imagen de huesos u órganos hecha con radiación.',
   'We will take an X-ray of your chest.', 'Le tomaremos una radiografía de tórax.', 'radiology', 'beginner', ARRAY['imaging'], TRUE),
  ('cccc9008-0000-4000-8000-000000000007', 'CT scan', '/ˌsiːˈtiː skæn/', 'tomografía (TC)',
   'A detailed cross-sectional X-ray image.', 'Imagen radiográfica transversal detallada.',
   'The CT scan showed no bleeding.', 'La tomografía no mostró sangrado.', 'radiology', 'intermediate', ARRAY['imaging'], TRUE),
  ('cccc9008-0000-4000-8000-000000000008', 'MRI', '/ˌɛm.ɑːrˈaɪ/', 'resonancia magnética',
   'Imaging using a strong magnetic field.', 'Imagen que usa un campo magnético fuerte.',
   'The MRI gives a clear view of soft tissue.', 'La resonancia da una vista clara del tejido blando.', 'radiology', 'intermediate', ARRAY['imaging'], TRUE),
  ('cccc9008-0000-4000-8000-000000000009', 'contrast', '/ˈkɒn.trɑːst/', 'medio de contraste',
   'A substance that improves imaging visibility.', 'Sustancia que mejora la visibilidad en las imágenes.',
   'Are you allergic to contrast?', '¿Es alérgico al contraste?', 'radiology', 'advanced', ARRAY['imaging'], TRUE),
  ('cccc9008-0000-4000-8000-000000000010', 'elevated', '/ˈɛl.ɪ.veɪ.tɪd/', 'elevado',
   'Higher than the normal value.', 'Más alto que el valor normal.',
   'Your glucose is slightly elevated.', 'Su glucosa está un poco elevada.', 'laboratory', 'intermediate', ARRAY['results'], TRUE),
  ('cccc9008-0000-4000-8000-000000000011', 'noninvasive', '/ˌnɒn.ɪnˈveɪ.sɪv/', 'no invasivo',
   'Not requiring entry into the body.', 'Que no requiere penetrar el cuerpo.',
   'An ultrasound is a noninvasive test.', 'El ultrasonido es una prueba no invasiva.', 'procedures', 'advanced', ARRAY['imaging'], TRUE),
  ('cccc9008-0000-4000-8000-000000000012', 'results', '/rɪˈzʌlts/', 'resultados',
   'The findings of a test.', 'Los hallazgos de una prueba.',
   'Your results will be ready tomorrow.', 'Sus resultados estarán listos mañana.', 'laboratory', 'beginner', ARRAY['results'], TRUE),
  -- Module 9: Diagnosis & Treatment
  ('cccc9009-0000-4000-8000-000000000001', 'diagnosis', '/ˌdaɪ.əɡˈnoʊ.sɪs/', 'diagnóstico',
   'Identification of a disease or condition.', 'Identificación de una enfermedad o condición.',
   'The diagnosis is type 2 diabetes.', 'El diagnóstico es diabetes tipo 2.', 'general', 'intermediate', ARRAY['diagnosis'], TRUE),
  ('cccc9009-0000-4000-8000-000000000002', 'prognosis', '/prɒɡˈnoʊ.sɪs/', 'pronóstico',
   'The likely course and outcome of a condition.', 'El curso y desenlace probables de una condición.',
   'The prognosis is good with treatment.', 'El pronóstico es bueno con tratamiento.', 'general', 'advanced', ARRAY['prognosis'], TRUE),
  ('cccc9009-0000-4000-8000-000000000003', 'treatable', '/ˈtriː.tə.bəl/', 'tratable',
   'Able to be managed or cured.', 'Que se puede manejar o curar.',
   'It is a treatable condition.', 'Es una condición tratable.', 'general', 'intermediate', ARRAY['treatment'], TRUE),
  ('cccc9009-0000-4000-8000-000000000004', 'treatment', '/ˈtriːt.mənt/', 'tratamiento',
   'Medical care given for a condition.', 'Atención médica dada para una condición.',
   'We will start treatment today.', 'Comenzaremos el tratamiento hoy.', 'general', 'beginner', ARRAY['treatment'], TRUE),
  ('cccc9009-0000-4000-8000-000000000005', 'risks', '/rɪsks/', 'riesgos',
   'The chances of harm from a treatment.', 'Las probabilidades de daño de un tratamiento.',
   'Every treatment has risks and benefits.', 'Todo tratamiento tiene riesgos y beneficios.', 'general', 'intermediate', ARRAY['treatment'], TRUE),
  ('cccc9009-0000-4000-8000-000000000006', 'benefits', '/ˈbɛn.ɪ.fɪts/', 'beneficios',
   'The good effects expected from a treatment.', 'Los efectos buenos esperados de un tratamiento.',
   'The benefits outweigh the risks here.', 'Aquí los beneficios superan los riesgos.', 'general', 'intermediate', ARRAY['treatment'], TRUE),
  ('cccc9009-0000-4000-8000-000000000007', 'informed consent', '/ɪnˈfɔːrmd kənˈsɛnt/', 'consentimiento informado',
   'Agreement to treatment after understanding it.', 'Acuerdo al tratamiento tras comprenderlo.',
   'Please sign the informed consent form.', 'Por favor firme el consentimiento informado.', 'general', 'advanced', ARRAY['consent'], TRUE),
  ('cccc9009-0000-4000-8000-000000000008', 'procedure', '/prəˈsiː.dʒər/', 'procedimiento',
   'A medical operation or intervention.', 'Una operación o intervención médica.',
   'The procedure takes about an hour.', 'El procedimiento dura alrededor de una hora.', 'procedures', 'intermediate', ARRAY['consent'], TRUE),
  ('cccc9009-0000-4000-8000-000000000009', 'withdraw', '/wɪðˈdrɔː/', 'retirar',
   'To take back consent or participation.', 'Retirar el consentimiento o la participación.',
   'You can withdraw your consent at any time.', 'Puede retirar su consentimiento en cualquier momento.', 'general', 'advanced', ARRAY['consent'], TRUE),
  ('cccc9009-0000-4000-8000-000000000010', 'alternatives', '/ɔːlˈtɜːr.nə.tɪvz/', 'alternativas',
   'Other options to a proposed treatment.', 'Otras opciones a un tratamiento propuesto.',
   'Let us discuss the alternatives.', 'Analicemos las alternativas.', 'general', 'advanced', ARRAY['treatment'], TRUE),
  ('cccc9009-0000-4000-8000-000000000011', 'prescribe', '/prɪˈskraɪb/', 'recetar',
   'To order a medication for a patient.', 'Ordenar un medicamento para un paciente.',
   'I will prescribe an antibiotic.', 'Le recetaré un antibiótico.', 'pharmacology', 'intermediate', ARRAY['treatment'], TRUE),
  ('cccc9009-0000-4000-8000-000000000012', 'follow-up', '/ˈfɒl.oʊ.ʌp/', 'seguimiento',
   'A later visit to check progress.', 'Una visita posterior para revisar el progreso.',
   'Let us schedule a follow-up in two weeks.', 'Programemos un seguimiento en dos semanas.', 'general', 'beginner', ARRAY['closing'], TRUE),
  -- Module 10: Clinical cases & review
  ('cccc9010-0000-4000-8000-000000000001', 'chief complaint', '/tʃiːf kəmˈpleɪnt/', 'motivo de consulta',
   'The main reason a patient seeks care.', 'La razón principal por la que un paciente busca atención.',
   'What is your chief complaint today?', '¿Cuál es su motivo de consulta hoy?', 'general', 'intermediate', ARRAY['intake'], TRUE),
  ('cccc9010-0000-4000-8000-000000000002', 'workup', '/ˈwɜːrk.ʌp/', 'estudio / abordaje diagnóstico',
   'The set of tests done to reach a diagnosis.', 'El conjunto de pruebas para llegar a un diagnóstico.',
   'We will begin the workup with blood tests.', 'Comenzaremos el abordaje con análisis de sangre.', 'general', 'advanced', ARRAY['diagnosis'], TRUE),
  ('cccc9010-0000-4000-8000-000000000003', 'discharge', '/ˈdɪs.tʃɑːrdʒ/', 'alta',
   'Releasing a patient from care.', 'Dar salida a un paciente de la atención.',
   'You will be ready for discharge tomorrow.', 'Estará listo para el alta mañana.', 'general', 'intermediate', ARRAY['closing'], TRUE),
  ('cccc9010-0000-4000-8000-000000000004', 'return precautions', '/rɪˈtɜːrn prɪˈkɔː.ʃənz/', 'signos de alarma para regresar',
   'Warning signs that should prompt a return visit.', 'Señales de alarma que deben motivar el regreso.',
   'I will explain the return precautions before you go.', 'Le explicaré los signos de alarma antes de irse.', 'general', 'advanced', ARRAY['closing'], TRUE),
  ('cccc9010-0000-4000-8000-000000000005', 'saturation', '/ˌsætʃ.əˈreɪ.ʃən/', 'saturación',
   'The percentage of oxygen in the blood.', 'El porcentaje de oxígeno en la sangre.',
   'Your oxygen saturation is ninety-eight percent.', 'Su saturación de oxígeno es del noventa y ocho por ciento.', 'general', 'advanced', ARRAY['vitals'], TRUE),
  ('cccc9010-0000-4000-8000-000000000006', 'tenderness', '/ˈtɛn.dər.nəs/', 'sensibilidad / dolor al tacto',
   'Pain felt when an area is touched.', 'Dolor que se siente al tocar una zona.',
   'There is tenderness in the lower right abdomen.', 'Hay sensibilidad en el abdomen inferior derecho.', 'pathology', 'advanced', ARRAY['exam'], TRUE),
  ('cccc9010-0000-4000-8000-000000000007', 'episode', '/ˈɛp.ɪ.soʊd/', 'episodio',
   'A single occurrence of symptoms.', 'Una sola ocurrencia de síntomas.',
   'Have you had any episodes of low blood sugar?', '¿Ha tenido episodios de azúcar baja?', 'general', 'intermediate', ARRAY['history'], TRUE),
  ('cccc9010-0000-4000-8000-000000000008', 'reading', '/ˈriː.dɪŋ/', 'lectura / medición',
   'A measured value, as of blood sugar.', 'Un valor medido, como el de azúcar en sangre.',
   'How have your blood sugar readings been?', '¿Cómo han estado sus mediciones de azúcar?', 'general', 'beginner', ARRAY['monitoring'], TRUE),
  ('cccc9010-0000-4000-8000-000000000009', 'concern', '/kənˈsɜːrn/', 'preocupación / motivo',
   'A worry or main issue a patient raises.', 'Una inquietud o asunto principal del paciente.',
   'What is your main concern today?', '¿Cuál es su principal preocupación hoy?', 'general', 'beginner', ARRAY['intake'], TRUE),
  ('cccc9010-0000-4000-8000-000000000010', 'reassure', '/ˌriː.əˈʃʊər/', 'tranquilizar',
   'To ease a patient''s worry with calm words.', 'Aliviar la preocupación del paciente con palabras calmadas.',
   'I want to reassure you that this is treatable.', 'Quiero tranquilizarlo: esto es tratable.', 'general', 'advanced', ARRAY['communication'], TRUE)
ON CONFLICT (id) DO NOTHING;

-- Lesson ↔ vocabulary links ---------------------------------------------------
INSERT INTO lesson_vocabulary (lesson_id, vocabulary_id, sort_order)
VALUES
  ('cccc0701-0000-4000-8000-000000000000', 'cccc9007-0000-4000-8000-000000000001', 0),
  ('cccc0701-0000-4000-8000-000000000000', 'cccc9007-0000-4000-8000-000000000002', 1),
  ('cccc0701-0000-4000-8000-000000000000', 'cccc9007-0000-4000-8000-000000000012', 2),
  ('cccc0702-0000-4000-8000-000000000000', 'cccc9007-0000-4000-8000-000000000003', 0),
  ('cccc0702-0000-4000-8000-000000000000', 'cccc9007-0000-4000-8000-000000000004', 1),
  ('cccc0702-0000-4000-8000-000000000000', 'cccc9007-0000-4000-8000-000000000005', 2),
  ('cccc0703-0000-4000-8000-000000000000', 'cccc9007-0000-4000-8000-000000000006', 0),
  ('cccc0703-0000-4000-8000-000000000000', 'cccc9007-0000-4000-8000-000000000011', 1),
  ('cccc0704-0000-4000-8000-000000000000', 'cccc9007-0000-4000-8000-000000000007', 0),
  ('cccc0704-0000-4000-8000-000000000000', 'cccc9007-0000-4000-8000-000000000008', 1),
  ('cccc0704-0000-4000-8000-000000000000', 'cccc9007-0000-4000-8000-000000000009', 2),
  ('cccc0705-0000-4000-8000-000000000000', 'cccc9007-0000-4000-8000-000000000010', 0),
  ('cccc0801-0000-4000-8000-000000000000', 'cccc9008-0000-4000-8000-000000000001', 0),
  ('cccc0801-0000-4000-8000-000000000000', 'cccc9008-0000-4000-8000-000000000002', 1),
  ('cccc0801-0000-4000-8000-000000000000', 'cccc9008-0000-4000-8000-000000000003', 2),
  ('cccc0802-0000-4000-8000-000000000000', 'cccc9008-0000-4000-8000-000000000004', 0),
  ('cccc0802-0000-4000-8000-000000000000', 'cccc9008-0000-4000-8000-000000000005', 1),
  ('cccc0803-0000-4000-8000-000000000000', 'cccc9008-0000-4000-8000-000000000006', 0),
  ('cccc0803-0000-4000-8000-000000000000', 'cccc9008-0000-4000-8000-000000000007', 1),
  ('cccc0803-0000-4000-8000-000000000000', 'cccc9008-0000-4000-8000-000000000008', 2),
  ('cccc0803-0000-4000-8000-000000000000', 'cccc9008-0000-4000-8000-000000000009', 3),
  ('cccc0804-0000-4000-8000-000000000000', 'cccc9008-0000-4000-8000-000000000010', 0),
  ('cccc0804-0000-4000-8000-000000000000', 'cccc9008-0000-4000-8000-000000000012', 1),
  ('cccc0805-0000-4000-8000-000000000000', 'cccc9008-0000-4000-8000-000000000011', 0),
  ('cccc0901-0000-4000-8000-000000000000', 'cccc9009-0000-4000-8000-000000000001', 0),
  ('cccc0902-0000-4000-8000-000000000000', 'cccc9009-0000-4000-8000-000000000002', 0),
  ('cccc0902-0000-4000-8000-000000000000', 'cccc9009-0000-4000-8000-000000000003', 1),
  ('cccc0903-0000-4000-8000-000000000000', 'cccc9009-0000-4000-8000-000000000004', 0),
  ('cccc0903-0000-4000-8000-000000000000', 'cccc9009-0000-4000-8000-000000000005', 1),
  ('cccc0903-0000-4000-8000-000000000000', 'cccc9009-0000-4000-8000-000000000006', 2),
  ('cccc0903-0000-4000-8000-000000000000', 'cccc9009-0000-4000-8000-000000000010', 3),
  ('cccc0904-0000-4000-8000-000000000000', 'cccc9009-0000-4000-8000-000000000007', 0),
  ('cccc0904-0000-4000-8000-000000000000', 'cccc9009-0000-4000-8000-000000000008', 1),
  ('cccc0904-0000-4000-8000-000000000000', 'cccc9009-0000-4000-8000-000000000009', 2),
  ('cccc0905-0000-4000-8000-000000000000', 'cccc9009-0000-4000-8000-000000000011', 0),
  ('cccc0905-0000-4000-8000-000000000000', 'cccc9009-0000-4000-8000-000000000012', 1),
  ('cccc1001-0000-4000-8000-000000000000', 'cccc9010-0000-4000-8000-000000000002', 0),
  ('cccc1001-0000-4000-8000-000000000000', 'cccc9010-0000-4000-8000-000000000006', 1),
  ('cccc1002-0000-4000-8000-000000000000', 'cccc9010-0000-4000-8000-000000000005', 0),
  ('cccc1003-0000-4000-8000-000000000000', 'cccc9010-0000-4000-8000-000000000007', 0),
  ('cccc1003-0000-4000-8000-000000000000', 'cccc9010-0000-4000-8000-000000000008', 1),
  ('cccc1004-0000-4000-8000-000000000000', 'cccc9010-0000-4000-8000-000000000001', 0),
  ('cccc1004-0000-4000-8000-000000000000', 'cccc9010-0000-4000-8000-000000000009', 1),
  ('cccc1005-0000-4000-8000-000000000000', 'cccc9010-0000-4000-8000-000000000003', 0),
  ('cccc1005-0000-4000-8000-000000000000', 'cccc9010-0000-4000-8000-000000000004', 1),
  ('cccc1005-0000-4000-8000-000000000000', 'cccc9010-0000-4000-8000-000000000010', 2)
ON CONFLICT DO NOTHING;

-- ---- pathway targeting: Essentials is the general/foundational track --------
UPDATE public.courses SET target_goals = ARRAY['general']
  WHERE id = '11111111-1111-1111-1111-111111111111';
