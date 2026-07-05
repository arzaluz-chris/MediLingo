-- ============================================================================
-- MediLingo — Shop item catalog (Phase 4)
-- Rollback: DELETE FROM shop_items;
-- Items + gem prices from docs/GAMIFICATION.md § Shop.
-- ============================================================================

INSERT INTO shop_items (slug, title, description, category, price_gems, effect, is_available, max_owned, sort_order) VALUES
('streak_freeze', 'Streak Freeze', 'Protects your streak for one day of inactivity.', 'power_up', 200,
  '{"type":"streak_freeze","duration_days":1}', TRUE, 3, 0),
('heart_refill', 'Heart Refill', 'Instantly restores all your hearts.', 'consumable', 50,
  '{"type":"heart_refill"}', TRUE, NULL, 1),
('double_xp', 'Double XP (1 hour)', 'Earn 2x XP for 60 minutes.', 'power_up', 100,
  '{"type":"double_xp","duration_minutes":60}', TRUE, NULL, 2),
('bonus_lesson', 'Bonus Lesson Unlock', 'Unlock one premium lesson.', 'unlock', 150,
  '{"type":"unlock_lesson"}', TRUE, NULL, 3),
('avatar_scrubs', 'Scrubs Outfit', 'A cosmetic outfit for your avatar.', 'cosmetic', 300,
  '{"type":"cosmetic","slot":"outfit","id":"scrubs"}', TRUE, 1, 4),
('avatar_labcoat', 'Lab Coat', 'A cosmetic lab coat for your avatar.', 'cosmetic', 500,
  '{"type":"cosmetic","slot":"outfit","id":"labcoat"}', TRUE, 1, 5)
ON CONFLICT (slug) DO NOTHING;
