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
