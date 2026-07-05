-- ============================================================================
-- MediLingo — Achievement definitions (~50 badges)
-- Rollback: DELETE FROM achievements;
-- Idempotent: re-running updates nothing existing (ON CONFLICT DO NOTHING).
-- requirement JSONB: {"type": <metric>, "value": <n>} or course-specific.
-- ============================================================================

INSERT INTO achievements (slug, title, description, category, requirement, xp_reward, gem_reward, sort_order, is_secret) VALUES
-- Streak ---------------------------------------------------------------------
('streak_3',   '3-Day Streak',   'Learn 3 days in a row.',        'streak', '{"type":"streak","value":3}',   50,  5,  10, FALSE),
('streak_7',   '7-Day Streak',   'A full week of learning.',      'streak', '{"type":"streak","value":7}',   100, 10, 11, FALSE),
('streak_14',  '2-Week Streak',  'Fourteen days strong.',         'streak', '{"type":"streak","value":14}',  150, 15, 12, FALSE),
('streak_30',  '30-Day Streak',  'A month without missing.',      'streak', '{"type":"streak","value":30}',  250, 25, 13, FALSE),
('streak_100', '100-Day Streak', 'Triple-digit dedication.',      'streak', '{"type":"streak","value":100}', 400, 50, 14, FALSE),
('streak_365', '365-Day Streak', 'A full year, every day.',       'streak', '{"type":"streak","value":365}', 500, 100,15, FALSE),
-- Learning (lessons) ---------------------------------------------------------
('lessons_1',   'First Lesson',   'Complete your first lesson.',  'learning', '{"type":"lessons_completed","value":1}',   25,  5,  20, FALSE),
('lessons_10',  '10 Lessons',     'Ten lessons completed.',       'learning', '{"type":"lessons_completed","value":10}',  75,  10, 21, FALSE),
('lessons_25',  '25 Lessons',     'Twenty-five down.',            'learning', '{"type":"lessons_completed","value":25}',  100, 10, 22, FALSE),
('lessons_50',  '50 Lessons',     'Halfway to a hundred.',        'learning', '{"type":"lessons_completed","value":50}',  150, 20, 23, FALSE),
('lessons_100', '100 Lessons',    'A century of lessons.',        'learning', '{"type":"lessons_completed","value":100}', 300, 40, 24, FALSE),
-- Perfect lessons ------------------------------------------------------------
('perfect_1',  'Flawless',       'Finish a lesson with no mistakes.', 'learning', '{"type":"perfect_lessons","value":1}',  50,  5,  30, FALSE),
('perfect_10', 'Perfectionist',  'Ten perfect lessons.',              'learning', '{"type":"perfect_lessons","value":10}', 150, 20, 31, FALSE),
('perfect_25', 'Immaculate',     'Twenty-five perfect lessons.',      'learning', '{"type":"perfect_lessons","value":25}', 300, 40, 32, FALSE),
-- Exercises ------------------------------------------------------------------
('exercises_50',   '50 Exercises',   'Fifty exercises answered.',   'learning', '{"type":"exercises_completed","value":50}',   75,  10, 40, FALSE),
('exercises_250',  '250 Exercises',  'A quarter-thousand done.',    'learning', '{"type":"exercises_completed","value":250}',  150, 20, 41, FALSE),
('exercises_1000', '1000 Exercises', 'Exercise machine.',           'learning', '{"type":"exercises_completed","value":1000}', 400, 50, 42, FALSE),
-- Vocabulary -----------------------------------------------------------------
('words_50',   '50 Words',   'Learn 50 medical terms.',        'learning', '{"type":"words_learned","value":50}',   75,  10, 50, FALSE),
('words_100',  '100 Words',  'A hundred words mastered.',      'learning', '{"type":"words_learned","value":100}',  100, 10, 51, FALSE),
('words_250',  '250 Words',  'Building a real vocabulary.',    'learning', '{"type":"words_learned","value":250}',  150, 20, 52, FALSE),
('words_500',  '500 Words',  'Five hundred terms.',            'learning', '{"type":"words_learned","value":500}',  300, 40, 53, FALSE),
('words_1000', '1000 Words', 'Walking medical dictionary.',    'learning', '{"type":"words_learned","value":1000}', 500, 75, 54, FALSE),
-- Flashcards -----------------------------------------------------------------
('flashcards_100',  'Card Shark',    'Review 100 flashcards.',   'learning', '{"type":"flashcards_reviewed","value":100}',  75,  10, 60, FALSE),
('flashcards_500',  'Memory Master', 'Review 500 flashcards.',   'learning', '{"type":"flashcards_reviewed","value":500}',  200, 25, 61, FALSE),
-- Clinical -------------------------------------------------------------------
('clinical_1',       'First Diagnosis', 'Complete your first clinical case.', 'clinical', '{"type":"clinical_cases","value":1}',  100, 10, 70, FALSE),
('clinical_5',       '5 Cases',         'Five clinical cases solved.',        'clinical', '{"type":"clinical_cases","value":5}',  200, 25, 71, FALSE),
('clinical_25',      '25 Cases',        'Twenty-five cases handled.',         'clinical', '{"type":"clinical_cases","value":25}', 400, 50, 72, FALSE),
('clinical_perfect', 'Perfect Case',    'Ace a clinical case.',               'clinical', '{"type":"perfect_clinical_case","value":1}', 150, 20, 73, TRUE),
-- AI conversations -----------------------------------------------------------
('ai_1',   'First Consult',   'Complete an AI patient conversation.', 'clinical', '{"type":"ai_conversations","value":1}',  60,  5,  80, FALSE),
('ai_10',  'Bedside Manner',  'Ten AI conversations.',                'clinical', '{"type":"ai_conversations","value":10}', 200, 25, 81, FALSE),
('ai_50',  'Fluent Clinician','Fifty AI conversations.',              'clinical', '{"type":"ai_conversations","value":50}', 400, 50, 82, FALSE),
-- Levels / Milestones --------------------------------------------------------
('level_5',   'Level 5',   'Reach level 5.',   'milestone', '{"type":"level","value":5}',   50,  5,  90, FALSE),
('level_10',  'Level 10',  'Reach level 10.',  'milestone', '{"type":"level","value":10}',  100, 10, 91, FALSE),
('level_25',  'Level 25',  'Reach level 25.',  'milestone', '{"type":"level","value":25}',  200, 25, 92, FALSE),
('level_50',  'Level 50',  'Reach level 50.',  'milestone', '{"type":"level","value":50}',  350, 50, 93, FALSE),
('level_100', 'Level 100', 'Reach level 100.', 'milestone', '{"type":"level","value":100}', 500, 100,94, FALSE),
-- Social ---------------------------------------------------------------------
('friend_1',    'First Friend',    'Add your first friend.',       'social', '{"type":"friends","value":1}',        25,  5,  100, FALSE),
('friend_10',   'Well Connected',  'Add ten friends.',             'social', '{"type":"friends","value":10}',       100, 15, 101, FALSE),
('challenge_1', 'Challenger',      'Win your first challenge.',    'social', '{"type":"challenges_won","value":1}', 40,  5,  102, FALSE),
('challenge_10','Duelist',         'Win ten challenges.',          'social', '{"type":"challenges_won","value":10}',150, 20, 103, FALSE),
('league_promo','Promoted',        'Get promoted to a higher league.', 'social', '{"type":"league_promoted","value":1}', 100, 15, 104, FALSE),
('league_master','Master League',  'Reach the Master league.',     'social', '{"type":"league_reached","tier":"master"}', 400, 50, 105, FALSE),
-- Specialty course completion ------------------------------------------------
('course_essentials', 'Essentials Graduate', 'Complete Medical English Essentials.', 'specialty', '{"type":"course_completed","course_slug":"medical-english-essentials"}', 300, 40, 110, FALSE),
('course_emergency',  'Emergency English Certified', 'Complete the Emergency Medicine course.', 'specialty', '{"type":"course_completed","course_slug":"emergency-medicine-english"}', 300, 40, 111, FALSE),
('course_cardiology', 'Cardiology English Certified', 'Complete the Cardiology course.', 'specialty', '{"type":"course_completed","course_slug":"cardiology-english"}', 300, 40, 112, FALSE),
-- General / fun --------------------------------------------------------------
('early_bird',  'Early Bird',   'Study before 7 AM.',              'general', '{"type":"study_before_hour","value":7}',  30, 5, 120, TRUE),
('night_owl',   'Night Owl',    'Study after 11 PM.',              'general', '{"type":"study_after_hour","value":23}', 30, 5, 121, TRUE),
('weekend',     'Weekend Warrior','Study on both Saturday and Sunday.', 'general', '{"type":"weekend_study","value":1}', 40, 5, 122, FALSE),
('comeback',    'Comeback',     'Return after a 7-day break.',     'general', '{"type":"comeback","value":7}',          40, 5, 123, TRUE),
('xp_10000',    'XP Hunter',    'Earn 10,000 total XP.',           'milestone','{"type":"total_xp","value":10000}',      200,25, 124, FALSE)
ON CONFLICT (slug) DO NOTHING;
