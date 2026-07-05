-- ============================================================================
-- MediLingo — Daily quest pool
-- Rollback: DELETE FROM daily_quests;
-- assign-daily-quests Edge Function draws 3 random active quests per user/day.
-- ============================================================================

INSERT INTO daily_quests (title, description, quest_type, target_value, xp_reward, gem_reward, is_active) VALUES
('Complete 1 Lesson',    'Finish one lesson today.',              'complete_lessons',  1,  25, 5,  TRUE),
('Complete 2 Lessons',   'Finish two lessons today.',             'complete_lessons',  2,  40, 8,  TRUE),
('Complete 3 Lessons',   'Finish three lessons today.',           'complete_lessons',  3,  60, 12, TRUE),
('Earn 50 XP',           'Earn 50 XP today.',                     'earn_xp',           50, 25, 5,  TRUE),
('Earn 100 XP',          'Earn 100 XP today.',                    'earn_xp',           100,40, 8,  TRUE),
('Earn 200 XP',          'Earn 200 XP today.',                    'earn_xp',           200,70, 15, TRUE),
('Learn 5 New Words',    'Master five new vocabulary terms.',     'learn_words',       5,  25, 5,  TRUE),
('Learn 10 New Words',   'Master ten new vocabulary terms.',      'learn_words',       10, 45, 10, TRUE),
('Perfect Lesson',       'Complete a lesson with no mistakes.',   'perfect_lesson',    1,  40, 8,  TRUE),
('Review 10 Flashcards', 'Review ten flashcards today.',          'review_flashcards', 10, 25, 5,  TRUE),
('Review 15 Flashcards', 'Review fifteen flashcards today.',      'review_flashcards', 15, 35, 7,  TRUE),
('Practice with AI',     'Complete one AI conversation.',         'ai_conversation',   1,  50, 10, TRUE),
('Keep the Streak',      'Earn any XP to extend your streak.',    'streak',            1,  20, 5,  TRUE)
ON CONFLICT DO NOTHING;
