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
