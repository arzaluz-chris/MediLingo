-- ============================================================================
-- MediLingo — Clinical English by Specialty (pathway: patient_care)
--
-- Course + 6 specialty modules (cardiology, pulmonology, pediatrics, emergency,
-- gastroenterology, neurology). Assembled from supabase/seed/pathways/clinical/.
-- Every row is is_published = FALSE (AI-drafted, pending physician validation);
-- the admin publishes after review. metadata validated against
-- shared/schemas/*.schema.json by scripts/validate-content.mjs (CI + local).
--
-- Idempotent: ON CONFLICT DO NOTHING throughout. Depends on migration
-- 20260708000000 (courses.target_goals column). Safe to re-run.
-- Rollback: DELETE FROM courses WHERE id = 'c0000000-0000-0000-0000-0000000000c0';
--           (cascades to modules/lessons/exercises/options/lesson_vocabulary)
--           DELETE FROM vocabulary WHERE id LIKE 'ca_c0000-%';
-- ============================================================================


-- ==== 00_course_modules ====
-- ============================================================================
-- MediLingo — Pathway: Clinical English by Specialty (primary_goal=patient_care)
-- Course + module scaffold. Lessons/exercises/vocab per module in 0M_*.sql.
-- AI-drafted — pending physician validation. is_published = FALSE (draft).
-- UUID scheme: course c000…c0 · modules cb00000M…cb · content caM… (M=module).
-- ============================================================================

INSERT INTO courses (id, slug, title, description, short_desc, color_hex, difficulty, category, target_role, target_goals, estimated_hours, sort_order, is_premium, is_published, is_featured)
VALUES (
  'c0000000-0000-0000-0000-0000000000c0',
  'clinical-english-specialty',
  'Clinical English by Specialty',
  'Real clinical communication in English across core specialties — cardiology, pulmonology, pediatrics, emergency, gastroenterology and neurology. History-taking, exam language, and case-based reasoning for Spanish-speaking clinicians.',
  'English for real clinical work, by specialty.',
  '#0EA5E9', 'intermediate', 'specialty', ARRAY['doctor','resident','nurse'], ARRAY['patient_care'], 14, 1, FALSE, FALSE, FALSE
) ON CONFLICT (id) DO NOTHING;

INSERT INTO modules (id, course_id, slug, title, description, sort_order, is_published)
VALUES
  ('cb000001-0000-0000-0000-0000000000cb', 'c0000000-0000-0000-0000-0000000000c0', 'cardiology',        'Cardiology — Chest Pain & Cardiac Care',     'Cardiac symptoms, history-taking, auscultation language, and an acute chest-pain case.', 0, FALSE),
  ('cb000002-0000-0000-0000-0000000000cb', 'c0000000-0000-0000-0000-0000000000c0', 'pulmonology',       'Pulmonology — Respiratory Assessment',       'Respiratory symptoms, breathing history, lung-exam language, and a dyspnea case.',       1, FALSE),
  ('cb000003-0000-0000-0000-0000000000cb', 'c0000000-0000-0000-0000-0000000000c0', 'pediatrics',        'Pediatrics — The Pediatric Encounter',       'Talking to caregivers and children, growth/immunization vocabulary, and a fever case.',  2, FALSE),
  ('cb000004-0000-0000-0000-0000000000cb', 'c0000000-0000-0000-0000-0000000000c0', 'emergency',         'Emergency — Acute & Trauma Care',            'Triage language, rapid history, trauma vocabulary, and an emergency case.',              3, FALSE),
  ('cb000005-0000-0000-0000-0000000000cb', 'c0000000-0000-0000-0000-0000000000c0', 'gastroenterology',  'Gastroenterology — Abdominal Complaints',    'GI symptoms, abdominal history and exam language, and an acute abdomen case.',           4, FALSE),
  ('cb000006-0000-0000-0000-0000000000cb', 'c0000000-0000-0000-0000-0000000000c0', 'neurology',         'Neurology — Neuro Assessment',               'Neurological symptoms, focused history, exam commands, and a stroke case.',              5, FALSE)
ON CONFLICT (id) DO NOTHING;

-- ==== 01_cardiology ====
-- ============================================================================
-- Clinical English by Specialty — Module 1: Cardiology (GOLD-STANDARD TEMPLATE)
-- module_id cb000001…cb · content UUIDs prefixed ca1… · is_published = FALSE
-- AI-drafted, pending physician validation.
-- ============================================================================

-- Lessons --------------------------------------------------------------------
INSERT INTO lessons (id, module_id, slug, title, description, lesson_type, difficulty, estimated_minutes, xp_reward, sort_order, is_published, intro_text, completion_text)
VALUES
  ('ca100001-0000-0000-0000-000000000001', 'cb000001-0000-0000-0000-0000000000cb', 'cardiac-vocabulary',
   'Cardiac Symptoms & Vocabulary', 'Core terms for cardiac symptoms and presentations.', 'standard', 'intermediate', 6, 50, 0, FALSE,
   'Learn the English terms patients and clinicians use for cardiac symptoms.', 'You can now name the key cardiac symptoms in English.'),
  ('ca100001-0000-0000-0000-000000000002', 'cb000001-0000-0000-0000-0000000000cb', 'cardiac-history',
   'Taking a Cardiac History', 'Ask focused questions about chest pain and cardiac risk.', 'standard', 'intermediate', 7, 60, 1, FALSE,
   'Practice the questions of a focused cardiac history (OPQRST).', 'You can now take a focused cardiac history in English.'),
  ('ca100001-0000-0000-0000-000000000003', 'cb000001-0000-0000-0000-0000000000cb', 'cardiac-exam',
   'The Cardiac Examination', 'Auscultation and exam language, said clearly.', 'pronunciation', 'intermediate', 6, 55, 2, FALSE,
   'Say cardiac exam terms clearly and give exam instructions.', 'Your cardiac exam English is clearer and more confident.'),
  ('ca100001-0000-0000-0000-000000000004', 'cb000001-0000-0000-0000-0000000000cb', 'acute-chest-pain-case',
   'Clinical Case: Acute Chest Pain', 'A 58-year-old with chest pain — reason through it in English.', 'clinical_case', 'intermediate', 9, 75, 3, FALSE,
   'Work through an acute chest-pain presentation in English.', 'You reasoned through an acute coronary presentation in English.'),
  ('ca100001-0000-0000-0000-000000000005', 'cb000001-0000-0000-0000-0000000000cb', 'cardiology-review',
   'Cardiology Review', 'Consolidate the module.', 'test', 'intermediate', 6, 60, 4, FALSE,
   'Review the cardiology module.', 'Cardiology module complete.')
ON CONFLICT (id) DO NOTHING;

-- Lesson 1 exercises ---------------------------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca1e0101-0000-0000-0000-000000000001', 'ca100001-0000-0000-0000-000000000001', 'multiple_choice',
   'A patient says "my heart is racing and skipping beats." Which term documents this?', 'Palpitations',
   'Palpitations = the subjective awareness of an irregular, forceful, or rapid heartbeat.', 'Palpitaciones = percepción subjetiva de latidos irregulares, fuertes o rápidos.',
   'intermediate', 10, 0, '{}'::jsonb, FALSE),
  ('ca1e0101-0000-0000-0000-000000000002', 'ca100001-0000-0000-0000-000000000001', 'flashcard',
   'dyspnea', 'disnea',
   'Difficult or labored breathing; often "shortness of breath" for patients.', 'Dificultad para respirar; para el paciente, "shortness of breath".',
   'intermediate', 10, 1, '{"front":{"text":"dyspnea","subtext":"/dɪspˈniːə/"},"back":{"text":"disnea","translation":"disnea","example":"The patient reports dyspnea on exertion.","explanation":"Use \"shortness of breath\" with patients; \"dyspnea\" in charts."}}'::jsonb, FALSE),
  ('ca1e0101-0000-0000-0000-000000000003', 'ca100001-0000-0000-0000-000000000001', 'fill_in_blank',
   'Complete: "Chest pain that occurs on exertion and is relieved by rest is called ______."', 'angina',
   'Stable angina is exertional chest pain relieved by rest or nitroglycerin.', 'La angina estable es dolor torácico de esfuerzo que cede con el reposo o nitroglicerina.',
   'intermediate', 10, 2, '{"acceptable_answers":["angina","stable angina","angina pectoris"],"case_sensitive":false}'::jsonb, FALSE),
  ('ca1e0101-0000-0000-0000-000000000004', 'ca100001-0000-0000-0000-000000000001', 'matching',
   'Match each cardiac term with its meaning.', NULL,
   'Core cardiac vocabulary.', 'Vocabulario cardíaco básico.',
   'intermediate', 10, 3, '{"columns":2}'::jsonb, FALSE),
  ('ca1e0101-0000-0000-0000-000000000005', 'ca100001-0000-0000-0000-000000000001', 'translation',
   'Translate to English: "El paciente presenta hinchazón en ambos tobillos."', 'The patient has swelling in both ankles.',
   '"Swelling" is the patient-friendly word for edema.', '"Swelling" es la palabra sencilla para edema.',
   'intermediate', 10, 4, '{"source_language":"es","target_language":"en","source_text":"El paciente presenta hinchazón en ambos tobillos.","acceptable_translations":["The patient has swelling in both ankles.","The patient has edema in both ankles.","There is swelling in both ankles."],"key_terms":["swelling","edema","ankles"]}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

-- matching options for ca1e0101-...004 (grouped by match_pair_id) -------------
INSERT INTO exercise_options (exercise_id, option_text, match_pair_id, sort_order)
VALUES
  ('ca1e0101-0000-0000-0000-000000000004', 'palpitations', 'p1', 0),
  ('ca1e0101-0000-0000-0000-000000000004', 'awareness of an irregular or rapid heartbeat', 'p1', 1),
  ('ca1e0101-0000-0000-0000-000000000004', 'syncope', 'p2', 2),
  ('ca1e0101-0000-0000-0000-000000000004', 'a transient loss of consciousness (fainting)', 'p2', 3),
  ('ca1e0101-0000-0000-0000-000000000004', 'edema', 'p3', 4),
  ('ca1e0101-0000-0000-0000-000000000004', 'swelling from fluid in the tissues', 'p3', 5),
  ('ca1e0101-0000-0000-0000-000000000004', 'diaphoresis', 'p4', 6),
  ('ca1e0101-0000-0000-0000-000000000004', 'excessive sweating', 'p4', 7)
ON CONFLICT DO NOTHING;

-- multiple-choice options for ca1e0101-...001 --------------------------------
INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca1e0101-0000-0000-0000-000000000001', 'Palpitations', TRUE, 0),
  ('ca1e0101-0000-0000-0000-000000000001', 'Claudication', FALSE, 1),
  ('ca1e0101-0000-0000-0000-000000000001', 'Orthopnea', FALSE, 2),
  ('ca1e0101-0000-0000-0000-000000000001', 'Bradycardia', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Lesson 2 exercises (cardiac history) ---------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca1e0201-0000-0000-0000-000000000001', 'ca100001-0000-0000-0000-000000000002', 'multiple_choice',
   'You want to know if chest pain spreads. Which question is most natural?', 'Does the pain radiate anywhere, like your arm or jaw?',
   '"Radiate" is the clinical verb; naming arm/jaw prompts the patient.', '"Radiate" es el verbo clínico; mencionar brazo/mandíbula guía al paciente.',
   'intermediate', 10, 0, '{}'::jsonb, FALSE),
  ('ca1e0201-0000-0000-0000-000000000002', 'ca100001-0000-0000-0000-000000000002', 'sentence_ordering',
   'Put the history question in order.', 'Does the pain get worse when you exert yourself?',
   'A question about exertional worsening — key for angina.', 'Pregunta sobre empeoramiento con el esfuerzo — clave en angina.',
   'intermediate', 10, 1, '{"words":["Does","the","pain","get","worse","when","you","exert","yourself"]}'::jsonb, FALSE),
  ('ca1e0201-0000-0000-0000-000000000003', 'ca100001-0000-0000-0000-000000000002', 'fill_in_blank',
   'Complete the OPQRST prompt: "On a scale of 0 to 10, how would you ______ the pain?"', 'rate',
   'Severity in OPQRST: "rate the pain" from 0 to 10.', 'Severidad en OPQRST: "rate the pain" de 0 a 10.',
   'intermediate', 10, 2, '{"acceptable_answers":["rate","score"],"case_sensitive":false,"word_bank":["rate","score","count","weigh"]}'::jsonb, FALSE),
  ('ca1e0201-0000-0000-0000-000000000004', 'ca100001-0000-0000-0000-000000000002', 'translation',
   'Translate to English: "¿El dolor le despierta por la noche?"', 'Does the pain wake you up at night?',
   'Nocturnal symptoms suggest unstable angina or heart failure.', 'Los síntomas nocturnos sugieren angina inestable o insuficiencia cardíaca.',
   'intermediate', 10, 3, '{"source_language":"es","target_language":"en","source_text":"¿El dolor le despierta por la noche?","acceptable_translations":["Does the pain wake you up at night?","Does the pain wake you at night?"],"key_terms":["wake up","at night"]}'::jsonb, FALSE),
  ('ca1e0201-0000-0000-0000-000000000005', 'ca100001-0000-0000-0000-000000000002', 'typing',
   'Type the clinical term: the "T" in OPQRST asks about the ______ of the pain (when it started, how long it lasts).', 'timing',
   'OPQRST: Onset, Provocation, Quality, Radiation, Severity, Timing.', 'OPQRST: inicio, provocación, calidad, irradiación, severidad, tiempo (timing).',
   'intermediate', 10, 4, '{"acceptable_answers":["timing","time"],"case_sensitive":false}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca1e0201-0000-0000-0000-000000000001', 'Does the pain radiate anywhere, like your arm or jaw?', TRUE, 0),
  ('ca1e0201-0000-0000-0000-000000000001', 'Is your pain psychological?', FALSE, 1),
  ('ca1e0201-0000-0000-0000-000000000001', 'Do you have pain?', FALSE, 2),
  ('ca1e0201-0000-0000-0000-000000000001', 'Why did you wait so long to come in?', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Lesson 3 exercises (cardiac exam — pronunciation) --------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca1e0301-0000-0000-0000-000000000001', 'ca100001-0000-0000-0000-000000000003', 'pronunciation',
   'Say the word: "auscultation"', 'auscultation',
   'Listening to internal sounds, usually with a stethoscope.', 'Auscultación: escuchar sonidos internos con estetoscopio.',
   'intermediate', 10, 0, '{"word":"auscultation","phonetic":"/ˌɔː.skəlˈteɪ.ʃən/","minimum_score":60,"syllables":["aus","cul","ta","tion"]}'::jsonb, FALSE),
  ('ca1e0301-0000-0000-0000-000000000002', 'ca100001-0000-0000-0000-000000000003', 'pronunciation',
   'Say the word: "murmur"', 'murmur',
   'A murmur is a whooshing sound from turbulent blood flow.', 'Un soplo (murmur) es un sonido por flujo turbulento.',
   'intermediate', 10, 1, '{"word":"murmur","phonetic":"/ˈmɜː.mər/","minimum_score":60,"common_mistakes":[{"mistake":"mur-MUR with a rolled r","correction":"soft English r, stress the first syllable: MUR-mur"}]}'::jsonb, FALSE),
  ('ca1e0301-0000-0000-0000-000000000003', 'ca100001-0000-0000-0000-000000000003', 'multiple_choice',
   'Which instruction asks the patient to help you hear the lung bases and heart better?', 'Take a deep breath in and slowly let it out.',
   'Deep breathing improves auscultation and is easy for patients to follow.', 'La respiración profunda mejora la auscultación y es fácil de seguir.',
   'intermediate', 10, 2, '{}'::jsonb, FALSE),
  ('ca1e0301-0000-0000-0000-000000000004', 'ca100001-0000-0000-0000-000000000003', 'fill_in_blank',
   'Complete: "I am going to listen to your heart. The first two heart sounds are called S1 and ______."', 'S2',
   'S1 (lub) and S2 (dub) are the normal heart sounds.', 'S1 (lub) y S2 (dub) son los ruidos cardíacos normales.',
   'intermediate', 10, 3, '{"acceptable_answers":["S2","s2","S two"],"case_sensitive":false}'::jsonb, FALSE),
  ('ca1e0301-0000-0000-0000-000000000005', 'ca100001-0000-0000-0000-000000000003', 'translation',
   'Translate to English (exam instruction): "Recuéstese y relaje los brazos, por favor."', 'Please lie back and relax your arms.',
   'Clear, polite exam commands keep the patient comfortable.', 'Órdenes de examen claras y educadas mantienen cómodo al paciente.',
   'intermediate', 10, 4, '{"source_language":"es","target_language":"en","source_text":"Recuéstese y relaje los brazos, por favor.","acceptable_translations":["Please lie back and relax your arms.","Lie back and relax your arms, please.","Please lie down and relax your arms."]}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca1e0301-0000-0000-0000-000000000003', 'Take a deep breath in and slowly let it out.', TRUE, 0),
  ('ca1e0301-0000-0000-0000-000000000003', 'Hold your breath forever.', FALSE, 1),
  ('ca1e0301-0000-0000-0000-000000000003', 'Talk quickly, please.', FALSE, 2),
  ('ca1e0301-0000-0000-0000-000000000003', 'Cough as hard as you can now.', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Lesson 4 exercises (clinical case: acute chest pain) -----------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca1e0401-0000-0000-0000-000000000001', 'ca100001-0000-0000-0000-000000000004', 'multiple_choice',
   'A 58-year-old man reports crushing substernal chest pain radiating to the left arm, with diaphoresis and nausea. Which is the priority action?', 'Obtain a 12-lead ECG and give aspirin.',
   'Acute coronary syndrome: an early ECG and aspirin are time-critical.', 'Síndrome coronario agudo: ECG temprano y aspirina son críticos.',
   'intermediate', 12, 0, '{}'::jsonb, FALSE),
  ('ca1e0401-0000-0000-0000-000000000002', 'ca100001-0000-0000-0000-000000000004', 'fill_in_blank',
   'Complete the handoff: "58-year-old male with crushing chest pain radiating to the left arm — I am concerned about acute ______ syndrome."', 'coronary',
   'Acute coronary syndrome (ACS) covers unstable angina and MI.', 'El síndrome coronario agudo (SCA) abarca angina inestable e infarto.',
   'intermediate', 12, 1, '{"acceptable_answers":["coronary"],"case_sensitive":false}'::jsonb, FALSE),
  ('ca1e0401-0000-0000-0000-000000000003', 'ca100001-0000-0000-0000-000000000004', 'translation',
   'Translate for the patient: "Le vamos a hacer un electrocardiograma ahora mismo."', 'We are going to do an ECG right now.',
   'ECG (US: EKG) — reassure the patient while acting quickly.', 'ECG (EE.UU.: EKG) — tranquilice al paciente mientras actúa rápido.',
   'intermediate', 12, 2, '{"source_language":"es","target_language":"en","source_text":"Le vamos a hacer un electrocardiograma ahora mismo.","acceptable_translations":["We are going to do an ECG right now.","We are going to do an EKG right now.","We will do an ECG right away."],"key_terms":["ECG","EKG","right now"]}'::jsonb, FALSE),
  ('ca1e0401-0000-0000-0000-000000000004', 'ca100001-0000-0000-0000-000000000004', 'sentence_ordering',
   'Order the reassuring instruction to the patient.', 'Try to stay calm and tell me if the pain changes.',
   'Calm, clear instructions reduce patient anxiety in the ED.', 'Instrucciones claras y calmadas reducen la ansiedad en urgencias.',
   'intermediate', 12, 3, '{"words":["Try","to","stay","calm","and","tell","me","if","the","pain","changes"]}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca1e0401-0000-0000-0000-000000000001', 'Obtain a 12-lead ECG and give aspirin.', TRUE, 0),
  ('ca1e0401-0000-0000-0000-000000000001', 'Send him home with reassurance.', FALSE, 1),
  ('ca1e0401-0000-0000-0000-000000000001', 'Order a routine outpatient stress test next month.', FALSE, 2),
  ('ca1e0401-0000-0000-0000-000000000001', 'Wait and see if the pain resolves on its own.', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Lesson 5 exercises (review/test) -------------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca1e0501-0000-0000-0000-000000000001', 'ca100001-0000-0000-0000-000000000005', 'multiple_choice',
   'Which symptom set most suggests heart failure rather than a simple cold?', 'Orthopnea, ankle edema, and exertional dyspnea',
   'Orthopnea + edema + exertional dyspnea is a classic heart-failure triad.', 'Ortopnea + edema + disnea de esfuerzo: tríada clásica de insuficiencia cardíaca.',
   'intermediate', 12, 0, '{}'::jsonb, FALSE),
  ('ca1e0501-0000-0000-0000-000000000002', 'ca100001-0000-0000-0000-000000000005', 'flashcard',
   'orthopnea', 'ortopnea',
   'Shortness of breath when lying flat, relieved by sitting up.', 'Disnea al estar acostado, que mejora al sentarse.',
   'intermediate', 10, 1, '{"front":{"text":"orthopnea","subtext":"/ɔːrˈθɒp.ni.ə/"},"back":{"text":"ortopnea","translation":"ortopnea","example":"She sleeps on three pillows because of orthopnea."}}'::jsonb, FALSE),
  ('ca1e0501-0000-0000-0000-000000000003', 'ca100001-0000-0000-0000-000000000005', 'typing',
   'Type the term: chest pain from myocardial ischemia, classically on exertion, is called ______.', 'angina',
   'Angina = ischemic chest pain, usually exertional.', 'Angina = dolor torácico isquémico, típicamente de esfuerzo.',
   'intermediate', 10, 2, '{"acceptable_answers":["angina","angina pectoris"],"case_sensitive":false}'::jsonb, FALSE),
  ('ca1e0501-0000-0000-0000-000000000004', 'ca100001-0000-0000-0000-000000000005', 'translation',
   'Translate to English: "¿Ha tenido alguna vez un infarto?"', 'Have you ever had a heart attack?',
   '"Heart attack" is the patient term for myocardial infarction.', '"Heart attack" es el término coloquial para infarto de miocardio.',
   'intermediate', 10, 3, '{"source_language":"es","target_language":"en","source_text":"¿Ha tenido alguna vez un infarto?","acceptable_translations":["Have you ever had a heart attack?","Have you ever had an MI?","Have you had a heart attack before?"],"key_terms":["heart attack","myocardial infarction"]}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca1e0501-0000-0000-0000-000000000001', 'Orthopnea, ankle edema, and exertional dyspnea', TRUE, 0),
  ('ca1e0501-0000-0000-0000-000000000001', 'Sneezing, sore throat, and runny nose', FALSE, 1),
  ('ca1e0501-0000-0000-0000-000000000001', 'Itchy eyes and rash', FALSE, 2),
  ('ca1e0501-0000-0000-0000-000000000001', 'Stubbed toe and bruising', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Vocabulary (module 1) ------------------------------------------------------
INSERT INTO vocabulary (id, word, phonetic, translation_es, definition_en, definition_es, example_en, example_es, category, difficulty, tags, is_published)
VALUES
  ('ca1c0000-0000-0000-0000-000000000001', 'palpitations', '/ˌpæl.pɪˈteɪ.ʃənz/', 'palpitaciones', 'A subjective awareness of an irregular, forceful, or rapid heartbeat.', 'Percepción subjetiva de latidos irregulares, fuertes o rápidos.', 'She came in with palpitations after climbing stairs.', 'Llegó con palpitaciones tras subir escaleras.', 'cardiology', 'intermediate', ARRAY['cardiac','symptom'], FALSE),
  ('ca1c0000-0000-0000-0000-000000000002', 'dyspnea', '/dɪspˈniː.ə/', 'disnea', 'Difficult or labored breathing; shortness of breath.', 'Respiración difícil o trabajosa; falta de aire.', 'He reports dyspnea on exertion.', 'Refiere disnea de esfuerzo.', 'cardiology', 'intermediate', ARRAY['cardiac','respiratory','symptom'], FALSE),
  ('ca1c0000-0000-0000-0000-000000000003', 'angina', '/ænˈdʒaɪ.nə/', 'angina', 'Chest pain due to myocardial ischemia, often on exertion.', 'Dolor torácico por isquemia miocárdica, a menudo con el esfuerzo.', 'His angina is relieved by rest.', 'Su angina cede con el reposo.', 'cardiology', 'intermediate', ARRAY['cardiac','symptom'], FALSE),
  ('ca1c0000-0000-0000-0000-000000000004', 'edema', '/ɪˈdiː.mə/', 'edema', 'Swelling caused by excess fluid in body tissues.', 'Hinchazón por exceso de líquido en los tejidos.', 'There is pitting edema in both ankles.', 'Hay edema con fóvea en ambos tobillos.', 'cardiology', 'intermediate', ARRAY['cardiac','sign'], FALSE),
  ('ca1c0000-0000-0000-0000-000000000005', 'syncope', '/ˈsɪŋ.kə.piː/', 'síncope', 'A transient loss of consciousness due to reduced cerebral blood flow.', 'Pérdida transitoria del conocimiento por menor flujo cerebral.', 'The syncope occurred while standing up.', 'El síncope ocurrió al ponerse de pie.', 'cardiology', 'intermediate', ARRAY['cardiac','symptom'], FALSE),
  ('ca1c0000-0000-0000-0000-000000000006', 'orthopnea', '/ɔːrˈθɒp.ni.ə/', 'ortopnea', 'Shortness of breath when lying flat, relieved by sitting up.', 'Disnea al acostarse que mejora al sentarse.', 'Her orthopnea requires three pillows.', 'Su ortopnea requiere tres almohadas.', 'cardiology', 'advanced', ARRAY['cardiac','symptom'], FALSE),
  ('ca1c0000-0000-0000-0000-000000000007', 'murmur', '/ˈmɜː.mər/', 'soplo', 'A whooshing heart sound from turbulent blood flow.', 'Sonido cardíaco por flujo sanguíneo turbulento.', 'A systolic murmur was heard at the apex.', 'Se auscultó un soplo sistólico en el ápex.', 'cardiology', 'intermediate', ARRAY['cardiac','sign','exam'], FALSE),
  ('ca1c0000-0000-0000-0000-000000000008', 'auscultation', '/ˌɔː.skəlˈteɪ.ʃən/', 'auscultación', 'Listening to internal body sounds, usually with a stethoscope.', 'Escuchar sonidos internos, generalmente con estetoscopio.', 'On auscultation, the lungs were clear.', 'A la auscultación, los pulmones estaban limpios.', 'cardiology', 'intermediate', ARRAY['exam','procedure'], FALSE),
  ('ca1c0000-0000-0000-0000-000000000009', 'diaphoresis', '/ˌdaɪ.ə.fəˈriː.sɪs/', 'diaforesis', 'Excessive sweating, often with acute cardiac events.', 'Sudoración excesiva, frecuente en eventos cardíacos agudos.', 'He was pale and had diaphoresis.', 'Estaba pálido y con diaforesis.', 'cardiology', 'advanced', ARRAY['cardiac','sign'], FALSE),
  ('ca1c0000-0000-0000-0000-00000000000a', 'myocardial infarction', '/ˌmaɪ.əˈkɑːr.di.əl ɪnˈfɑːrk.ʃən/', 'infarto de miocardio', 'Death of heart muscle from blocked coronary blood flow; a heart attack.', 'Muerte del músculo cardíaco por obstrucción coronaria; infarto.', 'The ECG confirmed a myocardial infarction.', 'El ECG confirmó un infarto de miocardio.', 'cardiology', 'advanced', ARRAY['cardiac','diagnosis'], FALSE)
ON CONFLICT (id) DO NOTHING;

-- Link vocabulary to lessons -------------------------------------------------
INSERT INTO lesson_vocabulary (lesson_id, vocabulary_id, sort_order)
VALUES
  ('ca100001-0000-0000-0000-000000000001', 'ca1c0000-0000-0000-0000-000000000001', 0),
  ('ca100001-0000-0000-0000-000000000001', 'ca1c0000-0000-0000-0000-000000000002', 1),
  ('ca100001-0000-0000-0000-000000000001', 'ca1c0000-0000-0000-0000-000000000003', 2),
  ('ca100001-0000-0000-0000-000000000001', 'ca1c0000-0000-0000-0000-000000000004', 3),
  ('ca100001-0000-0000-0000-000000000001', 'ca1c0000-0000-0000-0000-000000000005', 4),
  ('ca100001-0000-0000-0000-000000000003', 'ca1c0000-0000-0000-0000-000000000007', 5),
  ('ca100001-0000-0000-0000-000000000003', 'ca1c0000-0000-0000-0000-000000000008', 6),
  ('ca100001-0000-0000-0000-000000000005', 'ca1c0000-0000-0000-0000-000000000006', 7),
  ('ca100001-0000-0000-0000-000000000005', 'ca1c0000-0000-0000-0000-00000000000a', 8)
ON CONFLICT DO NOTHING;

-- ==== 02_pulmonology ====
-- ============================================================================
-- Clinical English by Specialty — Module 2: Pulmonology (Respiratory Assessment)
-- module_id cb000002…cb · content UUIDs prefixed ca2… · is_published = FALSE
-- AI-drafted, pending physician validation.
-- ============================================================================

-- Lessons --------------------------------------------------------------------
INSERT INTO lessons (id, module_id, slug, title, description, lesson_type, difficulty, estimated_minutes, xp_reward, sort_order, is_published, intro_text, completion_text)
VALUES
  ('ca200001-0000-0000-0000-000000000001', 'cb000002-0000-0000-0000-0000000000cb', 'respiratory-vocabulary',
   'Respiratory Symptoms & Vocabulary', 'Core terms for respiratory symptoms and presentations.', 'standard', 'intermediate', 6, 50, 0, FALSE,
   'Learn the English terms patients and clinicians use for respiratory symptoms.', 'You can now name the key respiratory symptoms in English.'),
  ('ca200001-0000-0000-0000-000000000002', 'cb000002-0000-0000-0000-0000000000cb', 'respiratory-history',
   'Taking a Respiratory History', 'Ask focused questions about cough, sputum, and breathlessness.', 'standard', 'intermediate', 7, 60, 1, FALSE,
   'Practice the questions of a focused respiratory history.', 'You can now take a focused respiratory history in English.'),
  ('ca200001-0000-0000-0000-000000000003', 'cb000002-0000-0000-0000-0000000000cb', 'chest-exam',
   'The Lung & Chest Examination', 'Auscultation, percussion, and exam language, said clearly.', 'pronunciation', 'intermediate', 6, 55, 2, FALSE,
   'Say chest exam terms clearly and give exam instructions.', 'Your chest exam English is clearer and more confident.'),
  ('ca200001-0000-0000-0000-000000000004', 'cb000002-0000-0000-0000-0000000000cb', 'acute-dyspnea-case',
   'Clinical Case: Acute Dyspnea', 'A 68-year-old with worsening breathlessness — reason through it in English.', 'clinical_case', 'intermediate', 9, 75, 3, FALSE,
   'Work through an acute dyspnea presentation in English.', 'You reasoned through a COPD exacerbation in English.'),
  ('ca200001-0000-0000-0000-000000000005', 'cb000002-0000-0000-0000-0000000000cb', 'pulmonology-review',
   'Pulmonology Review', 'Consolidate the module.', 'test', 'intermediate', 6, 60, 4, FALSE,
   'Review the pulmonology module.', 'Pulmonology module complete.')
ON CONFLICT (id) DO NOTHING;

-- Lesson 1 exercises (respiratory vocabulary) --------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca2e0101-0000-0000-0000-000000000001', 'ca200001-0000-0000-0000-000000000001', 'multiple_choice',
   'A patient says "I''ve been coughing up blood." Which term documents this?', 'Hemoptysis',
   'Hemoptysis = coughing up blood or blood-streaked sputum from the respiratory tract.', 'Hemoptisis = expectoración de sangre o esputo con sangre del tracto respiratorio.',
   'intermediate', 10, 0, '{}'::jsonb, FALSE),
  ('ca2e0101-0000-0000-0000-000000000002', 'ca200001-0000-0000-0000-000000000001', 'flashcard',
   'wheeze', 'sibilancia',
   'A high-pitched whistling sound, usually on expiration, from narrowed airways.', 'Sonido silbante agudo, generalmente espiratorio, por estrechamiento de las vías respiratorias.',
   'intermediate', 10, 1, '{"front":{"text":"wheeze","subtext":"/wiːz/"},"back":{"text":"sibilancia","translation":"sibilancia","example":"On auscultation there was an expiratory wheeze.","explanation":"Patients may say \"whistling\" in the chest; chart it as a \"wheeze\"."}}'::jsonb, FALSE),
  ('ca2e0101-0000-0000-0000-000000000003', 'ca200001-0000-0000-0000-000000000001', 'fill_in_blank',
   'Complete: "A cough that brings up mucus or phlegm is called a ______ cough."', 'productive',
   'A productive (or "wet") cough brings up sputum; a dry cough does not.', 'Una tos productiva (o "húmeda") expulsa esputo; la tos seca no.',
   'intermediate', 10, 2, '{"acceptable_answers":["productive","wet"],"case_sensitive":false,"word_bank":["productive","dry","wet","barking"]}'::jsonb, FALSE),
  ('ca2e0101-0000-0000-0000-000000000004', 'ca200001-0000-0000-0000-000000000001', 'matching',
   'Match each respiratory term with its meaning.', NULL,
   'Core respiratory vocabulary.', 'Vocabulario respiratorio básico.',
   'intermediate', 10, 3, '{"columns":2}'::jsonb, FALSE),
  ('ca2e0101-0000-0000-0000-000000000005', 'ca200001-0000-0000-0000-000000000001', 'translation',
   'Translate to English: "El paciente tiene tos con flema desde hace tres días."', 'The patient has had a productive cough for three days.',
   '"Phlegm" is the patient-friendly word for sputum; "productive cough" is the chart term.', '"Phlegm" es la palabra sencilla para esputo; "productive cough" es el término clínico.',
   'intermediate', 10, 4, '{"source_language":"es","target_language":"en","source_text":"El paciente tiene tos con flema desde hace tres días.","acceptable_translations":["The patient has had a productive cough for three days.","The patient has had a cough with phlegm for three days.","The patient has a productive cough for three days."],"key_terms":["productive cough","phlegm","sputum"]}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

-- matching options for ca2e0101-...004 (grouped by match_pair_id) -------------
INSERT INTO exercise_options (exercise_id, option_text, match_pair_id, sort_order)
VALUES
  ('ca2e0101-0000-0000-0000-000000000004', 'hemoptysis', 'p1', 0),
  ('ca2e0101-0000-0000-0000-000000000004', 'coughing up blood', 'p1', 1),
  ('ca2e0101-0000-0000-0000-000000000004', 'dyspnea', 'p2', 2),
  ('ca2e0101-0000-0000-0000-000000000004', 'difficult or labored breathing', 'p2', 3),
  ('ca2e0101-0000-0000-0000-000000000004', 'sputum', 'p3', 4),
  ('ca2e0101-0000-0000-0000-000000000004', 'mucus coughed up from the airways', 'p3', 5),
  ('ca2e0101-0000-0000-0000-000000000004', 'cyanosis', 'p4', 6),
  ('ca2e0101-0000-0000-0000-000000000004', 'bluish skin from low blood oxygen', 'p4', 7)
ON CONFLICT DO NOTHING;

-- multiple-choice options for ca2e0101-...001 --------------------------------
INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca2e0101-0000-0000-0000-000000000001', 'Hemoptysis', TRUE, 0),
  ('ca2e0101-0000-0000-0000-000000000001', 'Hematemesis', FALSE, 1),
  ('ca2e0101-0000-0000-0000-000000000001', 'Epistaxis', FALSE, 2),
  ('ca2e0101-0000-0000-0000-000000000001', 'Hematuria', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Lesson 2 exercises (respiratory history) -----------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca2e0201-0000-0000-0000-000000000001', 'ca200001-0000-0000-0000-000000000002', 'multiple_choice',
   'You want to know about the sputum. Which question is most useful?', 'What color is the phlegm you are coughing up?',
   'Sputum color and volume help distinguish infection from other causes.', 'El color y la cantidad del esputo ayudan a distinguir una infección de otras causas.',
   'intermediate', 10, 0, '{}'::jsonb, FALSE),
  ('ca2e0201-0000-0000-0000-000000000002', 'ca200001-0000-0000-0000-000000000002', 'sentence_ordering',
   'Put the history question in order.', 'How long have you been short of breath?',
   'Onset and duration of dyspnea guide the differential.', 'El inicio y la duración de la disnea orientan el diagnóstico diferencial.',
   'intermediate', 10, 1, '{"words":["How","long","have","you","been","short","of","breath"]}'::jsonb, FALSE),
  ('ca2e0201-0000-0000-0000-000000000003', 'ca200001-0000-0000-0000-000000000002', 'fill_in_blank',
   'Complete the question: "How many ______ of cigarettes have you smoked per day, and for how many years?"', 'packs',
   'Smoking history is quantified in pack-years (packs per day × years smoked).', 'El tabaquismo se cuantifica en paquetes-año (paquetes al día × años fumando).',
   'intermediate', 10, 2, '{"acceptable_answers":["packs","pack"],"case_sensitive":false}'::jsonb, FALSE),
  ('ca2e0201-0000-0000-0000-000000000004', 'ca200001-0000-0000-0000-000000000002', 'translation',
   'Translate to English: "¿Se despierta por la noche con falta de aire?"', 'Do you wake up at night short of breath?',
   'Nocturnal dyspnea suggests heart failure or poorly controlled asthma.', 'La disnea nocturna sugiere insuficiencia cardíaca o asma mal controlada.',
   'intermediate', 10, 3, '{"source_language":"es","target_language":"en","source_text":"¿Se despierta por la noche con falta de aire?","acceptable_translations":["Do you wake up at night short of breath?","Do you wake up at night out of breath?","Do you wake up short of breath at night?"],"key_terms":["wake up","short of breath","at night"]}'::jsonb, FALSE),
  ('ca2e0201-0000-0000-0000-000000000005', 'ca200001-0000-0000-0000-000000000002', 'typing',
   'Type the clinical term: breathlessness that occurs during physical activity is dyspnea on ______.', 'exertion',
   'Dyspnea on exertion (DOE) is breathlessness brought on by activity.', 'La disnea de esfuerzo (DOE) es la falta de aire provocada por la actividad.',
   'intermediate', 10, 4, '{"acceptable_answers":["exertion","effort"],"case_sensitive":false}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca2e0201-0000-0000-0000-000000000001', 'What color is the phlegm you are coughing up?', TRUE, 0),
  ('ca2e0201-0000-0000-0000-000000000001', 'Is your cough all in your head?', FALSE, 1),
  ('ca2e0201-0000-0000-0000-000000000001', 'Do you have a cough?', FALSE, 2),
  ('ca2e0201-0000-0000-0000-000000000001', 'Why do you smoke so much?', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Lesson 3 exercises (chest exam — pronunciation) ----------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca2e0301-0000-0000-0000-000000000001', 'ca200001-0000-0000-0000-000000000003', 'pronunciation',
   'Say the word: "percussion"', 'percussion',
   'Percussion = tapping the chest wall to judge whether the tissue beneath is air-filled or dull.', 'Percusión = golpear la pared torácica para valorar si el tejido subyacente contiene aire o es mate.',
   'intermediate', 10, 0, '{"word":"percussion","phonetic":"/pəˈkʌʃ.ən/","minimum_score":60,"syllables":["per","cus","sion"]}'::jsonb, FALSE),
  ('ca2e0301-0000-0000-0000-000000000002', 'ca200001-0000-0000-0000-000000000003', 'pronunciation',
   'Say the word: "cyanosis"', 'cyanosis',
   'Cyanosis is a bluish discoloration of the skin and lips from low blood oxygen.', 'La cianosis es una coloración azulada de la piel y los labios por baja oxigenación.',
   'intermediate', 10, 1, '{"word":"cyanosis","phonetic":"/ˌsaɪ.əˈnəʊ.sɪs/","minimum_score":60,"syllables":["cy","a","no","sis"],"common_mistakes":[{"mistake":"stressing the first syllable: CY-a-no-sis","correction":"stress the third syllable: cy-a-NO-sis"}]}'::jsonb, FALSE),
  ('ca2e0301-0000-0000-0000-000000000003', 'ca200001-0000-0000-0000-000000000003', 'multiple_choice',
   'Which instruction best helps you auscultate the lungs?', 'Breathe in and out through your mouth, a little deeper than usual.',
   'Deep mouth-breathing maximizes airflow so breath sounds are easier to hear.', 'Respirar hondo por la boca aumenta el flujo de aire y facilita oír los ruidos respiratorios.',
   'intermediate', 10, 2, '{}'::jsonb, FALSE),
  ('ca2e0301-0000-0000-0000-000000000004', 'ca200001-0000-0000-0000-000000000003', 'fill_in_blank',
   'Complete: "Fine ______ at the lung bases are crackling sounds often heard in pneumonia or pulmonary edema."', 'crackles',
   'Crackles (also called rales) are discontinuous popping sounds heard on inspiration.', 'Los crepitantes (estertores) son sonidos discontinuos que se oyen en la inspiración.',
   'intermediate', 10, 3, '{"acceptable_answers":["crackles","rales"],"case_sensitive":false}'::jsonb, FALSE),
  ('ca2e0301-0000-0000-0000-000000000005', 'ca200001-0000-0000-0000-000000000003', 'translation',
   'Translate to English (exam instruction): "Siéntese derecho y respire hondo por la boca, por favor."', 'Please sit up straight and take a deep breath through your mouth.',
   'Clear, polite exam commands help the patient cooperate with auscultation.', 'Órdenes de examen claras y educadas ayudan al paciente a cooperar con la auscultación.',
   'intermediate', 10, 4, '{"source_language":"es","target_language":"en","source_text":"Siéntese derecho y respire hondo por la boca, por favor.","acceptable_translations":["Please sit up straight and take a deep breath through your mouth.","Sit up straight and breathe deeply through your mouth, please.","Please sit up and take a deep breath through your mouth."]}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca2e0301-0000-0000-0000-000000000003', 'Breathe in and out through your mouth, a little deeper than usual.', TRUE, 0),
  ('ca2e0301-0000-0000-0000-000000000003', 'Hold your breath for as long as you can.', FALSE, 1),
  ('ca2e0301-0000-0000-0000-000000000003', 'Please keep talking while I listen.', FALSE, 2),
  ('ca2e0301-0000-0000-0000-000000000003', 'Breathe as shallowly as possible.', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Lesson 4 exercises (clinical case: acute dyspnea — COPD exacerbation) -------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca2e0401-0000-0000-0000-000000000001', 'ca200001-0000-0000-0000-000000000004', 'multiple_choice',
   'A 68-year-old with COPD has worsening dyspnea, purulent sputum, and wheeze. SpO2 is 86% on room air. What is the best oxygen strategy?', 'Give controlled oxygen, targeting an SpO2 of 88–92%.',
   'In COPD, controlled oxygen to a target of 88–92% avoids worsening hypercapnia from over-oxygenation.', 'En la EPOC, el oxígeno controlado con objetivo de 88–92% evita empeorar la hipercapnia por sobreoxigenación.',
   'intermediate', 12, 0, '{}'::jsonb, FALSE),
  ('ca2e0401-0000-0000-0000-000000000002', 'ca200001-0000-0000-0000-000000000004', 'fill_in_blank',
   'Complete: "The three cardinal symptoms of a COPD exacerbation are increased dyspnea, increased sputum volume, and increased sputum ______."', 'purulence',
   'Increased sputum purulence is a key Anthonisen criterion and supports starting antibiotics.', 'El aumento de la purulencia del esputo es un criterio de Anthonisen y apoya iniciar antibióticos.',
   'intermediate', 12, 1, '{"acceptable_answers":["purulence","purulency"],"case_sensitive":false}'::jsonb, FALSE),
  ('ca2e0401-0000-0000-0000-000000000003', 'ca200001-0000-0000-0000-000000000004', 'translation',
   'Translate for the patient: "Le vamos a poner un nebulizador para abrir las vías respiratorias."', 'We are going to give you a nebulizer to open your airways.',
   'Explaining the nebulizer reassures the patient while you deliver a bronchodilator.', 'Explicar el nebulizador tranquiliza al paciente mientras administra un broncodilatador.',
   'intermediate', 12, 2, '{"source_language":"es","target_language":"en","source_text":"Le vamos a poner un nebulizador para abrir las vías respiratorias.","acceptable_translations":["We are going to give you a nebulizer to open your airways.","We are going to give you a nebulizer treatment to open your airways.","We will give you a nebulizer to open your airways."],"key_terms":["nebulizer","airways","open"]}'::jsonb, FALSE),
  ('ca2e0401-0000-0000-0000-000000000004', 'ca200001-0000-0000-0000-000000000004', 'sentence_ordering',
   'Order the reassuring instruction to the patient.', 'Try to take slow, deep breaths through the mask.',
   'Calm, clear coaching helps a breathless patient tolerate the mask.', 'Un acompañamiento claro y calmado ayuda al paciente disneico a tolerar la mascarilla.',
   'intermediate', 12, 3, '{"words":["Try","to","take","slow","deep","breaths","through","the","mask"]}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca2e0401-0000-0000-0000-000000000001', 'Give controlled oxygen, targeting an SpO2 of 88–92%.', TRUE, 0),
  ('ca2e0401-0000-0000-0000-000000000001', 'Apply high-flow oxygen to reach an SpO2 of 100%.', FALSE, 1),
  ('ca2e0401-0000-0000-0000-000000000001', 'Withhold all oxygen to protect the respiratory drive.', FALSE, 2),
  ('ca2e0401-0000-0000-0000-000000000001', 'Delay oxygen until the arterial blood gas returns.', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Lesson 5 exercises (review/test) -------------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca2e0501-0000-0000-0000-000000000001', 'ca200001-0000-0000-0000-000000000005', 'multiple_choice',
   'Which symptom set most suggests pneumonia rather than a simple cold?', 'Fever, productive cough with purulent sputum, and pleuritic chest pain',
   'Fever + purulent sputum + pleuritic pain points to a lower respiratory tract infection.', 'Fiebre + esputo purulento + dolor pleurítico orienta a una infección respiratoria baja.',
   'intermediate', 12, 0, '{}'::jsonb, FALSE),
  ('ca2e0501-0000-0000-0000-000000000002', 'ca200001-0000-0000-0000-000000000005', 'flashcard',
   'tachypnea', 'taquipnea',
   'An abnormally rapid respiratory rate (in adults, more than 20 breaths per minute).', 'Frecuencia respiratoria anormalmente rápida (en adultos, más de 20 respiraciones por minuto).',
   'intermediate', 10, 1, '{"front":{"text":"tachypnea","subtext":"/ˌtæk.ɪpˈniː.ə/"},"back":{"text":"taquipnea","translation":"taquipnea","example":"He was tachypneic with a rate of 28.","explanation":"Compare with bradypnea (slow) and apnea (absent breathing)."}}'::jsonb, FALSE),
  ('ca2e0501-0000-0000-0000-000000000003', 'ca200001-0000-0000-0000-000000000005', 'typing',
   'Type the term: coughing up blood from the respiratory tract is called ______.', 'hemoptysis',
   'Hemoptysis = coughing up blood or blood-streaked sputum.', 'Hemoptisis = expectoración de sangre o esputo con sangre.',
   'intermediate', 10, 2, '{"acceptable_answers":["hemoptysis","haemoptysis"],"case_sensitive":false}'::jsonb, FALSE),
  ('ca2e0501-0000-0000-0000-000000000004', 'ca200001-0000-0000-0000-000000000005', 'translation',
   'Translate to English: "¿Alguna vez ha usado un inhalador para respirar mejor?"', 'Have you ever used an inhaler to help you breathe?',
   '"Inhaler" is the everyday word patients use for a metered-dose bronchodilator.', '"Inhaler" es la palabra cotidiana que usan los pacientes para el broncodilatador de dosis medida.',
   'intermediate', 10, 3, '{"source_language":"es","target_language":"en","source_text":"¿Alguna vez ha usado un inhalador para respirar mejor?","acceptable_translations":["Have you ever used an inhaler to help you breathe?","Have you ever used an inhaler to breathe better?","Have you used an inhaler to help you breathe before?"],"key_terms":["inhaler","breathe"]}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca2e0501-0000-0000-0000-000000000001', 'Fever, productive cough with purulent sputum, and pleuritic chest pain', TRUE, 0),
  ('ca2e0501-0000-0000-0000-000000000001', 'Itchy eyes, sneezing, and a runny nose', FALSE, 1),
  ('ca2e0501-0000-0000-0000-000000000001', 'A single sneeze and a mild headache', FALSE, 2),
  ('ca2e0501-0000-0000-0000-000000000001', 'Sore muscles after exercise', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Vocabulary (module 2) ------------------------------------------------------
INSERT INTO vocabulary (id, word, phonetic, translation_es, definition_en, definition_es, example_en, example_es, category, difficulty, tags, is_published)
VALUES
  ('ca2c0000-0000-0000-0000-000000000001', 'cough', '/kɒf/', 'tos', 'A sudden, forceful expulsion of air from the lungs to clear the airways.', 'Expulsión súbita y forzada de aire de los pulmones para despejar las vías respiratorias.', 'She has had a dry cough for two weeks.', 'Tiene tos seca desde hace dos semanas.', 'pulmonology', 'intermediate', ARRAY['respiratory','symptom'], FALSE),
  ('ca2c0000-0000-0000-0000-000000000002', 'wheeze', '/wiːz/', 'sibilancia', 'A high-pitched whistling sound, usually on expiration, from narrowed airways.', 'Sonido silbante agudo, generalmente espiratorio, por estrechamiento de las vías respiratorias.', 'An expiratory wheeze was heard bilaterally.', 'Se auscultó sibilancia espiratoria bilateral.', 'pulmonology', 'intermediate', ARRAY['respiratory','sign','exam'], FALSE),
  ('ca2c0000-0000-0000-0000-000000000003', 'sputum', '/ˈspjuː.təm/', 'esputo', 'Mucus coughed up from the lower airways; phlegm.', 'Moco expulsado con la tos desde las vías respiratorias bajas; flema.', 'The sputum was thick and green.', 'El esputo era espeso y verdoso.', 'pulmonology', 'intermediate', ARRAY['respiratory','symptom'], FALSE),
  ('ca2c0000-0000-0000-0000-000000000004', 'hemoptysis', '/hɪˈmɒp.tɪ.sɪs/', 'hemoptisis', 'Coughing up blood or blood-streaked sputum from the respiratory tract.', 'Expectoración de sangre o esputo con sangre del tracto respiratorio.', 'He presented with hemoptysis and weight loss.', 'Se presentó con hemoptisis y pérdida de peso.', 'pulmonology', 'advanced', ARRAY['respiratory','symptom'], FALSE),
  ('ca2c0000-0000-0000-0000-000000000005', 'dyspnea', '/dɪspˈniː.ə/', 'disnea', 'Difficult or labored breathing; shortness of breath.', 'Respiración difícil o trabajosa; falta de aire.', 'She reports dyspnea when climbing stairs.', 'Refiere disnea al subir escaleras.', 'pulmonology', 'intermediate', ARRAY['respiratory','symptom'], FALSE),
  ('ca2c0000-0000-0000-0000-000000000006', 'crackles', '/ˈkræk.əlz/', 'crepitantes', 'Discontinuous popping sounds heard on inspiration; also called rales.', 'Sonidos discontinuos de chasquido que se oyen en la inspiración; también llamados estertores.', 'Fine crackles were heard at both lung bases.', 'Se auscultaron crepitantes finos en ambas bases pulmonares.', 'pulmonology', 'intermediate', ARRAY['respiratory','sign','exam'], FALSE),
  ('ca2c0000-0000-0000-0000-000000000007', 'cyanosis', '/ˌsaɪ.əˈnəʊ.sɪs/', 'cianosis', 'A bluish discoloration of the skin and mucous membranes from low blood oxygen.', 'Coloración azulada de la piel y mucosas por baja oxigenación de la sangre.', 'Central cyanosis was visible on the lips.', 'Se observó cianosis central en los labios.', 'pulmonology', 'advanced', ARRAY['respiratory','sign'], FALSE),
  ('ca2c0000-0000-0000-0000-000000000008', 'tachypnea', '/ˌtæk.ɪpˈniː.ə/', 'taquipnea', 'An abnormally rapid respiratory rate.', 'Frecuencia respiratoria anormalmente rápida.', 'The patient was tachypneic at 30 breaths per minute.', 'El paciente estaba taquipneico a 30 respiraciones por minuto.', 'pulmonology', 'advanced', ARRAY['respiratory','sign'], FALSE),
  ('ca2c0000-0000-0000-0000-000000000009', 'percussion', '/pəˈkʌʃ.ən/', 'percusión', 'Tapping the chest wall to judge whether the underlying tissue is resonant or dull.', 'Golpear la pared torácica para valorar si el tejido subyacente es resonante o mate.', 'Percussion was dull over the right lower lobe.', 'La percusión era mate sobre el lóbulo inferior derecho.', 'pulmonology', 'intermediate', ARRAY['exam','procedure'], FALSE),
  ('ca2c0000-0000-0000-0000-00000000000a', 'pleurisy', '/ˈplʊə.rɪ.si/', 'pleuresía', 'Inflammation of the pleura, causing sharp chest pain that worsens with breathing.', 'Inflamación de la pleura que causa dolor torácico agudo que empeora al respirar.', 'The pleurisy caused sharp pain on deep inspiration.', 'La pleuresía causaba dolor agudo con la inspiración profunda.', 'pulmonology', 'advanced', ARRAY['respiratory','diagnosis'], FALSE)
ON CONFLICT (id) DO NOTHING;

-- Link vocabulary to lessons -------------------------------------------------
INSERT INTO lesson_vocabulary (lesson_id, vocabulary_id, sort_order)
VALUES
  ('ca200001-0000-0000-0000-000000000001', 'ca2c0000-0000-0000-0000-000000000001', 0),
  ('ca200001-0000-0000-0000-000000000001', 'ca2c0000-0000-0000-0000-000000000002', 1),
  ('ca200001-0000-0000-0000-000000000001', 'ca2c0000-0000-0000-0000-000000000003', 2),
  ('ca200001-0000-0000-0000-000000000001', 'ca2c0000-0000-0000-0000-000000000004', 3),
  ('ca200001-0000-0000-0000-000000000001', 'ca2c0000-0000-0000-0000-000000000005', 4),
  ('ca200001-0000-0000-0000-000000000003', 'ca2c0000-0000-0000-0000-000000000006', 5),
  ('ca200001-0000-0000-0000-000000000003', 'ca2c0000-0000-0000-0000-000000000009', 6),
  ('ca200001-0000-0000-0000-000000000005', 'ca2c0000-0000-0000-0000-000000000007', 7),
  ('ca200001-0000-0000-0000-000000000005', 'ca2c0000-0000-0000-0000-000000000008', 8),
  ('ca200001-0000-0000-0000-000000000005', 'ca2c0000-0000-0000-0000-00000000000a', 9)
ON CONFLICT DO NOTHING;

-- ==== 03_pediatrics ====
-- ============================================================================
-- Clinical English by Specialty — Module 3: Pediatrics (The Pediatric Encounter)
-- module_id cb000003…cb · content UUIDs prefixed ca3… · is_published = FALSE
-- AI-drafted, pending physician validation.
-- ============================================================================

-- Lessons --------------------------------------------------------------------
INSERT INTO lessons (id, module_id, slug, title, description, lesson_type, difficulty, estimated_minutes, xp_reward, sort_order, is_published, intro_text, completion_text)
VALUES
  ('ca300001-0000-0000-0000-000000000001', 'cb000003-0000-0000-0000-0000000000cb', 'pediatric-vocabulary',
   'Pediatric Vocabulary & Age-Appropriate Language', 'Core terms for growth, development, and immunization, plus child-friendly phrasing.', 'standard', 'intermediate', 6, 50, 0, FALSE,
   'Learn the English terms caregivers and clinicians use in pediatrics.', 'You can now name key pediatric terms in English.'),
  ('ca300001-0000-0000-0000-000000000002', 'cb000003-0000-0000-0000-0000000000cb', 'pediatric-history',
   'Taking a Pediatric History from Caregivers', 'Ask caregivers focused questions about feeding, diapers, and exposures.', 'standard', 'intermediate', 7, 60, 1, FALSE,
   'Practice the questions of a focused pediatric history with caregivers.', 'You can now take a focused pediatric history in English.'),
  ('ca300001-0000-0000-0000-000000000003', 'cb000003-0000-0000-0000-0000000000cb', 'pediatric-exam',
   'The Pediatric Examination', 'Exam vocabulary and child-friendly instructions, said clearly.', 'pronunciation', 'intermediate', 6, 55, 2, FALSE,
   'Say pediatric exam terms clearly and give gentle instructions to children.', 'Your pediatric exam English is clearer and more confident.'),
  ('ca300001-0000-0000-0000-000000000004', 'cb000003-0000-0000-0000-0000000000cb', 'febrile-infant-case',
   'Clinical Case: The Febrile Infant', 'A 3-week-old with a fever — reason through it in English.', 'clinical_case', 'intermediate', 9, 75, 3, FALSE,
   'Work through a febrile young infant presentation in English.', 'You reasoned through a febrile infant evaluation in English.'),
  ('ca300001-0000-0000-0000-000000000005', 'cb000003-0000-0000-0000-0000000000cb', 'pediatrics-review',
   'Pediatrics Review', 'Consolidate the module.', 'test', 'intermediate', 6, 60, 4, FALSE,
   'Review the pediatrics module.', 'Pediatrics module complete.')
ON CONFLICT (id) DO NOTHING;

-- Lesson 1 exercises (pediatric vocabulary) ----------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca3e0101-0000-0000-0000-000000000001', 'ca300001-0000-0000-0000-000000000001', 'multiple_choice',
   'A mother says "my baby is due for her shots." Which clinical term documents this?', 'Immunizations',
   'Caregivers say "shots"; the chart term is "immunizations" (or "vaccinations").', 'Los cuidadores dicen "shots"; en la historia se escribe "immunizations" (vacunas).',
   'intermediate', 10, 0, '{}'::jsonb, FALSE),
  ('ca3e0101-0000-0000-0000-000000000002', 'ca300001-0000-0000-0000-000000000001', 'flashcard',
   'immunization', 'inmunización',
   'The process of making a person immune, usually through vaccination.', 'Proceso de hacer inmune a una persona, generalmente mediante vacunación.',
   'intermediate', 10, 1, '{"front":{"text":"immunization","subtext":"/ˌɪm.jə.nɪˈzeɪ.ʃən/"},"back":{"text":"inmunización","translation":"inmunización","example":"His immunizations are up to date.","explanation":"With caregivers you can also say \"shots\" or \"vaccines\"."}}'::jsonb, FALSE),
  ('ca3e0101-0000-0000-0000-000000000003', 'ca300001-0000-0000-0000-000000000001', 'fill_in_blank',
   'Complete: "Skills a child should reach by a certain age, like sitting or walking, are developmental ______."', 'milestones',
   'Developmental milestones are age-based markers of a child''s progress.', 'Los hitos del desarrollo son marcadores por edad del progreso del niño.',
   'intermediate', 10, 2, '{"acceptable_answers":["milestones","milestone"],"case_sensitive":false}'::jsonb, FALSE),
  ('ca3e0101-0000-0000-0000-000000000004', 'ca300001-0000-0000-0000-000000000001', 'matching',
   'Match each pediatric term with its meaning.', NULL,
   'Core pediatric vocabulary.', 'Vocabulario pediátrico básico.',
   'intermediate', 10, 3, '{"columns":2}'::jsonb, FALSE),
  ('ca3e0101-0000-0000-0000-000000000005', 'ca300001-0000-0000-0000-000000000001', 'translation',
   'Translate to English: "El niño tiene fiebre desde ayer."', 'The child has had a fever since yesterday.',
   'Use the present perfect ("has had") for a symptom that started in the past and continues.', 'Use el present perfect ("has had") para un síntoma que empezó antes y sigue.',
   'intermediate', 10, 4, '{"source_language":"es","target_language":"en","source_text":"El niño tiene fiebre desde ayer.","acceptable_translations":["The child has had a fever since yesterday.","The boy has had a fever since yesterday.","The kid has had a fever since yesterday."],"key_terms":["fever","since yesterday"]}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

-- matching options for ca3e0101-...004 (grouped by match_pair_id) -------------
INSERT INTO exercise_options (exercise_id, option_text, match_pair_id, sort_order)
VALUES
  ('ca3e0101-0000-0000-0000-000000000004', 'caregiver', 'p1', 0),
  ('ca3e0101-0000-0000-0000-000000000004', 'a parent or guardian who looks after the child', 'p1', 1),
  ('ca3e0101-0000-0000-0000-000000000004', 'rash', 'p2', 2),
  ('ca3e0101-0000-0000-0000-000000000004', 'an area of irritated or red skin', 'p2', 3),
  ('ca3e0101-0000-0000-0000-000000000004', 'wheezing', 'p3', 4),
  ('ca3e0101-0000-0000-0000-000000000004', 'a whistling sound when breathing out', 'p3', 5),
  ('ca3e0101-0000-0000-0000-000000000004', 'lethargy', 'p4', 6),
  ('ca3e0101-0000-0000-0000-000000000004', 'abnormal drowsiness or lack of energy', 'p4', 7)
ON CONFLICT DO NOTHING;

-- multiple-choice options for ca3e0101-...001 --------------------------------
INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca3e0101-0000-0000-0000-000000000001', 'Immunizations', TRUE, 0),
  ('ca3e0101-0000-0000-0000-000000000001', 'Medications', FALSE, 1),
  ('ca3e0101-0000-0000-0000-000000000001', 'Milestones', FALSE, 2),
  ('ca3e0101-0000-0000-0000-000000000001', 'Allergies', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Lesson 2 exercises (pediatric history from caregivers) ---------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca3e0201-0000-0000-0000-000000000001', 'ca300001-0000-0000-0000-000000000002', 'multiple_choice',
   'You want to gauge hydration in an infant. Which caregiver question is most useful?', 'How many wet diapers has your baby had today?',
   'Wet-diaper count is a simple, reliable proxy for hydration in infants.', 'El número de pañales mojados es un indicador simple y fiable de la hidratación del lactante.',
   'intermediate', 10, 0, '{}'::jsonb, FALSE),
  ('ca3e0201-0000-0000-0000-000000000002', 'ca300001-0000-0000-0000-000000000002', 'sentence_ordering',
   'Put the caregiver question in order.', 'Has your child been around anyone who is sick?',
   'Asking about sick contacts helps identify a source of infection.', 'Preguntar por contactos enfermos ayuda a identificar la fuente de la infección.',
   'intermediate', 10, 1, '{"words":["Has","your","child","been","around","anyone","who","is","sick"]}'::jsonb, FALSE),
  ('ca3e0201-0000-0000-0000-000000000003', 'ca300001-0000-0000-0000-000000000002', 'fill_in_blank',
   'Complete: "Are your child''s vaccinations up to ______?"', 'date',
   '"Up to date" means the immunizations follow the recommended schedule.', '"Up to date" significa que las vacunas siguen el calendario recomendado.',
   'intermediate', 10, 2, '{"acceptable_answers":["date"],"case_sensitive":false,"word_bank":["date","day","time","now"]}'::jsonb, FALSE),
  ('ca3e0201-0000-0000-0000-000000000004', 'ca300001-0000-0000-0000-000000000002', 'translation',
   'Translate to English: "¿Está comiendo bien y mojando pañales?"', 'Is she feeding well and making wet diapers?',
   '"Feeding" and "wet diapers" are the everyday terms caregivers understand.', '"Feeding" y "wet diapers" son los términos cotidianos que entienden los cuidadores.',
   'intermediate', 10, 3, '{"source_language":"es","target_language":"en","source_text":"¿Está comiendo bien y mojando pañales?","acceptable_translations":["Is she feeding well and making wet diapers?","Is she eating well and making wet diapers?","Is he feeding well and having wet diapers?"],"key_terms":["feeding","wet diapers"]}'::jsonb, FALSE),
  ('ca3e0201-0000-0000-0000-000000000005', 'ca300001-0000-0000-0000-000000000002', 'typing',
   'Type the clinical term: when a caregiver says "shots," the chart term is ______.', 'immunizations',
   'Chart it as "immunizations" (or "vaccinations"); say "shots" to caregivers.', 'Escríbalo como "immunizations" (vacunas); diga "shots" a los cuidadores.',
   'intermediate', 10, 4, '{"acceptable_answers":["immunizations","immunization","vaccinations","vaccination"],"case_sensitive":false}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca3e0201-0000-0000-0000-000000000001', 'How many wet diapers has your baby had today?', TRUE, 0),
  ('ca3e0201-0000-0000-0000-000000000001', 'Why did you not come in sooner?', FALSE, 1),
  ('ca3e0201-0000-0000-0000-000000000001', 'Do you think the baby is faking it?', FALSE, 2),
  ('ca3e0201-0000-0000-0000-000000000001', 'What color is your baby''s room?', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Lesson 3 exercises (pediatric exam — pronunciation) ------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca3e0301-0000-0000-0000-000000000001', 'ca300001-0000-0000-0000-000000000003', 'pronunciation',
   'Say the word: "fontanelle"', 'fontanelle',
   'The soft spot on a baby''s head where the skull bones have not yet fused.', 'La fontanela: el punto blando del cráneo del bebé donde los huesos aún no se han fusionado.',
   'intermediate', 10, 0, '{"word":"fontanelle","phonetic":"/ˌfɒn.təˈnɛl/","minimum_score":60,"syllables":["fon","ta","nelle"]}'::jsonb, FALSE),
  ('ca3e0301-0000-0000-0000-000000000002', 'ca300001-0000-0000-0000-000000000003', 'pronunciation',
   'Say the word: "otoscope"', 'otoscope',
   'The instrument used to look inside the ear canal and at the eardrum.', 'El otoscopio: instrumento para mirar el conducto auditivo y el tímpano.',
   'intermediate', 10, 1, '{"word":"otoscope","phonetic":"/ˈoʊ.tə.skoʊp/","minimum_score":60,"common_mistakes":[{"mistake":"oh-TOS-cope with the stress on the second syllable","correction":"stress the first syllable: OH-tuh-scope"}]}'::jsonb, FALSE),
  ('ca3e0301-0000-0000-0000-000000000003', 'ca300001-0000-0000-0000-000000000003', 'multiple_choice',
   'Which instruction helps a young child cooperate with an ear exam?', 'I am going to look in your ears with my special flashlight, okay?',
   'Framing the otoscope as a "special flashlight" is friendly and non-threatening.', 'Llamar al otoscopio "linterna especial" es amistoso y poco amenazante.',
   'intermediate', 10, 2, '{}'::jsonb, FALSE),
  ('ca3e0301-0000-0000-0000-000000000004', 'ca300001-0000-0000-0000-000000000003', 'fill_in_blank',
   'Complete: "The soft spot on a baby''s head is called the ______."', 'fontanelle',
   'A sunken fontanelle can indicate dehydration; a bulging one, raised pressure.', 'Una fontanela hundida puede indicar deshidratación; una abombada, presión elevada.',
   'intermediate', 10, 3, '{"acceptable_answers":["fontanelle","fontanel","soft spot"],"case_sensitive":false}'::jsonb, FALSE),
  ('ca3e0301-0000-0000-0000-000000000005', 'ca300001-0000-0000-0000-000000000003', 'translation',
   'Translate to English (exam instruction to a child): "Abre grande la boca, por favor."', 'Open wide, please.',
   '"Open wide" is the natural, child-friendly phrasing for examining the mouth.', '"Open wide" es la frase natural y amigable para examinar la boca.',
   'intermediate', 10, 4, '{"source_language":"es","target_language":"en","source_text":"Abre grande la boca, por favor.","acceptable_translations":["Open wide, please.","Open your mouth wide, please.","Can you open wide for me?"]}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca3e0301-0000-0000-0000-000000000003', 'I am going to look in your ears with my special flashlight, okay?', TRUE, 0),
  ('ca3e0301-0000-0000-0000-000000000003', 'Hold still or this will hurt.', FALSE, 1),
  ('ca3e0301-0000-0000-0000-000000000003', 'Stop crying and sit up straight.', FALSE, 2),
  ('ca3e0301-0000-0000-0000-000000000003', 'This is an otoscope for tympanic membrane visualization.', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Lesson 4 exercises (clinical case: the febrile infant) ---------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca3e0401-0000-0000-0000-000000000001', 'ca300001-0000-0000-0000-000000000004', 'multiple_choice',
   'A 3-week-old presents with a rectal temperature of 38.5°C (101.3°F) and no obvious source. What is the appropriate management?', 'Perform a full sepsis evaluation and admit for empiric antibiotics.',
   'A febrile neonate (0–28 days) needs a full sepsis work-up (blood, urine, CSF), admission, and empiric antibiotics.', 'Un neonato febril (0–28 días) requiere estudio completo de sepsis (sangre, orina, LCR), ingreso y antibióticos empíricos.',
   'intermediate', 12, 0, '{}'::jsonb, FALSE),
  ('ca3e0401-0000-0000-0000-000000000002', 'ca300001-0000-0000-0000-000000000004', 'fill_in_blank',
   'Complete: "A rectal temperature of 38.0°C (100.4°F) or higher in an infant is defined as a ______."', 'fever',
   '38.0°C (100.4°F) rectal is the standard threshold that defines fever in an infant.', '38.0°C (100.4°F) rectal es el umbral estándar que define fiebre en el lactante.',
   'intermediate', 12, 1, '{"acceptable_answers":["fever"],"case_sensitive":false}'::jsonb, FALSE),
  ('ca3e0401-0000-0000-0000-000000000003', 'ca300001-0000-0000-0000-000000000004', 'translation',
   'Translate for the caregiver: "Necesitamos hacerle unos análisis de sangre y orina a su bebé."', 'We need to run some blood and urine tests on your baby.',
   'Explain the plan simply; "run some tests" is clearer than clinical jargon.', 'Explique el plan con sencillez; "run some tests" es más claro que la jerga clínica.',
   'intermediate', 12, 2, '{"source_language":"es","target_language":"en","source_text":"Necesitamos hacerle unos análisis de sangre y orina a su bebé.","acceptable_translations":["We need to run some blood and urine tests on your baby.","We need to do some blood and urine tests on your baby.","We need to run blood and urine tests on your baby."],"key_terms":["blood tests","urine tests"]}'::jsonb, FALSE),
  ('ca3e0401-0000-0000-0000-000000000004', 'ca300001-0000-0000-0000-000000000004', 'sentence_ordering',
   'Order the reassuring statement to the caregiver.', 'We are going to take good care of your baby.',
   'A calm, warm reassurance helps anxious caregivers during a work-up.', 'Una reassurance calmada y cálida ayuda a los cuidadores ansiosos durante el estudio.',
   'intermediate', 12, 3, '{"words":["We","are","going","to","take","good","care","of","your","baby"]}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca3e0401-0000-0000-0000-000000000001', 'Perform a full sepsis evaluation and admit for empiric antibiotics.', TRUE, 0),
  ('ca3e0401-0000-0000-0000-000000000001', 'Reassure the parents and send the baby home.', FALSE, 1),
  ('ca3e0401-0000-0000-0000-000000000001', 'Advise oral fluids and follow up in one week.', FALSE, 2),
  ('ca3e0401-0000-0000-0000-000000000001', 'Give an over-the-counter antipyretic only.', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Lesson 5 exercises (review/test) -------------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca3e0501-0000-0000-0000-000000000001', 'ca300001-0000-0000-0000-000000000005', 'multiple_choice',
   'Which finding is the most concerning red flag in a febrile infant?', 'Lethargy and poor feeding',
   'Lethargy and poor feeding suggest a seriously ill infant and warrant urgent evaluation.', 'El letargo y la mala alimentación sugieren un lactante gravemente enfermo y exigen evaluación urgente.',
   'intermediate', 12, 0, '{}'::jsonb, FALSE),
  ('ca3e0501-0000-0000-0000-000000000002', 'ca300001-0000-0000-0000-000000000005', 'flashcard',
   'dehydration', 'deshidratación',
   'A harmful loss of body water, shown by dry mouth, few wet diapers, or a sunken fontanelle.', 'Pérdida dañina de agua corporal, con boca seca, pocos pañales mojados o fontanela hundida.',
   'intermediate', 10, 1, '{"front":{"text":"dehydration","subtext":"/ˌdiː.haɪˈdreɪ.ʃən/"},"back":{"text":"deshidratación","translation":"deshidratación","example":"The infant showed signs of dehydration."}}'::jsonb, FALSE),
  ('ca3e0501-0000-0000-0000-000000000003', 'ca300001-0000-0000-0000-000000000005', 'typing',
   'Type the term: the whistling sound heard when a child breathes out with narrowed airways is called ______.', 'wheezing',
   'Wheezing is a high-pitched whistling sound, usually on expiration.', 'Las sibilancias son un sonido silbante agudo, generalmente en la espiración.',
   'intermediate', 10, 2, '{"acceptable_answers":["wheezing","wheeze","wheezes"],"case_sensitive":false}'::jsonb, FALSE),
  ('ca3e0501-0000-0000-0000-000000000004', 'ca300001-0000-0000-0000-000000000005', 'translation',
   'Translate to English: "¿Ha recibido todas sus vacunas?"', 'Has he had all of his vaccinations?',
   '"Vaccinations" (or "shots") — confirming immunization status is routine in pediatrics.', '"Vaccinations" (o "shots") — confirmar el estado de vacunación es rutinario en pediatría.',
   'intermediate', 10, 3, '{"source_language":"es","target_language":"en","source_text":"¿Ha recibido todas sus vacunas?","acceptable_translations":["Has he had all of his vaccinations?","Has she had all of her vaccinations?","Has your child had all of their shots?"],"key_terms":["vaccinations","shots"]}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca3e0501-0000-0000-0000-000000000001', 'Lethargy and poor feeding', TRUE, 0),
  ('ca3e0501-0000-0000-0000-000000000001', 'A single sneeze', FALSE, 1),
  ('ca3e0501-0000-0000-0000-000000000001', 'Playing and smiling normally', FALSE, 2),
  ('ca3e0501-0000-0000-0000-000000000001', 'A good appetite', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Vocabulary (module 3) ------------------------------------------------------
INSERT INTO vocabulary (id, word, phonetic, translation_es, definition_en, definition_es, example_en, example_es, category, difficulty, tags, is_published)
VALUES
  ('ca3c0000-0000-0000-0000-000000000001', 'immunization', '/ˌɪm.jə.nɪˈzeɪ.ʃən/', 'inmunización', 'The process of making a person immune, usually through vaccination.', 'Proceso de hacer inmune a una persona, generalmente mediante vacunación.', 'His immunizations are up to date.', 'Sus vacunas están al día.', 'pediatrics', 'intermediate', ARRAY['pediatric','prevention'], FALSE),
  ('ca3c0000-0000-0000-0000-000000000002', 'fever', '/ˈfiː.vər/', 'fiebre', 'A body temperature above the normal range, often a sign of infection.', 'Temperatura corporal por encima de lo normal, a menudo signo de infección.', 'The baby has had a fever since last night.', 'El bebé tiene fiebre desde anoche.', 'pediatrics', 'intermediate', ARRAY['pediatric','symptom'], FALSE),
  ('ca3c0000-0000-0000-0000-000000000003', 'milestone', '/ˈmaɪl.stoʊn/', 'hito del desarrollo', 'An age-based marker of a child''s developmental progress, like walking or talking.', 'Marcador por edad del progreso del desarrollo del niño, como caminar o hablar.', 'She is meeting all her developmental milestones.', 'Ella alcanza todos sus hitos del desarrollo.', 'pediatrics', 'intermediate', ARRAY['pediatric','development'], FALSE),
  ('ca3c0000-0000-0000-0000-000000000004', 'caregiver', '/ˈkɛr.ɡɪv.ər/', 'cuidador', 'A parent or guardian who looks after a child.', 'Padre, madre o tutor que cuida a un niño.', 'Please ask the caregiver about the feeding history.', 'Pregunte al cuidador sobre la historia alimentaria.', 'pediatrics', 'intermediate', ARRAY['pediatric','communication'], FALSE),
  ('ca3c0000-0000-0000-0000-000000000005', 'rash', '/ræʃ/', 'erupción cutánea', 'An area of irritated, red, or bumpy skin.', 'Zona de piel irritada, enrojecida o con protuberancias.', 'A pink rash appeared on the child''s trunk.', 'Apareció una erupción rosada en el tronco del niño.', 'pediatrics', 'intermediate', ARRAY['pediatric','sign','skin'], FALSE),
  ('ca3c0000-0000-0000-0000-000000000006', 'wheezing', '/ˈwiː.zɪŋ/', 'sibilancias', 'A high-pitched whistling sound when breathing out through narrowed airways.', 'Sonido silbante agudo al espirar por vías respiratorias estrechadas.', 'On exam there was wheezing in both lungs.', 'En la exploración había sibilancias en ambos pulmones.', 'pediatrics', 'intermediate', ARRAY['pediatric','respiratory','sign'], FALSE),
  ('ca3c0000-0000-0000-0000-000000000007', 'lethargy', '/ˈlɛθ.ər.dʒi/', 'letargo', 'Abnormal drowsiness, reduced alertness, or lack of energy.', 'Somnolencia anormal, menor alerta o falta de energía.', 'The infant''s lethargy was a worrying sign.', 'El letargo del lactante era un signo preocupante.', 'pediatrics', 'advanced', ARRAY['pediatric','symptom','red-flag'], FALSE),
  ('ca3c0000-0000-0000-0000-000000000008', 'dehydration', '/ˌdiː.haɪˈdreɪ.ʃən/', 'deshidratación', 'A harmful loss of body water and salts.', 'Pérdida dañina de agua y sales del cuerpo.', 'Few wet diapers can indicate dehydration.', 'Pocos pañales mojados pueden indicar deshidratación.', 'pediatrics', 'intermediate', ARRAY['pediatric','sign'], FALSE),
  ('ca3c0000-0000-0000-0000-000000000009', 'teething', '/ˈtiː.ðɪŋ/', 'dentición', 'The process of a baby''s first teeth breaking through the gums.', 'Proceso de salida de los primeros dientes del bebé a través de las encías.', 'Teething can cause drooling and irritability.', 'La dentición puede causar babeo e irritabilidad.', 'pediatrics', 'intermediate', ARRAY['pediatric','development'], FALSE),
  ('ca3c0000-0000-0000-0000-00000000000a', 'growth chart', '/ɡroʊθ tʃɑːrt/', 'curva de crecimiento', 'A graph used to track a child''s height, weight, and head circumference over time.', 'Gráfica para seguir la talla, el peso y el perímetro cefálico del niño a lo largo del tiempo.', 'Her weight is on the growth chart at the 50th percentile.', 'Su peso está en el percentil 50 de la curva de crecimiento.', 'pediatrics', 'intermediate', ARRAY['pediatric','development','exam'], FALSE)
ON CONFLICT (id) DO NOTHING;

-- Link vocabulary to lessons -------------------------------------------------
INSERT INTO lesson_vocabulary (lesson_id, vocabulary_id, sort_order)
VALUES
  ('ca300001-0000-0000-0000-000000000001', 'ca3c0000-0000-0000-0000-000000000001', 0),
  ('ca300001-0000-0000-0000-000000000001', 'ca3c0000-0000-0000-0000-000000000002', 1),
  ('ca300001-0000-0000-0000-000000000001', 'ca3c0000-0000-0000-0000-000000000003', 2),
  ('ca300001-0000-0000-0000-000000000001', 'ca3c0000-0000-0000-0000-000000000004', 3),
  ('ca300001-0000-0000-0000-000000000001', 'ca3c0000-0000-0000-0000-000000000005', 4),
  ('ca300001-0000-0000-0000-000000000001', 'ca3c0000-0000-0000-0000-000000000009', 5),
  ('ca300001-0000-0000-0000-000000000001', 'ca3c0000-0000-0000-0000-00000000000a', 6),
  ('ca300001-0000-0000-0000-000000000004', 'ca3c0000-0000-0000-0000-000000000002', 7),
  ('ca300001-0000-0000-0000-000000000004', 'ca3c0000-0000-0000-0000-000000000006', 8),
  ('ca300001-0000-0000-0000-000000000004', 'ca3c0000-0000-0000-0000-000000000007', 9),
  ('ca300001-0000-0000-0000-000000000004', 'ca3c0000-0000-0000-0000-000000000008', 10)
ON CONFLICT DO NOTHING;

-- ==== 04_emergency ====
-- ============================================================================
-- Clinical English by Specialty — Module 4: Emergency (Acute & Trauma Care)
-- module_id cb000004…cb · content UUIDs prefixed ca4… · is_published = FALSE
-- AI-drafted, pending physician validation. ATLS/ACLS-consistent language.
-- ============================================================================

-- Lessons --------------------------------------------------------------------
INSERT INTO lessons (id, module_id, slug, title, description, lesson_type, difficulty, estimated_minutes, xp_reward, sort_order, is_published, intro_text, completion_text)
VALUES
  ('ca400001-0000-0000-0000-000000000001', 'cb000004-0000-0000-0000-0000000000cb', 'emergency-triage-vocabulary',
   'Triage & Severity Vocabulary', 'Core terms for triage, acuity, and severity in the ED.', 'standard', 'intermediate', 6, 50, 0, FALSE,
   'Learn the English terms used to triage patients and describe severity.', 'You can now triage and describe severity in English.'),
  ('ca400001-0000-0000-0000-000000000002', 'cb000004-0000-0000-0000-0000000000cb', 'emergency-rapid-history',
   'Rapid Focused History (AMPLE / SAMPLE)', 'Take a fast, structured emergency history.', 'standard', 'intermediate', 7, 60, 1, FALSE,
   'Practice the AMPLE and SAMPLE questions of a rapid emergency history.', 'You can now take a rapid AMPLE history in English.'),
  ('ca400001-0000-0000-0000-000000000003', 'cb000004-0000-0000-0000-0000000000cb', 'emergency-exam',
   'The Emergency Examination', 'Trauma and resuscitation exam language, said clearly.', 'pronunciation', 'intermediate', 6, 55, 2, FALSE,
   'Say emergency exam terms clearly and give commands under pressure.', 'Your emergency exam English is clearer and more confident.'),
  ('ca400001-0000-0000-0000-000000000004', 'cb000004-0000-0000-0000-0000000000cb', 'trauma-primary-survey-case',
   'Clinical Case: Trauma Primary Survey', 'A trauma arrival — run the ABCDE survey in English.', 'clinical_case', 'intermediate', 9, 75, 3, FALSE,
   'Work through a trauma primary survey (ABCDE) in English.', 'You ran a trauma primary survey in English.'),
  ('ca400001-0000-0000-0000-000000000005', 'cb000004-0000-0000-0000-0000000000cb', 'emergency-review',
   'Emergency Review', 'Consolidate the module.', 'test', 'intermediate', 6, 60, 4, FALSE,
   'Review the emergency module.', 'Emergency module complete.')
ON CONFLICT (id) DO NOTHING;

-- Lesson 1 exercises (triage & severity) -------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca4e0101-0000-0000-0000-000000000001', 'ca400001-0000-0000-0000-000000000001', 'multiple_choice',
   'A patient arrives with airway obstruction and severe respiratory distress. How is this patient triaged?', 'Immediate — the highest priority (red).',
   'Life-threatening airway or breathing problems are triaged as immediate (red), seen first.', 'Los problemas de vía aérea o respiración que amenazan la vida se clasifican como inmediatos (rojo), atendidos primero.',
   'intermediate', 10, 0, '{}'::jsonb, FALSE),
  ('ca4e0101-0000-0000-0000-000000000002', 'ca400001-0000-0000-0000-000000000001', 'flashcard',
   'triage', 'triaje',
   'Sorting patients by the urgency of their condition to prioritize care.', 'Clasificar a los pacientes según la urgencia de su estado para priorizar la atención.',
   'intermediate', 10, 1, '{"front":{"text":"triage","subtext":"/ˈtriː.ɑːʒ/"},"back":{"text":"triaje","translation":"triaje","example":"The nurse will triage every patient on arrival.","explanation":"Triage sorts patients by severity so the sickest are seen first."}}'::jsonb, FALSE),
  ('ca4e0101-0000-0000-0000-000000000003', 'ca400001-0000-0000-0000-000000000001', 'fill_in_blank',
   'Complete: "The patient is getting worse quickly; his condition is ______."', 'deteriorating',
   'A patient who is getting worse is described as deteriorating; the opposite is stable.', 'Un paciente que empeora se describe como deteriorating (en deterioro); lo contrario es stable.',
   'intermediate', 10, 2, '{"acceptable_answers":["deteriorating","unstable","worsening"],"case_sensitive":false,"word_bank":["deteriorating","stable","improving","discharged"]}'::jsonb, FALSE),
  ('ca4e0101-0000-0000-0000-000000000004', 'ca400001-0000-0000-0000-000000000001', 'matching',
   'Match each emergency term with its meaning.', NULL,
   'Core emergency vocabulary.', 'Vocabulario básico de urgencias.',
   'intermediate', 10, 3, '{"columns":2}'::jsonb, FALSE),
  ('ca4e0101-0000-0000-0000-000000000005', 'ca400001-0000-0000-0000-000000000001', 'translation',
   'Translate to English: "El paciente está inconsciente y no responde."', 'The patient is unconscious and unresponsive.',
   '"Unresponsive" means the patient does not respond to voice or touch.', '"Unresponsive" significa que el paciente no responde a la voz ni al tacto.',
   'intermediate', 10, 4, '{"source_language":"es","target_language":"en","source_text":"El paciente está inconsciente y no responde.","acceptable_translations":["The patient is unconscious and unresponsive.","The patient is unconscious and does not respond.","The patient is unconscious and not responding."],"key_terms":["unconscious","unresponsive"]}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

-- matching options for ca4e0101-...004 (grouped by match_pair_id) ------------
INSERT INTO exercise_options (exercise_id, option_text, match_pair_id, sort_order)
VALUES
  ('ca4e0101-0000-0000-0000-000000000004', 'triage', 'p1', 0),
  ('ca4e0101-0000-0000-0000-000000000004', 'sorting patients by the urgency of their condition', 'p1', 1),
  ('ca4e0101-0000-0000-0000-000000000004', 'hemorrhage', 'p2', 2),
  ('ca4e0101-0000-0000-0000-000000000004', 'heavy or uncontrolled bleeding', 'p2', 3),
  ('ca4e0101-0000-0000-0000-000000000004', 'tachycardia', 'p3', 4),
  ('ca4e0101-0000-0000-0000-000000000004', 'an abnormally fast heart rate', 'p3', 5),
  ('ca4e0101-0000-0000-0000-000000000004', 'hypotension', 'p4', 6),
  ('ca4e0101-0000-0000-0000-000000000004', 'abnormally low blood pressure', 'p4', 7)
ON CONFLICT DO NOTHING;

-- multiple-choice options for ca4e0101-...001 --------------------------------
INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca4e0101-0000-0000-0000-000000000001', 'Immediate — the highest priority (red).', TRUE, 0),
  ('ca4e0101-0000-0000-0000-000000000001', 'Non-urgent — can wait several hours (green).', FALSE, 1),
  ('ca4e0101-0000-0000-0000-000000000001', 'Discharge home without assessment.', FALSE, 2),
  ('ca4e0101-0000-0000-0000-000000000001', 'Routine outpatient referral.', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Lesson 2 exercises (rapid focused history — AMPLE / SAMPLE) ----------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca4e0201-0000-0000-0000-000000000001', 'ca400001-0000-0000-0000-000000000002', 'multiple_choice',
   'In the AMPLE history, what does the letter "A" stand for?', 'Allergies',
   'AMPLE = Allergies, Medications, Past history, Last meal, Events. "A" is Allergies.', 'AMPLE = Allergies (alergias), Medications, Past history, Last meal, Events. La "A" es alergias.',
   'intermediate', 10, 0, '{}'::jsonb, FALSE),
  ('ca4e0201-0000-0000-0000-000000000002', 'ca400001-0000-0000-0000-000000000002', 'sentence_ordering',
   'Put the emergency history question in order.', 'When did you last eat or drink anything?',
   'The "L" in AMPLE asks about the last meal — key before urgent surgery or sedation.', 'La "L" de AMPLE pregunta por la última comida — clave antes de cirugía urgente o sedación.',
   'intermediate', 10, 1, '{"words":["When","did","you","last","eat","or","drink","anything"]}'::jsonb, FALSE),
  ('ca4e0201-0000-0000-0000-000000000003', 'ca400001-0000-0000-0000-000000000002', 'fill_in_blank',
   'Complete the SAMPLE prompt: "Can you tell me what ______ led up to this happening?"', 'events',
   'The "E" in SAMPLE asks about the events leading up to the injury or illness.', 'La "E" de SAMPLE pregunta por los eventos que precedieron a la lesión o enfermedad.',
   'intermediate', 10, 2, '{"acceptable_answers":["events","event"],"case_sensitive":false,"word_bank":["events","allergies","medications","symptoms"]}'::jsonb, FALSE),
  ('ca4e0201-0000-0000-0000-000000000004', 'ca400001-0000-0000-0000-000000000002', 'translation',
   'Translate to English: "¿Toma algún medicamento actualmente?"', 'Are you taking any medications right now?',
   'The "M" in AMPLE covers current medications — ask this early.', 'La "M" de AMPLE cubre los medicamentos actuales — pregúntelo temprano.',
   'intermediate', 10, 3, '{"source_language":"es","target_language":"en","source_text":"¿Toma algún medicamento actualmente?","acceptable_translations":["Are you taking any medications right now?","Are you currently taking any medications?","Do you take any medications right now?"],"key_terms":["medications","taking"]}'::jsonb, FALSE),
  ('ca4e0201-0000-0000-0000-000000000005', 'ca400001-0000-0000-0000-000000000002', 'typing',
   'Type the clinical term: the "P" in AMPLE asks about the patient''s ______ medical history.', 'past',
   'AMPLE: Allergies, Medications, Past medical history, Last meal, Events.', 'AMPLE: alergias, medicamentos, antecedentes (past medical history), última comida, eventos.',
   'intermediate', 10, 4, '{"acceptable_answers":["past","past medical","prior"],"case_sensitive":false}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca4e0201-0000-0000-0000-000000000001', 'Allergies', TRUE, 0),
  ('ca4e0201-0000-0000-0000-000000000001', 'Age', FALSE, 1),
  ('ca4e0201-0000-0000-0000-000000000001', 'Airway', FALSE, 2),
  ('ca4e0201-0000-0000-0000-000000000001', 'Address', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Lesson 3 exercises (emergency exam — pronunciation) ------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca4e0301-0000-0000-0000-000000000001', 'ca400001-0000-0000-0000-000000000003', 'pronunciation',
   'Say the word: "hemorrhage"', 'hemorrhage',
   'Heavy or uncontrolled bleeding. Note the silent, tricky spelling.', 'Hemorragia: sangrado abundante o incontrolado. Ojo con la ortografía.',
   'intermediate', 10, 0, '{"word":"hemorrhage","phonetic":"/ˈhem.ər.ɪdʒ/","minimum_score":60,"syllables":["hem","or","rhage"],"common_mistakes":[{"mistake":"hemo-RAGE with a hard g","correction":"stress the first syllable: HEM-or-ij, ending in a soft j sound"}]}'::jsonb, FALSE),
  ('ca4e0301-0000-0000-0000-000000000002', 'ca400001-0000-0000-0000-000000000003', 'pronunciation',
   'Say the word: "resuscitation"', 'resuscitation',
   'The act of reviving someone from unconsciousness or apparent death.', 'Reanimación: acto de revivir a alguien inconsciente o en paro.',
   'intermediate', 10, 1, '{"word":"resuscitation","phonetic":"/rɪˌsʌs.ɪˈteɪ.ʃən/","minimum_score":60,"syllables":["re","sus","ci","ta","tion"]}'::jsonb, FALSE),
  ('ca4e0301-0000-0000-0000-000000000003', 'ca400001-0000-0000-0000-000000000003', 'multiple_choice',
   'Which command asks the patient to show you they can protect their own airway?', 'Can you say your name and squeeze my hand?',
   'A patient who talks clearly and follows commands is protecting their airway.', 'Un paciente que habla con claridad y obedece órdenes está protegiendo su vía aérea.',
   'intermediate', 10, 2, '{}'::jsonb, FALSE),
  ('ca4e0301-0000-0000-0000-000000000004', 'ca400001-0000-0000-0000-000000000003', 'fill_in_blank',
   'Complete: "I am going to check your breathing. Please take a slow, deep ______."', 'breath',
   'Clear, simple exam commands help a distressed patient cooperate.', 'Órdenes de examen claras y simples ayudan a cooperar a un paciente angustiado.',
   'intermediate', 10, 3, '{"acceptable_answers":["breath","breath in"],"case_sensitive":false}'::jsonb, FALSE),
  ('ca4e0301-0000-0000-0000-000000000005', 'ca400001-0000-0000-0000-000000000003', 'translation',
   'Translate to English (exam command): "No se mueva, vamos a estabilizarle el cuello."', 'Do not move; we are going to stabilize your neck.',
   'In trauma, protect the cervical spine and tell the patient to stay still.', 'En trauma, proteja la columna cervical y pida al paciente que no se mueva.',
   'intermediate', 10, 4, '{"source_language":"es","target_language":"en","source_text":"No se mueva, vamos a estabilizarle el cuello.","acceptable_translations":["Do not move; we are going to stabilize your neck.","Do not move, we are going to stabilize your neck.","Please stay still; we are going to stabilize your neck."],"key_terms":["do not move","stabilize","neck"]}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca4e0301-0000-0000-0000-000000000003', 'Can you say your name and squeeze my hand?', TRUE, 0),
  ('ca4e0301-0000-0000-0000-000000000003', 'Hold your breath for two minutes.', FALSE, 1),
  ('ca4e0301-0000-0000-0000-000000000003', 'Run in place for me, please.', FALSE, 2),
  ('ca4e0301-0000-0000-0000-000000000003', 'Read this small print across the room.', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Lesson 4 exercises (clinical case: trauma primary survey ABCDE) ------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca4e0401-0000-0000-0000-000000000001', 'ca400001-0000-0000-0000-000000000004', 'multiple_choice',
   'A trauma patient arrives after a motor vehicle collision. Following the primary survey, what do you assess first?', 'Airway, with cervical spine protection.',
   'ATLS primary survey is ABCDE: Airway first, protecting the cervical spine.', 'La evaluación primaria del ATLS es ABCDE: la vía aérea primero, protegiendo la columna cervical.',
   'intermediate', 12, 0, '{}'::jsonb, FALSE),
  ('ca4e0401-0000-0000-0000-000000000002', 'ca400001-0000-0000-0000-000000000004', 'fill_in_blank',
   'Complete the ABCDE sequence: "A is Airway, B is Breathing, C is ______, D is Disability, E is Exposure."', 'Circulation',
   'ABCDE: Airway, Breathing, Circulation, Disability, Exposure. "C" is Circulation.', 'ABCDE: vía aérea, respiración, circulación, discapacidad neurológica, exposición. La "C" es circulación.',
   'intermediate', 12, 1, '{"acceptable_answers":["Circulation","circulation"],"case_sensitive":false}'::jsonb, FALSE),
  ('ca4e0401-0000-0000-0000-000000000003', 'ca400001-0000-0000-0000-000000000004', 'translation',
   'Translate for the trauma team: "Tiene una hemorragia importante en la pierna; apliquen presión."', 'He has major bleeding in the leg; apply pressure.',
   'Control external hemorrhage with direct pressure during the C of ABCDE.', 'Controle la hemorragia externa con presión directa durante la C de ABCDE.',
   'intermediate', 12, 2, '{"source_language":"es","target_language":"en","source_text":"Tiene una hemorragia importante en la pierna; apliquen presión.","acceptable_translations":["He has major bleeding in the leg; apply pressure.","He has significant bleeding in the leg, apply pressure.","There is major bleeding in the leg; apply pressure."],"key_terms":["bleeding","hemorrhage","apply pressure"]}'::jsonb, FALSE),
  ('ca4e0401-0000-0000-0000-000000000004', 'ca400001-0000-0000-0000-000000000004', 'sentence_ordering',
   'Order the reassuring instruction to the trauma patient.', 'Stay still and tell me where it hurts.',
   'Keep the patient still to protect the spine while you localize injuries.', 'Mantenga quieto al paciente para proteger la columna mientras localiza las lesiones.',
   'intermediate', 12, 3, '{"words":["Stay","still","and","tell","me","where","it","hurts"]}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca4e0401-0000-0000-0000-000000000001', 'Airway, with cervical spine protection.', TRUE, 0),
  ('ca4e0401-0000-0000-0000-000000000001', 'A detailed past surgical history.', FALSE, 1),
  ('ca4e0401-0000-0000-0000-000000000001', 'A full skin and cosmetic assessment.', FALSE, 2),
  ('ca4e0401-0000-0000-0000-000000000001', 'Discharge paperwork.', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Lesson 5 exercises (review/test) -------------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca4e0501-0000-0000-0000-000000000001', 'ca400001-0000-0000-0000-000000000005', 'multiple_choice',
   'Which set of vital signs most suggests hypovolemic shock from blood loss?', 'Tachycardia, hypotension, and cool, clammy skin',
   'Fast heart rate, low blood pressure, and cool clammy skin point to hypovolemic shock.', 'Frecuencia cardíaca alta, presión baja y piel fría y sudorosa apuntan a shock hipovolémico.',
   'intermediate', 12, 0, '{}'::jsonb, FALSE),
  ('ca4e0501-0000-0000-0000-000000000002', 'ca400001-0000-0000-0000-000000000005', 'flashcard',
   'tourniquet', 'torniquete',
   'A tight band applied around a limb to stop severe arterial bleeding.', 'Banda apretada aplicada alrededor de una extremidad para detener un sangrado arterial grave.',
   'intermediate', 10, 1, '{"front":{"text":"tourniquet","subtext":"/ˈtɜːr.nɪ.kət/"},"back":{"text":"torniquete","translation":"torniquete","example":"Apply a tourniquet above the wound to stop the bleeding."}}'::jsonb, FALSE),
  ('ca4e0501-0000-0000-0000-000000000003', 'ca400001-0000-0000-0000-000000000005', 'typing',
   'Type the term: the structured primary survey used in trauma is remembered by the letters ______.', 'ABCDE',
   'ABCDE = Airway, Breathing, Circulation, Disability, Exposure.', 'ABCDE = vía aérea, respiración, circulación, discapacidad, exposición.',
   'intermediate', 10, 2, '{"acceptable_answers":["ABCDE","abcde","A B C D E"],"case_sensitive":false}'::jsonb, FALSE),
  ('ca4e0501-0000-0000-0000-000000000004', 'ca400001-0000-0000-0000-000000000005', 'translation',
   'Translate to English: "¿Es alérgico a algún medicamento?"', 'Are you allergic to any medications?',
   'Allergies is the "A" of AMPLE — a fast, essential emergency question.', 'Las alergias son la "A" de AMPLE — una pregunta rápida y esencial en urgencias.',
   'intermediate', 10, 3, '{"source_language":"es","target_language":"en","source_text":"¿Es alérgico a algún medicamento?","acceptable_translations":["Are you allergic to any medications?","Do you have any drug allergies?","Are you allergic to any medicines?"],"key_terms":["allergic","medications"]}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca4e0501-0000-0000-0000-000000000001', 'Tachycardia, hypotension, and cool, clammy skin', TRUE, 0),
  ('ca4e0501-0000-0000-0000-000000000001', 'Bradycardia, hypertension, and warm, dry skin', FALSE, 1),
  ('ca4e0501-0000-0000-0000-000000000001', 'Sneezing, itchy eyes, and a rash', FALSE, 2),
  ('ca4e0501-0000-0000-0000-000000000001', 'Normal vitals and no complaints', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Vocabulary (module 4) ------------------------------------------------------
INSERT INTO vocabulary (id, word, phonetic, translation_es, definition_en, definition_es, example_en, example_es, category, difficulty, tags, is_published)
VALUES
  ('ca4c0000-0000-0000-0000-000000000001', 'triage', '/ˈtriː.ɑːʒ/', 'triaje', 'Sorting patients by the urgency of their condition to prioritize care.', 'Clasificar a los pacientes según la urgencia de su estado para priorizar la atención.', 'The nurse will triage every patient on arrival.', 'La enfermera hará el triaje de cada paciente a su llegada.', 'emergency', 'intermediate', ARRAY['emergency','process'], FALSE),
  ('ca4c0000-0000-0000-0000-000000000002', 'hemorrhage', '/ˈhem.ər.ɪdʒ/', 'hemorragia', 'Heavy or uncontrolled bleeding from a damaged blood vessel.', 'Sangrado abundante o incontrolado de un vaso sanguíneo dañado.', 'They controlled the hemorrhage with direct pressure.', 'Controlaron la hemorragia con presión directa.', 'emergency', 'intermediate', ARRAY['emergency','trauma','sign'], FALSE),
  ('ca4c0000-0000-0000-0000-000000000003', 'resuscitation', '/rɪˌsʌs.ɪˈteɪ.ʃən/', 'reanimación', 'The act of reviving a person from unconsciousness or apparent death.', 'Acto de revivir a una persona inconsciente o en paro aparente.', 'The team began resuscitation immediately.', 'El equipo inició la reanimación de inmediato.', 'emergency', 'advanced', ARRAY['emergency','procedure'], FALSE),
  ('ca4c0000-0000-0000-0000-000000000004', 'laceration', '/ˌlæs.əˈreɪ.ʃən/', 'laceración', 'A deep cut or tear in the skin or flesh.', 'Corte o desgarro profundo en la piel o los tejidos.', 'The laceration on his forearm needed sutures.', 'La laceración en su antebrazo necesitó puntos.', 'emergency', 'intermediate', ARRAY['emergency','trauma','injury'], FALSE),
  ('ca4c0000-0000-0000-0000-000000000005', 'tachycardia', '/ˌtæk.ɪˈkɑːr.di.ə/', 'taquicardia', 'An abnormally fast heart rate, usually over 100 beats per minute.', 'Frecuencia cardíaca anormalmente rápida, generalmente por encima de 100 latidos por minuto.', 'The monitor showed tachycardia at 130.', 'El monitor mostró taquicardia a 130.', 'emergency', 'intermediate', ARRAY['emergency','sign','vital'], FALSE),
  ('ca4c0000-0000-0000-0000-000000000006', 'hypotension', '/ˌhaɪ.poʊˈten.ʃən/', 'hipotensión', 'Abnormally low blood pressure.', 'Presión arterial anormalmente baja.', 'Persistent hypotension suggests ongoing blood loss.', 'La hipotensión persistente sugiere pérdida de sangre en curso.', 'emergency', 'advanced', ARRAY['emergency','sign','vital'], FALSE),
  ('ca4c0000-0000-0000-0000-000000000007', 'airway', '/ˈer.weɪ/', 'vía aérea', 'The passage through which air reaches the lungs.', 'El conducto por el que el aire llega a los pulmones.', 'Check that the airway is open and clear.', 'Compruebe que la vía aérea esté abierta y despejada.', 'emergency', 'intermediate', ARRAY['emergency','anatomy','exam'], FALSE),
  ('ca4c0000-0000-0000-0000-000000000008', 'contusion', '/kənˈtuː.ʒən/', 'contusión', 'A bruise; an injury from a blunt blow that does not break the skin.', 'Moretón; lesión por un golpe contundente que no rompe la piel.', 'She has a contusion over the left rib cage.', 'Tiene una contusión sobre las costillas izquierdas.', 'emergency', 'intermediate', ARRAY['emergency','trauma','injury'], FALSE),
  ('ca4c0000-0000-0000-0000-000000000009', 'tourniquet', '/ˈtɜːr.nɪ.kət/', 'torniquete', 'A tight band applied around a limb to stop severe arterial bleeding.', 'Banda apretada aplicada alrededor de una extremidad para detener un sangrado arterial grave.', 'Apply a tourniquet above the wound.', 'Coloque un torniquete por encima de la herida.', 'emergency', 'advanced', ARRAY['emergency','trauma','procedure'], FALSE),
  ('ca4c0000-0000-0000-0000-00000000000a', 'unresponsive', '/ˌʌn.rɪˈspɑːn.sɪv/', 'sin respuesta', 'Not reacting to voice, touch, or pain; a patient who does not respond.', 'Que no reacciona a la voz, el tacto ni el dolor; paciente que no responde.', 'The patient is unresponsive but breathing.', 'El paciente no responde pero respira.', 'emergency', 'intermediate', ARRAY['emergency','sign','exam'], FALSE)
ON CONFLICT (id) DO NOTHING;

-- Link vocabulary to lessons -------------------------------------------------
INSERT INTO lesson_vocabulary (lesson_id, vocabulary_id, sort_order)
VALUES
  ('ca400001-0000-0000-0000-000000000001', 'ca4c0000-0000-0000-0000-000000000001', 0),
  ('ca400001-0000-0000-0000-000000000001', 'ca4c0000-0000-0000-0000-000000000002', 1),
  ('ca400001-0000-0000-0000-000000000001', 'ca4c0000-0000-0000-0000-000000000005', 2),
  ('ca400001-0000-0000-0000-000000000001', 'ca4c0000-0000-0000-0000-000000000006', 3),
  ('ca400001-0000-0000-0000-000000000001', 'ca4c0000-0000-0000-0000-00000000000a', 4),
  ('ca400001-0000-0000-0000-000000000003', 'ca4c0000-0000-0000-0000-000000000003', 5),
  ('ca400001-0000-0000-0000-000000000003', 'ca4c0000-0000-0000-0000-000000000007', 6),
  ('ca400001-0000-0000-0000-000000000004', 'ca4c0000-0000-0000-0000-000000000004', 7),
  ('ca400001-0000-0000-0000-000000000004', 'ca4c0000-0000-0000-0000-000000000008', 8),
  ('ca400001-0000-0000-0000-000000000004', 'ca4c0000-0000-0000-0000-000000000009', 9)
ON CONFLICT DO NOTHING;

-- ==== 05_gastroenterology ====
-- ============================================================================
-- Clinical English by Specialty — Module 5: Gastroenterology (Abdominal Complaints)
-- module_id cb000005…cb · content UUIDs prefixed ca5… · is_published = FALSE
-- AI-drafted, pending physician validation.
-- ============================================================================

-- Lessons --------------------------------------------------------------------
INSERT INTO lessons (id, module_id, slug, title, description, lesson_type, difficulty, estimated_minutes, xp_reward, sort_order, is_published, intro_text, completion_text)
VALUES
  ('ca500001-0000-0000-0000-000000000001', 'cb000005-0000-0000-0000-0000000000cb', 'gi-vocabulary',
   'GI Symptoms & Vocabulary', 'Core terms for gastrointestinal symptoms and presentations.', 'standard', 'intermediate', 6, 50, 0, FALSE,
   'Learn the English terms patients and clinicians use for GI symptoms.', 'You can now name the key GI symptoms in English.'),
  ('ca500001-0000-0000-0000-000000000002', 'cb000005-0000-0000-0000-0000000000cb', 'abdominal-pain-history',
   'Taking an Abdominal-Pain History', 'Ask focused questions about the location, character, and associated symptoms of abdominal pain.', 'standard', 'intermediate', 7, 60, 1, FALSE,
   'Practice the questions of a focused abdominal-pain history (SOCRATES).', 'You can now take a focused abdominal-pain history in English.'),
  ('ca500001-0000-0000-0000-000000000003', 'cb000005-0000-0000-0000-0000000000cb', 'abdominal-exam',
   'The Abdominal Examination', 'Inspection, palpation, and exam language, said clearly.', 'pronunciation', 'intermediate', 6, 55, 2, FALSE,
   'Say abdominal exam terms clearly and give exam instructions.', 'Your abdominal exam English is clearer and more confident.'),
  ('ca500001-0000-0000-0000-000000000004', 'cb000005-0000-0000-0000-0000000000cb', 'acute-abdomen-case',
   'Clinical Case: Acute Abdomen', 'A 22-year-old with migrating right lower-quadrant pain — reason through it in English.', 'clinical_case', 'intermediate', 9, 75, 3, FALSE,
   'Work through an acute-abdomen presentation in English.', 'You reasoned through an acute appendicitis presentation in English.'),
  ('ca500001-0000-0000-0000-000000000005', 'cb000005-0000-0000-0000-0000000000cb', 'gastroenterology-review',
   'Gastroenterology Review', 'Consolidate the module.', 'test', 'intermediate', 6, 60, 4, FALSE,
   'Review the gastroenterology module.', 'Gastroenterology module complete.')
ON CONFLICT (id) DO NOTHING;

-- Lesson 1 exercises (GI symptoms & vocabulary) ------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca5e0101-0000-0000-0000-000000000001', 'ca500001-0000-0000-0000-000000000001', 'multiple_choice',
   'A patient says "I feel like I''m going to throw up, but nothing comes out." Which term documents this?', 'Nausea',
   'Nausea = the unpleasant urge to vomit, without necessarily vomiting.', 'Náusea = la sensación desagradable de ganas de vomitar, sin vomitar necesariamente.',
   'intermediate', 10, 0, '{}'::jsonb, FALSE),
  ('ca5e0101-0000-0000-0000-000000000002', 'ca500001-0000-0000-0000-000000000001', 'flashcard',
   'jaundice', 'ictericia',
   'Yellowing of the skin and eyes from excess bilirubin.', 'Coloración amarilla de piel y ojos por exceso de bilirrubina.',
   'intermediate', 10, 1, '{"front":{"text":"jaundice","subtext":"/ˈdʒɔːn.dɪs/"},"back":{"text":"ictericia","translation":"ictericia","example":"The patient has jaundice and dark urine.","explanation":"Look for yellowing of the sclerae; ask about pale stools and dark urine."}}'::jsonb, FALSE),
  ('ca5e0101-0000-0000-0000-000000000003', 'ca500001-0000-0000-0000-000000000001', 'fill_in_blank',
   'Complete: "Yellowing of the skin and the whites of the eyes is called ______."', 'jaundice',
   'Jaundice reflects an elevated bilirubin, seen in liver and biliary disease.', 'La ictericia refleja bilirrubina elevada, presente en enfermedad hepática y biliar.',
   'intermediate', 10, 2, '{"acceptable_answers":["jaundice"],"case_sensitive":false}'::jsonb, FALSE),
  ('ca5e0101-0000-0000-0000-000000000004', 'ca500001-0000-0000-0000-000000000001', 'matching',
   'Match each GI term with its meaning.', NULL,
   'Core gastrointestinal vocabulary.', 'Vocabulario gastrointestinal básico.',
   'intermediate', 10, 3, '{"columns":2}'::jsonb, FALSE),
  ('ca5e0101-0000-0000-0000-000000000005', 'ca500001-0000-0000-0000-000000000001', 'translation',
   'Translate to English: "El paciente refiere náuseas y vómitos desde ayer."', 'The patient reports nausea and vomiting since yesterday.',
   'Pair "nausea and vomiting" together; it is a common documented complaint.', 'Se documentan juntos "nausea and vomiting"; es una queja frecuente.',
   'intermediate', 10, 4, '{"source_language":"es","target_language":"en","source_text":"El paciente refiere náuseas y vómitos desde ayer.","acceptable_translations":["The patient reports nausea and vomiting since yesterday.","The patient has nausea and vomiting since yesterday.","The patient reports nausea and vomiting starting yesterday."],"key_terms":["nausea","vomiting","since yesterday"]}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

-- matching options for ca5e0101-...004 (grouped by match_pair_id) -------------
INSERT INTO exercise_options (exercise_id, option_text, match_pair_id, sort_order)
VALUES
  ('ca5e0101-0000-0000-0000-000000000004', 'nausea', 'p1', 0),
  ('ca5e0101-0000-0000-0000-000000000004', 'the urge to vomit', 'p1', 1),
  ('ca5e0101-0000-0000-0000-000000000004', 'jaundice', 'p2', 2),
  ('ca5e0101-0000-0000-0000-000000000004', 'yellowing of the skin and eyes', 'p2', 3),
  ('ca5e0101-0000-0000-0000-000000000004', 'dysphagia', 'p3', 4),
  ('ca5e0101-0000-0000-0000-000000000004', 'difficulty swallowing', 'p3', 5),
  ('ca5e0101-0000-0000-0000-000000000004', 'constipation', 'p4', 6),
  ('ca5e0101-0000-0000-0000-000000000004', 'infrequent, hard-to-pass stools', 'p4', 7)
ON CONFLICT DO NOTHING;

-- multiple-choice options for ca5e0101-...001 --------------------------------
INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca5e0101-0000-0000-0000-000000000001', 'Nausea', TRUE, 0),
  ('ca5e0101-0000-0000-0000-000000000001', 'Dysphagia', FALSE, 1),
  ('ca5e0101-0000-0000-0000-000000000001', 'Jaundice', FALSE, 2),
  ('ca5e0101-0000-0000-0000-000000000001', 'Constipation', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Lesson 2 exercises (abdominal-pain history) --------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca5e0201-0000-0000-0000-000000000001', 'ca500001-0000-0000-0000-000000000002', 'multiple_choice',
   'You want the patient to show you where the pain is. Which question is most natural?', 'Can you point to where it hurts the most?',
   'Asking the patient to point localizes the pain quickly and clearly.', 'Pedir al paciente que señale localiza el dolor de forma rápida y clara.',
   'intermediate', 10, 0, '{}'::jsonb, FALSE),
  ('ca5e0201-0000-0000-0000-000000000002', 'ca500001-0000-0000-0000-000000000002', 'sentence_ordering',
   'Put the history question in order.', 'Does the pain come and go or is it constant?',
   'This distinguishes colicky (intermittent) from constant pain.', 'Distingue el dolor cólico (intermitente) del dolor constante.',
   'intermediate', 10, 1, '{"words":["Does","the","pain","come","and","go","or","is","it","constant"]}'::jsonb, FALSE),
  ('ca5e0201-0000-0000-0000-000000000003', 'ca500001-0000-0000-0000-000000000002', 'fill_in_blank',
   'Complete: "Pain that comes in waves and builds to a peak is described as ______."', 'colicky',
   'Colicky pain waxes and wanes; it is typical of obstruction of a hollow organ.', 'El dolor cólico aumenta y disminuye; es típico de la obstrucción de una víscera hueca.',
   'intermediate', 10, 2, '{"acceptable_answers":["colicky","cramping"],"case_sensitive":false,"word_bank":["colicky","cramping","burning","stabbing"]}'::jsonb, FALSE),
  ('ca5e0201-0000-0000-0000-000000000004', 'ca500001-0000-0000-0000-000000000002', 'translation',
   'Translate to English: "¿El dolor comenzó alrededor del ombligo?"', 'Did the pain start around the belly button?',
   'Periumbilical pain that later migrates is a classic appendicitis clue.', 'El dolor periumbilical que luego migra es una pista clásica de apendicitis.',
   'intermediate', 10, 3, '{"source_language":"es","target_language":"en","source_text":"¿El dolor comenzó alrededor del ombligo?","acceptable_translations":["Did the pain start around the belly button?","Did the pain start around your belly button?","Did the pain begin around the navel?"],"key_terms":["belly button","navel","umbilicus"]}'::jsonb, FALSE),
  ('ca5e0201-0000-0000-0000-000000000005', 'ca500001-0000-0000-0000-000000000002', 'typing',
   'Type the term: the "C" in SOCRATES asks about the ______ of the pain (sharp, dull, cramping).', 'character',
   'SOCRATES: Site, Onset, Character, Radiation, Associations, Timing, Exacerbating factors, Severity.', 'SOCRATES: sitio, inicio, carácter (character), irradiación, asociaciones, tiempo, factores, severidad.',
   'intermediate', 10, 4, '{"acceptable_answers":["character","quality"],"case_sensitive":false}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca5e0201-0000-0000-0000-000000000001', 'Can you point to where it hurts the most?', TRUE, 0),
  ('ca5e0201-0000-0000-0000-000000000001', 'Is the pain in your imagination?', FALSE, 1),
  ('ca5e0201-0000-0000-0000-000000000001', 'Do you have pain?', FALSE, 2),
  ('ca5e0201-0000-0000-0000-000000000001', 'Why did you eat something bad?', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Lesson 3 exercises (abdominal exam — pronunciation) ------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca5e0301-0000-0000-0000-000000000001', 'ca500001-0000-0000-0000-000000000003', 'pronunciation',
   'Say the word: "palpation"', 'palpation',
   'Palpation = examining the abdomen by feeling it with the hands.', 'Palpación: examinar el abdomen palpándolo con las manos.',
   'intermediate', 10, 0, '{"word":"palpation","phonetic":"/pælˈpeɪ.ʃən/","minimum_score":60,"syllables":["pal","pa","tion"]}'::jsonb, FALSE),
  ('ca5e0301-0000-0000-0000-000000000002', 'ca500001-0000-0000-0000-000000000003', 'pronunciation',
   'Say the word: "abdomen"', 'abdomen',
   'The abdomen is the belly, between the chest and the pelvis.', 'El abdomen es el vientre, entre el tórax y la pelvis.',
   'intermediate', 10, 1, '{"word":"abdomen","phonetic":"/ˈæb.də.mən/","minimum_score":60,"common_mistakes":[{"mistake":"ab-DOH-men with stress on the second syllable","correction":"stress the first syllable: AB-do-men"}]}'::jsonb, FALSE),
  ('ca5e0301-0000-0000-0000-000000000003', 'ca500001-0000-0000-0000-000000000003', 'multiple_choice',
   'Which instruction best helps the patient relax the abdominal wall for palpation?', 'Bend your knees and let your belly go soft.',
   'Flexing the knees and relaxing the abdomen reduces voluntary guarding.', 'Flexionar las rodillas y relajar el abdomen reduce la defensa voluntaria.',
   'intermediate', 10, 2, '{}'::jsonb, FALSE),
  ('ca5e0301-0000-0000-0000-000000000004', 'ca500001-0000-0000-0000-000000000003', 'fill_in_blank',
   'Complete: "Pain felt when you quickly release your hand after pressing is called ______ tenderness."', 'rebound',
   'Rebound tenderness suggests peritoneal irritation (peritonitis).', 'El dolor de rebote (rebound) sugiere irritación peritoneal (peritonitis).',
   'intermediate', 10, 3, '{"acceptable_answers":["rebound"],"case_sensitive":false}'::jsonb, FALSE),
  ('ca5e0301-0000-0000-0000-000000000005', 'ca500001-0000-0000-0000-000000000003', 'translation',
   'Translate to English (exam instruction): "Dígame si le duele cuando presiono."', 'Tell me if it hurts when I press.',
   'Clear, simple exam commands help you localize tenderness.', 'Órdenes de examen claras y sencillas ayudan a localizar el dolor.',
   'intermediate', 10, 4, '{"source_language":"es","target_language":"en","source_text":"Dígame si le duele cuando presiono.","acceptable_translations":["Tell me if it hurts when I press.","Let me know if it hurts when I press.","Tell me if this hurts when I press."],"key_terms":["press","hurts"]}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca5e0301-0000-0000-0000-000000000003', 'Bend your knees and let your belly go soft.', TRUE, 0),
  ('ca5e0301-0000-0000-0000-000000000003', 'Hold your breath and tense your stomach.', FALSE, 1),
  ('ca5e0301-0000-0000-0000-000000000003', 'Stand up and jump, please.', FALSE, 2),
  ('ca5e0301-0000-0000-0000-000000000003', 'Push against my hand as hard as you can.', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Lesson 4 exercises (clinical case: acute abdomen — appendicitis) -----------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca5e0401-0000-0000-0000-000000000001', 'ca500001-0000-0000-0000-000000000004', 'multiple_choice',
   'A 22-year-old reports pain that began around the navel and moved to the right lower quadrant, with loss of appetite, low-grade fever, and tenderness at McBurney''s point. Which is the most likely diagnosis?', 'Acute appendicitis',
   'Migrating periumbilical-to-RLQ pain with anorexia and focal tenderness is the classic appendicitis picture.', 'El dolor que migra de periumbilical a la fosa ilíaca derecha con anorexia y dolor focal es el cuadro clásico de apendicitis.',
   'intermediate', 12, 0, '{}'::jsonb, FALSE),
  ('ca5e0401-0000-0000-0000-000000000002', 'ca500001-0000-0000-0000-000000000004', 'fill_in_blank',
   'Complete the handoff: "22-year-old with pain that migrated from the umbilicus to the right lower ______ — I am concerned about appendicitis."', 'quadrant',
   'The abdomen is mapped in four quadrants; the appendix sits in the right lower quadrant (RLQ).', 'El abdomen se divide en cuatro cuadrantes; el apéndice está en el cuadrante inferior derecho (RLQ).',
   'intermediate', 12, 1, '{"acceptable_answers":["quadrant"],"case_sensitive":false}'::jsonb, FALSE),
  ('ca5e0401-0000-0000-0000-000000000003', 'ca500001-0000-0000-0000-000000000004', 'translation',
   'Translate for the patient: "Le vamos a hacer una tomografía del abdomen."', 'We are going to do a CT scan of your abdomen.',
   'A CT scan of the abdomen helps confirm appendicitis when the diagnosis is unclear.', 'La tomografía (CT) de abdomen ayuda a confirmar la apendicitis cuando el diagnóstico no está claro.',
   'intermediate', 12, 2, '{"source_language":"es","target_language":"en","source_text":"Le vamos a hacer una tomografía del abdomen.","acceptable_translations":["We are going to do a CT scan of your abdomen.","We are going to get a CT scan of your abdomen.","We will do a CT scan of your abdomen."],"key_terms":["CT scan","abdomen"]}'::jsonb, FALSE),
  ('ca5e0401-0000-0000-0000-000000000004', 'ca500001-0000-0000-0000-000000000004', 'sentence_ordering',
   'Order the instruction to keep the patient NPO before possible surgery.', 'Please do not eat or drink anything for now.',
   'Keeping the patient NPO (nothing by mouth) is important before possible surgery.', 'Mantener al paciente en ayuno (NPO) es importante antes de una posible cirugía.',
   'intermediate', 12, 3, '{"words":["Please","do","not","eat","or","drink","anything","for","now"]}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca5e0401-0000-0000-0000-000000000001', 'Acute appendicitis', TRUE, 0),
  ('ca5e0401-0000-0000-0000-000000000001', 'Simple viral gastroenteritis', FALSE, 1),
  ('ca5e0401-0000-0000-0000-000000000001', 'Chronic constipation', FALSE, 2),
  ('ca5e0401-0000-0000-0000-000000000001', 'Tension headache', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Lesson 5 exercises (review/test) -------------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca5e0501-0000-0000-0000-000000000001', 'ca500001-0000-0000-0000-000000000005', 'multiple_choice',
   'Which set of features most suggests appendicitis rather than simple indigestion?', 'Periumbilical pain migrating to the right lower quadrant with fever and anorexia',
   'Migration, fever, and loss of appetite point to appendicitis, not indigestion.', 'La migración, la fiebre y la pérdida de apetito apuntan a apendicitis, no a indigestión.',
   'intermediate', 12, 0, '{}'::jsonb, FALSE),
  ('ca5e0501-0000-0000-0000-000000000002', 'ca500001-0000-0000-0000-000000000005', 'flashcard',
   'dysphagia', 'disfagia',
   'Difficulty swallowing; ask whether it is worse with solids or liquids.', 'Dificultad para tragar; pregunte si es peor con sólidos o líquidos.',
   'intermediate', 10, 1, '{"front":{"text":"dysphagia","subtext":"/dɪsˈfeɪ.dʒə/"},"back":{"text":"disfagia","translation":"disfagia","example":"He has dysphagia to solids."}}'::jsonb, FALSE),
  ('ca5e0501-0000-0000-0000-000000000003', 'ca500001-0000-0000-0000-000000000005', 'typing',
   'Type the term: difficulty swallowing is called ______.', 'dysphagia',
   'Dysphagia = difficulty swallowing; it warrants further evaluation.', 'Disfagia = dificultad para tragar; requiere evaluación adicional.',
   'intermediate', 10, 2, '{"acceptable_answers":["dysphagia"],"case_sensitive":false}'::jsonb, FALSE),
  ('ca5e0501-0000-0000-0000-000000000004', 'ca500001-0000-0000-0000-000000000005', 'translation',
   'Translate to English: "¿Ha notado sangre en las heces?"', 'Have you noticed blood in your stool?',
   '"Stool" is the chart word; "poop" or "bowel movement" work with patients.', '"Stool" es el término clínico; "poop" o "bowel movement" sirven con el paciente.',
   'intermediate', 10, 3, '{"source_language":"es","target_language":"en","source_text":"¿Ha notado sangre en las heces?","acceptable_translations":["Have you noticed blood in your stool?","Have you seen blood in your stool?","Have you noticed any blood in your stool?"],"key_terms":["blood","stool"]}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca5e0501-0000-0000-0000-000000000001', 'Periumbilical pain migrating to the right lower quadrant with fever and anorexia', TRUE, 0),
  ('ca5e0501-0000-0000-0000-000000000001', 'Sneezing, sore throat, and runny nose', FALSE, 1),
  ('ca5e0501-0000-0000-0000-000000000001', 'Itchy eyes and a skin rash', FALSE, 2),
  ('ca5e0501-0000-0000-0000-000000000001', 'Occasional bloating relieved by burping', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Vocabulary (module 5) ------------------------------------------------------
INSERT INTO vocabulary (id, word, phonetic, translation_es, definition_en, definition_es, example_en, example_es, category, difficulty, tags, is_published)
VALUES
  ('ca5c0000-0000-0000-0000-000000000001', 'nausea', '/ˈnɔː.zi.ə/', 'náusea', 'The unpleasant urge to vomit.', 'Sensación desagradable de ganas de vomitar.', 'She has nausea and cannot keep food down.', 'Tiene náuseas y no tolera los alimentos.', 'gastroenterology', 'intermediate', ARRAY['gi','symptom'], FALSE),
  ('ca5c0000-0000-0000-0000-000000000002', 'vomiting', '/ˈvɒm.ɪ.tɪŋ/', 'vómito', 'The forceful expulsion of stomach contents through the mouth.', 'Expulsión forzada del contenido gástrico por la boca.', 'The vomiting started after dinner.', 'El vómito comenzó después de la cena.', 'gastroenterology', 'intermediate', ARRAY['gi','symptom'], FALSE),
  ('ca5c0000-0000-0000-0000-000000000003', 'diarrhea', '/ˌdaɪ.əˈriː.ə/', 'diarrea', 'Loose or watery stools, usually more frequent than normal.', 'Heces sueltas o líquidas, generalmente más frecuentes de lo normal.', 'He has had watery diarrhea for two days.', 'Ha tenido diarrea líquida durante dos días.', 'gastroenterology', 'intermediate', ARRAY['gi','symptom'], FALSE),
  ('ca5c0000-0000-0000-0000-000000000004', 'constipation', '/ˌkɒn.stɪˈpeɪ.ʃən/', 'estreñimiento', 'Infrequent or difficult passage of hard stools.', 'Evacuación infrecuente o difícil de heces duras.', 'Her constipation improved with more fiber.', 'Su estreñimiento mejoró con más fibra.', 'gastroenterology', 'intermediate', ARRAY['gi','symptom'], FALSE),
  ('ca5c0000-0000-0000-0000-000000000005', 'heartburn', '/ˈhɑːrt.bɜːrn/', 'acidez (pirosis)', 'A burning sensation behind the breastbone from acid reflux.', 'Sensación de ardor detrás del esternón por reflujo ácido.', 'He gets heartburn after spicy meals.', 'Tiene acidez tras comidas picantes.', 'gastroenterology', 'intermediate', ARRAY['gi','symptom'], FALSE),
  ('ca5c0000-0000-0000-0000-000000000006', 'bloating', '/ˈbləʊ.tɪŋ/', 'distensión abdominal', 'A feeling of fullness or swelling in the abdomen.', 'Sensación de plenitud o hinchazón en el abdomen.', 'She reports bloating after meals.', 'Refiere distensión abdominal tras las comidas.', 'gastroenterology', 'intermediate', ARRAY['gi','symptom'], FALSE),
  ('ca5c0000-0000-0000-0000-000000000007', 'jaundice', '/ˈdʒɔːn.dɪs/', 'ictericia', 'Yellowing of the skin and eyes from excess bilirubin.', 'Coloración amarilla de piel y ojos por exceso de bilirrubina.', 'The jaundice suggests a liver or biliary problem.', 'La ictericia sugiere un problema hepático o biliar.', 'gastroenterology', 'advanced', ARRAY['gi','sign'], FALSE),
  ('ca5c0000-0000-0000-0000-000000000008', 'dysphagia', '/dɪsˈfeɪ.dʒə/', 'disfagia', 'Difficulty swallowing solids or liquids.', 'Dificultad para tragar sólidos o líquidos.', 'His dysphagia is worse with solid food.', 'Su disfagia es peor con alimentos sólidos.', 'gastroenterology', 'advanced', ARRAY['gi','symptom'], FALSE),
  ('ca5c0000-0000-0000-0000-000000000009', 'tenderness', '/ˈtɛn.dər.nəs/', 'dolor a la palpación', 'Pain or discomfort felt when an area is pressed during examination.', 'Dolor o molestia al presionar una zona durante el examen.', 'There is tenderness in the right lower quadrant.', 'Hay dolor a la palpación en el cuadrante inferior derecho.', 'gastroenterology', 'intermediate', ARRAY['gi','sign','exam'], FALSE),
  ('ca5c0000-0000-0000-0000-00000000000a', 'guarding', '/ˈɡɑːr.dɪŋ/', 'defensa abdominal', 'Tensing of the abdominal wall muscles in response to palpation or pain.', 'Contracción de los músculos de la pared abdominal ante la palpación o el dolor.', 'Involuntary guarding suggests peritoneal irritation.', 'La defensa involuntaria sugiere irritación peritoneal.', 'gastroenterology', 'advanced', ARRAY['gi','sign','exam'], FALSE)
ON CONFLICT (id) DO NOTHING;

-- Link vocabulary to lessons -------------------------------------------------
INSERT INTO lesson_vocabulary (lesson_id, vocabulary_id, sort_order)
VALUES
  ('ca500001-0000-0000-0000-000000000001', 'ca5c0000-0000-0000-0000-000000000001', 0),
  ('ca500001-0000-0000-0000-000000000001', 'ca5c0000-0000-0000-0000-000000000002', 1),
  ('ca500001-0000-0000-0000-000000000001', 'ca5c0000-0000-0000-0000-000000000003', 2),
  ('ca500001-0000-0000-0000-000000000001', 'ca5c0000-0000-0000-0000-000000000004', 3),
  ('ca500001-0000-0000-0000-000000000001', 'ca5c0000-0000-0000-0000-000000000005', 4),
  ('ca500001-0000-0000-0000-000000000001', 'ca5c0000-0000-0000-0000-000000000006', 5),
  ('ca500001-0000-0000-0000-000000000003', 'ca5c0000-0000-0000-0000-000000000009', 6),
  ('ca500001-0000-0000-0000-000000000003', 'ca5c0000-0000-0000-0000-00000000000a', 7),
  ('ca500001-0000-0000-0000-000000000005', 'ca5c0000-0000-0000-0000-000000000007', 8),
  ('ca500001-0000-0000-0000-000000000005', 'ca5c0000-0000-0000-0000-000000000008', 9)
ON CONFLICT DO NOTHING;

-- ==== 06_neurology ====
-- ============================================================================
-- Clinical English by Specialty — Module 6: Neurology (Neuro Assessment)
-- module_id cb000006…cb · content UUIDs prefixed ca6… · is_published = FALSE
-- AI-drafted, pending physician validation.
-- ============================================================================

-- Lessons --------------------------------------------------------------------
INSERT INTO lessons (id, module_id, slug, title, description, lesson_type, difficulty, estimated_minutes, xp_reward, sort_order, is_published, intro_text, completion_text)
VALUES
  ('ca600001-0000-0000-0000-000000000001', 'cb000006-0000-0000-0000-0000000000cb', 'neuro-vocabulary',
   'Neurological Symptoms & Vocabulary', 'Core terms for neurological symptoms and presentations.', 'standard', 'intermediate', 6, 50, 0, FALSE,
   'Learn the English terms patients and clinicians use for neurological symptoms.', 'You can now name the key neurological symptoms in English.'),
  ('ca600001-0000-0000-0000-000000000002', 'cb000006-0000-0000-0000-0000000000cb', 'neuro-history',
   'Taking a Neurological History', 'Ask focused questions about headache, weakness, and deficits.', 'standard', 'intermediate', 7, 60, 1, FALSE,
   'Practice the questions of a focused neurological history.', 'You can now take a focused neurological history in English.'),
  ('ca600001-0000-0000-0000-000000000003', 'cb000006-0000-0000-0000-0000000000cb', 'neuro-exam-commands',
   'The Neurological Examination', 'Give clear exam commands the patient can follow.', 'pronunciation', 'intermediate', 6, 55, 2, FALSE,
   'Say neuro exam commands clearly so patients follow them.', 'Your neuro exam English is clearer and more confident.'),
  ('ca600001-0000-0000-0000-000000000004', 'cb000006-0000-0000-0000-0000000000cb', 'acute-stroke-case',
   'Clinical Case: Acute Stroke', 'A 67-year-old with sudden deficits — reason through it in English.', 'clinical_case', 'intermediate', 9, 75, 3, FALSE,
   'Work through a time-critical acute stroke presentation in English.', 'You reasoned through an acute stroke presentation in English.'),
  ('ca600001-0000-0000-0000-000000000005', 'cb000006-0000-0000-0000-0000000000cb', 'neurology-review',
   'Neurology Review', 'Consolidate the module.', 'test', 'intermediate', 6, 60, 4, FALSE,
   'Review the neurology module.', 'Neurology module complete.')
ON CONFLICT (id) DO NOTHING;

-- Lesson 1 exercises (neuro vocabulary) --------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca6e0101-0000-0000-0000-000000000001', 'ca600001-0000-0000-0000-000000000001', 'multiple_choice',
   'A patient says "I can''t feel my left hand at all." Which term documents this?', 'Numbness',
   'Numbness = a loss or reduction of sensation in a body part.', 'Numbness (entumecimiento) = pérdida o disminución de la sensibilidad en una parte del cuerpo.',
   'intermediate', 10, 0, '{}'::jsonb, FALSE),
  ('ca6e0101-0000-0000-0000-000000000002', 'ca600001-0000-0000-0000-000000000001', 'flashcard',
   'seizure', 'convulsión',
   'A sudden burst of abnormal electrical activity in the brain.', 'Descarga súbita de actividad eléctrica anormal en el cerebro.',
   'intermediate', 10, 1, '{"front":{"text":"seizure","subtext":"/ˈsiː.ʒər/"},"back":{"text":"convulsión","translation":"convulsión / crisis","example":"The patient had a witnessed seizure lasting two minutes.","explanation":"Use \"seizure\" in charts; patients may say \"a fit\" or \"a convulsion\"."}}'::jsonb, FALSE),
  ('ca6e0101-0000-0000-0000-000000000003', 'ca600001-0000-0000-0000-000000000001', 'fill_in_blank',
   'Complete: "Sudden one-sided facial droop and arm weakness are red flags for a ______."', 'stroke',
   'A stroke is a sudden focal neurological deficit from disrupted cerebral blood flow.', 'Un ictus (stroke) es un déficit neurológico focal súbito por interrupción del flujo cerebral.',
   'intermediate', 10, 2, '{"acceptable_answers":["stroke","a stroke","cerebrovascular accident"],"case_sensitive":false}'::jsonb, FALSE),
  ('ca6e0101-0000-0000-0000-000000000004', 'ca600001-0000-0000-0000-000000000001', 'matching',
   'Match each neurological term with its meaning.', NULL,
   'Core neurological vocabulary.', 'Vocabulario neurológico básico.',
   'intermediate', 10, 3, '{"columns":2}'::jsonb, FALSE),
  ('ca6e0101-0000-0000-0000-000000000005', 'ca600001-0000-0000-0000-000000000001', 'translation',
   'Translate to English: "El paciente presenta debilidad en el lado derecho."', 'The patient has weakness on the right side.',
   '"Weakness" is the plain-language term for reduced muscle power.', '"Weakness" es el término sencillo para pérdida de fuerza muscular.',
   'intermediate', 10, 4, '{"source_language":"es","target_language":"en","source_text":"El paciente presenta debilidad en el lado derecho.","acceptable_translations":["The patient has weakness on the right side.","The patient has right-sided weakness.","There is weakness on the right side."],"key_terms":["weakness","right side"]}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

-- matching options for ca6e0101-...004 (grouped by match_pair_id) -------------
INSERT INTO exercise_options (exercise_id, option_text, match_pair_id, sort_order)
VALUES
  ('ca6e0101-0000-0000-0000-000000000004', 'numbness', 'p1', 0),
  ('ca6e0101-0000-0000-0000-000000000004', 'loss or reduction of sensation', 'p1', 1),
  ('ca6e0101-0000-0000-0000-000000000004', 'weakness', 'p2', 2),
  ('ca6e0101-0000-0000-0000-000000000004', 'reduced muscle power', 'p2', 3),
  ('ca6e0101-0000-0000-0000-000000000004', 'dizziness', 'p3', 4),
  ('ca6e0101-0000-0000-0000-000000000004', 'a sensation of spinning or lightheadedness', 'p3', 5),
  ('ca6e0101-0000-0000-0000-000000000004', 'seizure', 'p4', 6),
  ('ca6e0101-0000-0000-0000-000000000004', 'abnormal brain electrical activity causing convulsions', 'p4', 7)
ON CONFLICT DO NOTHING;

-- multiple-choice options for ca6e0101-...001 --------------------------------
INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca6e0101-0000-0000-0000-000000000001', 'Numbness', TRUE, 0),
  ('ca6e0101-0000-0000-0000-000000000001', 'Weakness', FALSE, 1),
  ('ca6e0101-0000-0000-0000-000000000001', 'Dizziness', FALSE, 2),
  ('ca6e0101-0000-0000-0000-000000000001', 'Headache', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Lesson 2 exercises (neuro history) -----------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca6e0201-0000-0000-0000-000000000001', 'ca600001-0000-0000-0000-000000000002', 'multiple_choice',
   'You want to know how a severe headache began. Which question best screens for a thunderclap headache?', 'Did the headache come on suddenly and reach its worst within seconds?',
   'A sudden "worst-ever" headache peaking in seconds raises concern for subarachnoid hemorrhage.', 'Una cefalea súbita "la peor de mi vida" que alcanza su máximo en segundos hace sospechar hemorragia subaracnoidea.',
   'intermediate', 10, 0, '{}'::jsonb, FALSE),
  ('ca6e0201-0000-0000-0000-000000000002', 'ca600001-0000-0000-0000-000000000002', 'sentence_ordering',
   'Put the history question in order.', 'Have you noticed any weakness on one side of your body?',
   'A focused question screening for a focal, lateralizing deficit.', 'Pregunta enfocada que busca un déficit focal y lateralizado.',
   'intermediate', 10, 1, '{"words":["Have","you","noticed","any","weakness","on","one","side","of","your","body"]}'::jsonb, FALSE),
  ('ca6e0201-0000-0000-0000-000000000003', 'ca600001-0000-0000-0000-000000000002', 'fill_in_blank',
   'Complete the timing question: "When did the symptoms first ______? Try to remember the exact time."', 'start',
   'Establishing the exact time of onset is essential for stroke treatment decisions.', 'Establecer la hora exacta de inicio es esencial para las decisiones de tratamiento del ictus.',
   'intermediate', 10, 2, '{"acceptable_answers":["start","begin","appear"],"case_sensitive":false,"word_bank":["start","begin","appear","stop"]}'::jsonb, FALSE),
  ('ca6e0201-0000-0000-0000-000000000004', 'ca600001-0000-0000-0000-000000000002', 'translation',
   'Translate to English: "¿Ha perdido el conocimiento en algún momento?"', 'Have you lost consciousness at any point?',
   'Loss of consciousness helps distinguish syncope, seizure, and other causes.', 'La pérdida de conocimiento ayuda a distinguir síncope, crisis y otras causas.',
   'intermediate', 10, 3, '{"source_language":"es","target_language":"en","source_text":"¿Ha perdido el conocimiento en algún momento?","acceptable_translations":["Have you lost consciousness at any point?","Have you lost consciousness at any time?","Did you lose consciousness at any point?"],"key_terms":["lost consciousness","at any point"]}'::jsonb, FALSE),
  ('ca6e0201-0000-0000-0000-000000000005', 'ca600001-0000-0000-0000-000000000002', 'typing',
   'Type the clinical term: the warning sensation some patients feel just before a seizure is called an ______.', 'aura',
   'An aura is a premonitory sensory symptom preceding a seizure or migraine.', 'El aura es un síntoma sensorial premonitorio que precede a una crisis o migraña.',
   'intermediate', 10, 4, '{"acceptable_answers":["aura","an aura"],"case_sensitive":false}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca6e0201-0000-0000-0000-000000000001', 'Did the headache come on suddenly and reach its worst within seconds?', TRUE, 0),
  ('ca6e0201-0000-0000-0000-000000000001', 'Is the headache all in your imagination?', FALSE, 1),
  ('ca6e0201-0000-0000-0000-000000000001', 'Do you have a headache?', FALSE, 2),
  ('ca6e0201-0000-0000-0000-000000000001', 'Why did you not take anything for it?', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Lesson 3 exercises (neuro exam commands — pronunciation) -------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca6e0301-0000-0000-0000-000000000001', 'ca600001-0000-0000-0000-000000000003', 'pronunciation',
   'Say the exam command: "Follow my finger with your eyes."', 'Follow my finger with your eyes.',
   'A clear command for testing extraocular movements without moving the head.', 'Orden clara para evaluar los movimientos oculares sin mover la cabeza.',
   'intermediate', 10, 0, '{"word":"Follow my finger with your eyes.","phonetic":"/ˈfɒl.oʊ maɪ ˈfɪŋ.ɡər wɪð jɔːr aɪz/","minimum_score":60,"common_mistakes":[{"mistake":"stressing \"finger\" as fin-GER","correction":"stress the first syllable: FIN-ger"}]}'::jsonb, FALSE),
  ('ca6e0301-0000-0000-0000-000000000002', 'ca600001-0000-0000-0000-000000000003', 'pronunciation',
   'Say the exam command: "Squeeze my hands."', 'Squeeze my hands.',
   'A grip-strength command; "squeeze" begins with a tricky /skw/ cluster.', 'Orden de fuerza de prensión; "squeeze" empieza con el grupo consonántico /skw/.',
   'intermediate', 10, 1, '{"word":"Squeeze my hands.","phonetic":"/skwiːz maɪ hændz/","minimum_score":60,"syllables":["squeeze","my","hands"],"common_mistakes":[{"mistake":"adding a vowel: es-queeze","correction":"blend the /skw/ cluster: skweez"}]}'::jsonb, FALSE),
  ('ca6e0301-0000-0000-0000-000000000003', 'ca600001-0000-0000-0000-000000000003', 'multiple_choice',
   'Which instruction tests limb coordination (finger-to-nose)?', 'Touch your nose, then touch my finger, back and forth.',
   'Finger-to-nose testing screens for dysmetria and cerebellar dysfunction.', 'La prueba dedo-nariz busca dismetría y disfunción cerebelosa.',
   'intermediate', 10, 2, '{}'::jsonb, FALSE),
  ('ca6e0301-0000-0000-0000-000000000004', 'ca600001-0000-0000-0000-000000000003', 'fill_in_blank',
   'Complete the exam command: "Please ______ your eyes and keep them closed until I say to open them."', 'close',
   'Testing facial strength and orbicularis oculi requires the patient to close the eyes tightly.', 'Evaluar la fuerza facial y el orbicular de los párpados requiere que el paciente cierre los ojos con fuerza.',
   'intermediate', 10, 3, '{"acceptable_answers":["close","shut"],"case_sensitive":false}'::jsonb, FALSE),
  ('ca6e0301-0000-0000-0000-000000000005', 'ca600001-0000-0000-0000-000000000003', 'translation',
   'Translate to English (exam command): "Empuje contra mi mano lo más fuerte que pueda."', 'Push against my hand as hard as you can.',
   'Clear strength commands let you grade power symmetrically.', 'Órdenes claras de fuerza permiten graduar la potencia de forma simétrica.',
   'intermediate', 10, 4, '{"source_language":"es","target_language":"en","source_text":"Empuje contra mi mano lo más fuerte que pueda.","acceptable_translations":["Push against my hand as hard as you can.","Push against my hand as hard as possible.","Push on my hand as hard as you can."],"key_terms":["push against","as hard as you can"]}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca6e0301-0000-0000-0000-000000000003', 'Touch your nose, then touch my finger, back and forth.', TRUE, 0),
  ('ca6e0301-0000-0000-0000-000000000003', 'Hold your breath and count to fifty.', FALSE, 1),
  ('ca6e0301-0000-0000-0000-000000000003', 'Read this paragraph out loud, please.', FALSE, 2),
  ('ca6e0301-0000-0000-0000-000000000003', 'Cough as hard as you can now.', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Lesson 4 exercises (clinical case: acute stroke) ---------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca6e0401-0000-0000-0000-000000000001', 'ca600001-0000-0000-0000-000000000004', 'multiple_choice',
   'A 67-year-old woman has sudden right-sided facial droop, arm weakness, and slurred speech that began 40 minutes ago. Which is the priority action?', 'Activate the stroke protocol, confirm the time of onset, and get an urgent head CT.',
   'Acute stroke is time-critical: rapid imaging and an exact onset time drive reperfusion decisions.', 'El ictus agudo es tiempo-dependiente: la imagen rápida y la hora exacta de inicio guían las decisiones de reperfusión.',
   'intermediate', 12, 0, '{}'::jsonb, FALSE),
  ('ca6e0401-0000-0000-0000-000000000002', 'ca600001-0000-0000-0000-000000000004', 'fill_in_blank',
   'Complete the FAST acronym: "F is for face, A is for arms, S is for speech, and T is for ______."', 'time',
   'FAST: Face drooping, Arm weakness, Speech difficulty, Time to call emergency services.', 'FAST: caída Facial, debilidad de brAzo, dificultad del hablA (Speech), y Tiempo para llamar a emergencias.',
   'intermediate', 12, 1, '{"acceptable_answers":["time","time to call"],"case_sensitive":false}'::jsonb, FALSE),
  ('ca6e0401-0000-0000-0000-000000000003', 'ca600001-0000-0000-0000-000000000004', 'translation',
   'Translate for the family: "¿A qué hora exacta empezaron los síntomas?"', 'What exact time did the symptoms start?',
   'The last-known-well time determines eligibility for clot-busting treatment.', 'La hora del último estado normal conocido determina la elegibilidad para el tratamiento trombolítico.',
   'intermediate', 12, 2, '{"source_language":"es","target_language":"en","source_text":"¿A qué hora exacta empezaron los síntomas?","acceptable_translations":["What exact time did the symptoms start?","At what exact time did the symptoms start?","What time exactly did the symptoms begin?"],"key_terms":["exact time","symptoms start"]}'::jsonb, FALSE),
  ('ca6e0401-0000-0000-0000-000000000004', 'ca600001-0000-0000-0000-000000000004', 'sentence_ordering',
   'Order the reassuring instruction to the patient.', 'Try to stay still and tell me if anything changes.',
   'Calm, clear instructions keep the patient safe while the team works quickly.', 'Instrucciones claras y calmadas mantienen al paciente seguro mientras el equipo actúa rápido.',
   'intermediate', 12, 3, '{"words":["Try","to","stay","still","and","tell","me","if","anything","changes"]}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca6e0401-0000-0000-0000-000000000001', 'Activate the stroke protocol, confirm the time of onset, and get an urgent head CT.', TRUE, 0),
  ('ca6e0401-0000-0000-0000-000000000001', 'Send her home and arrange a routine MRI next week.', FALSE, 1),
  ('ca6e0401-0000-0000-0000-000000000001', 'Reassure her and wait a few hours to see if it resolves.', FALSE, 2),
  ('ca6e0401-0000-0000-0000-000000000001', 'Give her a headache tablet and discharge her.', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Lesson 5 exercises (review/test) -------------------------------------------
INSERT INTO exercises (id, lesson_id, exercise_type, prompt, correct_answer, explanation, explanation_es, difficulty, xp_reward, sort_order, metadata, is_published)
VALUES
  ('ca6e0501-0000-0000-0000-000000000001', 'ca600001-0000-0000-0000-000000000005', 'multiple_choice',
   'Which cluster of symptoms most suggests an acute stroke rather than a simple tension headache?', 'Sudden one-sided weakness, facial droop, and slurred speech',
   'Sudden focal deficits (weakness, facial droop, slurred speech) point to stroke, not a benign headache.', 'Los déficits focales súbitos (debilidad, caída facial, habla arrastrada) orientan a ictus, no a una cefalea benigna.',
   'intermediate', 12, 0, '{}'::jsonb, FALSE),
  ('ca6e0501-0000-0000-0000-000000000002', 'ca600001-0000-0000-0000-000000000005', 'flashcard',
   'aphasia', 'afasia',
   'A loss or impairment of the ability to produce or understand language.', 'Pérdida o alteración de la capacidad de producir o comprender el lenguaje.',
   'intermediate', 10, 1, '{"front":{"text":"aphasia","subtext":"/əˈfeɪ.ʒə/"},"back":{"text":"afasia","translation":"afasia","example":"The stroke left him with expressive aphasia."}}'::jsonb, FALSE),
  ('ca6e0501-0000-0000-0000-000000000003', 'ca600001-0000-0000-0000-000000000005', 'typing',
   'Type the term: slurred, poorly articulated speech caused by weak or uncoordinated muscles is called ______.', 'dysarthria',
   'Dysarthria is a motor speech disorder; the words are correct but poorly articulated.', 'La disartria es un trastorno motor del habla; las palabras son correctas pero mal articuladas.',
   'intermediate', 10, 2, '{"acceptable_answers":["dysarthria"],"case_sensitive":false}'::jsonb, FALSE),
  ('ca6e0501-0000-0000-0000-000000000004', 'ca600001-0000-0000-0000-000000000005', 'translation',
   'Translate to English: "¿Se le ha dormido la cara o el brazo?"', 'Has your face or arm gone numb?',
   '"Gone numb" is the everyday way patients describe numbness.', '"Gone numb" es la forma cotidiana en que los pacientes describen el entumecimiento.',
   'intermediate', 10, 3, '{"source_language":"es","target_language":"en","source_text":"¿Se le ha dormido la cara o el brazo?","acceptable_translations":["Has your face or arm gone numb?","Has your face or arm become numb?","Have your face or arm gone numb?"],"key_terms":["gone numb","face","arm"]}'::jsonb, FALSE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_options (exercise_id, option_text, is_correct, sort_order)
VALUES
  ('ca6e0501-0000-0000-0000-000000000001', 'Sudden one-sided weakness, facial droop, and slurred speech', TRUE, 0),
  ('ca6e0501-0000-0000-0000-000000000001', 'Sneezing, sore throat, and a runny nose', FALSE, 1),
  ('ca6e0501-0000-0000-0000-000000000001', 'Itchy eyes and a mild skin rash', FALSE, 2),
  ('ca6e0501-0000-0000-0000-000000000001', 'A gradual dull ache after a long day at a screen', FALSE, 3)
ON CONFLICT DO NOTHING;

-- Vocabulary (module 6) ------------------------------------------------------
INSERT INTO vocabulary (id, word, phonetic, translation_es, definition_en, definition_es, example_en, example_es, category, difficulty, tags, is_published)
VALUES
  ('ca6c0000-0000-0000-0000-000000000001', 'headache', '/ˈhɛd.eɪk/', 'dolor de cabeza', 'Pain located in any region of the head.', 'Dolor localizado en cualquier región de la cabeza.', 'She came in with a sudden, severe headache.', 'Llegó con un dolor de cabeza súbito e intenso.', 'neurology', 'intermediate', ARRAY['neuro','symptom'], FALSE),
  ('ca6c0000-0000-0000-0000-000000000002', 'weakness', '/ˈwiːk.nəs/', 'debilidad', 'A reduction in muscle power or strength.', 'Disminución de la fuerza o potencia muscular.', 'He reports weakness in his right leg.', 'Refiere debilidad en la pierna derecha.', 'neurology', 'intermediate', ARRAY['neuro','symptom'], FALSE),
  ('ca6c0000-0000-0000-0000-000000000003', 'numbness', '/ˈnʌm.nəs/', 'entumecimiento', 'A loss or reduction of sensation in a body part.', 'Pérdida o disminución de la sensibilidad en una parte del cuerpo.', 'The numbness spread from her hand to her arm.', 'El entumecimiento se extendió de la mano al brazo.', 'neurology', 'intermediate', ARRAY['neuro','symptom'], FALSE),
  ('ca6c0000-0000-0000-0000-000000000004', 'dizziness', '/ˈdɪz.i.nəs/', 'mareo', 'A sensation of spinning, unsteadiness, or lightheadedness.', 'Sensación de giro, inestabilidad o aturdimiento.', 'The dizziness worsens when he stands up.', 'El mareo empeora al ponerse de pie.', 'neurology', 'intermediate', ARRAY['neuro','symptom'], FALSE),
  ('ca6c0000-0000-0000-0000-000000000005', 'seizure', '/ˈsiː.ʒər/', 'convulsión', 'A sudden burst of abnormal electrical activity in the brain.', 'Descarga súbita de actividad eléctrica anormal en el cerebro.', 'The seizure lasted about two minutes.', 'La convulsión duró unos dos minutos.', 'neurology', 'intermediate', ARRAY['neuro','symptom'], FALSE),
  ('ca6c0000-0000-0000-0000-000000000006', 'paresthesia', '/ˌpær.ɪsˈθiː.ʒə/', 'parestesia', 'An abnormal tingling or "pins and needles" sensation.', 'Sensación anormal de hormigueo o "alfileres y agujas".', 'She describes paresthesia in both feet.', 'Describe parestesia en ambos pies.', 'neurology', 'advanced', ARRAY['neuro','symptom'], FALSE),
  ('ca6c0000-0000-0000-0000-000000000007', 'aphasia', '/əˈfeɪ.ʒə/', 'afasia', 'A loss or impairment of the ability to produce or understand language.', 'Pérdida o alteración de la capacidad de producir o comprender el lenguaje.', 'The stroke left him with expressive aphasia.', 'El ictus le dejó una afasia expresiva.', 'neurology', 'advanced', ARRAY['neuro','sign','stroke'], FALSE),
  ('ca6c0000-0000-0000-0000-000000000008', 'hemiparesis', '/ˌhɛm.i.pəˈriː.sɪs/', 'hemiparesia', 'Weakness affecting one side of the body.', 'Debilidad que afecta a un lado del cuerpo.', 'Left hemiparesis was noted on examination.', 'Se observó hemiparesia izquierda en la exploración.', 'neurology', 'advanced', ARRAY['neuro','sign','stroke'], FALSE),
  ('ca6c0000-0000-0000-0000-000000000009', 'dysarthria', '/dɪsˈɑːr.θri.ə/', 'disartria', 'Slurred or poorly articulated speech due to weak or uncoordinated muscles.', 'Habla arrastrada o mal articulada por músculos débiles o descoordinados.', 'His dysarthria made the words hard to understand.', 'Su disartria hacía difícil entender las palabras.', 'neurology', 'advanced', ARRAY['neuro','sign','exam'], FALSE),
  ('ca6c0000-0000-0000-0000-00000000000a', 'stroke', '/stroʊk/', 'ictus', 'A sudden focal neurological deficit caused by disrupted cerebral blood flow.', 'Déficit neurológico focal súbito por interrupción del flujo sanguíneo cerebral.', 'Time is critical in the treatment of an acute stroke.', 'El tiempo es crítico en el tratamiento del ictus agudo.', 'neurology', 'advanced', ARRAY['neuro','diagnosis','stroke'], FALSE)
ON CONFLICT (id) DO NOTHING;

-- Link vocabulary to lessons -------------------------------------------------
INSERT INTO lesson_vocabulary (lesson_id, vocabulary_id, sort_order)
VALUES
  ('ca600001-0000-0000-0000-000000000001', 'ca6c0000-0000-0000-0000-000000000001', 0),
  ('ca600001-0000-0000-0000-000000000001', 'ca6c0000-0000-0000-0000-000000000002', 1),
  ('ca600001-0000-0000-0000-000000000001', 'ca6c0000-0000-0000-0000-000000000003', 2),
  ('ca600001-0000-0000-0000-000000000001', 'ca6c0000-0000-0000-0000-000000000004', 3),
  ('ca600001-0000-0000-0000-000000000001', 'ca6c0000-0000-0000-0000-000000000005', 4),
  ('ca600001-0000-0000-0000-000000000003', 'ca6c0000-0000-0000-0000-000000000009', 5),
  ('ca600001-0000-0000-0000-000000000003', 'ca6c0000-0000-0000-0000-000000000006', 6),
  ('ca600001-0000-0000-0000-000000000005', 'ca6c0000-0000-0000-0000-000000000007', 7),
  ('ca600001-0000-0000-0000-000000000005', 'ca6c0000-0000-0000-0000-000000000008', 8),
  ('ca600001-0000-0000-0000-000000000005', 'ca6c0000-0000-0000-0000-00000000000a', 9)
ON CONFLICT DO NOTHING;
