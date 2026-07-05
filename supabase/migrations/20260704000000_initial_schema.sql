-- ============================================================================
-- MediLingo — Initial Schema
-- Rollback: DROP SCHEMA public CASCADE; then recreate. (Local dev only.)
-- Convention: snake_case, UUID PKs, TIMESTAMPTZ, RLS added in 20260704000001.
-- Tables are ordered so every foreign key references an already-created table.
-- ============================================================================

-- Reserved app schema exposed via the API (see config.toml api.schemas).
CREATE SCHEMA IF NOT EXISTS medilingo;

-- ----------------------------------------------------------------------------
-- USERS & AUTH
-- ----------------------------------------------------------------------------

CREATE TABLE profiles (
  id              UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email           TEXT NOT NULL,
  display_name    TEXT NOT NULL DEFAULT '',
  avatar_url      TEXT,
  role            TEXT NOT NULL DEFAULT 'student'
                    CHECK (role IN ('student', 'doctor', 'nurse', 'dentist', 'therapist', 'paramedic', 'assistant', 'other')),
  english_level   TEXT NOT NULL DEFAULT 'beginner'
                    CHECK (english_level IN ('beginner', 'intermediate', 'advanced')),
  primary_goal    TEXT NOT NULL DEFAULT 'general'
                    CHECK (primary_goal IN ('enarm', 'research', 'patient_care', 'remote_work', 'travel_medicine', 'usmle', 'general')),
  specialty       TEXT,
  daily_goal_xp   INT NOT NULL DEFAULT 50,
  locale          TEXT NOT NULL DEFAULT 'es-MX',
  timezone        TEXT NOT NULL DEFAULT 'America/Mexico_City',
  is_premium      BOOLEAN NOT NULL DEFAULT FALSE,
  premium_until   TIMESTAMPTZ,
  referral_code   TEXT UNIQUE,
  referred_by     UUID REFERENCES profiles(id),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_profiles_referral_code ON profiles(referral_code);
CREATE INDEX idx_profiles_role ON profiles(role);
CREATE INDEX idx_profiles_is_premium ON profiles(is_premium);

CREATE TABLE user_settings (
  user_id                 UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  notifications_enabled   BOOLEAN NOT NULL DEFAULT TRUE,
  reminder_time           TIME DEFAULT '09:00:00',
  sound_enabled           BOOLEAN NOT NULL DEFAULT TRUE,
  haptics_enabled         BOOLEAN NOT NULL DEFAULT TRUE,
  auto_play_audio         BOOLEAN NOT NULL DEFAULT TRUE,
  dark_mode               TEXT NOT NULL DEFAULT 'system'
                            CHECK (dark_mode IN ('system', 'light', 'dark')),
  playback_speed          REAL NOT NULL DEFAULT 1.0
                            CHECK (playback_speed IN (0.5, 0.75, 1.0, 1.25, 1.5)),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- CONTENT
-- ----------------------------------------------------------------------------

CREATE TABLE courses (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug            TEXT UNIQUE NOT NULL,
  title           TEXT NOT NULL,
  description     TEXT NOT NULL DEFAULT '',
  short_desc      TEXT NOT NULL DEFAULT '',
  icon_url        TEXT,
  color_hex       TEXT NOT NULL DEFAULT '#4F46E5',
  difficulty      TEXT NOT NULL DEFAULT 'beginner'
                    CHECK (difficulty IN ('beginner', 'intermediate', 'advanced', 'mixed')),
  category        TEXT NOT NULL DEFAULT 'general'
                    CHECK (category IN ('general', 'specialty', 'scenario', 'exam_prep', 'professional')),
  target_role     TEXT[],
  estimated_hours INT NOT NULL DEFAULT 10,
  sort_order      INT NOT NULL DEFAULT 0,
  is_premium      BOOLEAN NOT NULL DEFAULT FALSE,
  is_published    BOOLEAN NOT NULL DEFAULT FALSE,
  is_featured     BOOLEAN NOT NULL DEFAULT FALSE,
  published_at    TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_courses_published ON courses(is_published, sort_order);
CREATE INDEX idx_courses_category ON courses(category);
CREATE INDEX idx_courses_slug ON courses(slug);

CREATE TABLE modules (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id       UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  slug            TEXT NOT NULL,
  title           TEXT NOT NULL,
  description     TEXT NOT NULL DEFAULT '',
  icon_url        TEXT,
  sort_order      INT NOT NULL DEFAULT 0,
  is_published    BOOLEAN NOT NULL DEFAULT FALSE,
  unlock_after    UUID REFERENCES modules(id),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(course_id, slug)
);
CREATE INDEX idx_modules_course ON modules(course_id, sort_order);

CREATE TABLE lessons (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id         UUID NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
  slug              TEXT NOT NULL,
  title             TEXT NOT NULL,
  description       TEXT NOT NULL DEFAULT '',
  lesson_type       TEXT NOT NULL DEFAULT 'standard'
                      CHECK (lesson_type IN ('standard', 'review', 'clinical_case', 'listening', 'pronunciation', 'writing', 'conversation', 'test')),
  difficulty        TEXT NOT NULL DEFAULT 'beginner'
                      CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
  estimated_minutes INT NOT NULL DEFAULT 5,
  xp_reward         INT NOT NULL DEFAULT 50,
  sort_order        INT NOT NULL DEFAULT 0,
  is_premium        BOOLEAN NOT NULL DEFAULT FALSE,
  is_published      BOOLEAN NOT NULL DEFAULT FALSE,
  unlock_after      UUID REFERENCES lessons(id),
  intro_text        TEXT,
  completion_text   TEXT,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(module_id, slug)
);
CREATE INDEX idx_lessons_module ON lessons(module_id, sort_order);
CREATE INDEX idx_lessons_type ON lessons(lesson_type);

CREATE TABLE exercises (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id       UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  exercise_type   TEXT NOT NULL
                    CHECK (exercise_type IN (
                      'multiple_choice', 'image_selection', 'listening', 'pronunciation',
                      'fill_in_blank', 'sentence_ordering', 'translation', 'flashcard',
                      'matching', 'typing', 'role_playing', 'ai_conversation',
                      'clinical_case', 'patient_interview', 'memory_game'
                    )),
  prompt          TEXT NOT NULL,
  prompt_audio_url TEXT,
  prompt_image_url TEXT,
  correct_answer  TEXT,
  explanation     TEXT,
  explanation_es  TEXT,
  hint            TEXT,
  difficulty      TEXT NOT NULL DEFAULT 'beginner'
                    CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
  xp_reward       INT NOT NULL DEFAULT 10,
  sort_order      INT NOT NULL DEFAULT 0,
  metadata        JSONB NOT NULL DEFAULT '{}',
  is_published    BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_exercises_lesson ON exercises(lesson_id, sort_order);
CREATE INDEX idx_exercises_type ON exercises(exercise_type);

CREATE TABLE exercise_options (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exercise_id     UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  option_text     TEXT NOT NULL,
  option_audio_url TEXT,
  option_image_url TEXT,
  is_correct      BOOLEAN NOT NULL DEFAULT FALSE,
  sort_order      INT NOT NULL DEFAULT 0,
  match_pair_id   TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_exercise_options_exercise ON exercise_options(exercise_id, sort_order);

CREATE TABLE vocabulary (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  word            TEXT NOT NULL,
  phonetic        TEXT,
  pronunciation_url TEXT,
  translation_es  TEXT NOT NULL,
  definition_en   TEXT NOT NULL,
  definition_es   TEXT,
  example_en      TEXT NOT NULL,
  example_es      TEXT,
  etymology       TEXT,
  category        TEXT NOT NULL DEFAULT 'general'
                    CHECK (category IN (
                      'general', 'anatomy', 'physiology', 'pathology', 'pharmacology',
                      'surgery', 'emergency', 'cardiology', 'pediatrics', 'ob_gyn',
                      'psychiatry', 'dermatology', 'radiology', 'laboratory',
                      'nursing', 'abbreviation', 'latin_abbreviation', 'billing',
                      'insurance', 'equipment', 'procedures'
                    )),
  difficulty      TEXT NOT NULL DEFAULT 'beginner'
                    CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
  tags            TEXT[] DEFAULT '{}',
  related_words   UUID[] DEFAULT '{}',
  is_published    BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_vocabulary_category ON vocabulary(category);
CREATE INDEX idx_vocabulary_difficulty ON vocabulary(difficulty);
CREATE INDEX idx_vocabulary_word ON vocabulary(word);
CREATE INDEX idx_vocabulary_tags ON vocabulary USING GIN(tags);

CREATE TABLE lesson_vocabulary (
  lesson_id     UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  vocabulary_id UUID NOT NULL REFERENCES vocabulary(id) ON DELETE CASCADE,
  sort_order    INT NOT NULL DEFAULT 0,
  PRIMARY KEY (lesson_id, vocabulary_id)
);

CREATE TABLE audio_clips (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title           TEXT NOT NULL,
  description     TEXT,
  file_url        TEXT NOT NULL,
  duration_ms     INT NOT NULL DEFAULT 0,
  transcript_en   TEXT,
  transcript_es   TEXT,
  speaker         TEXT NOT NULL DEFAULT 'narrator'
                    CHECK (speaker IN ('narrator', 'patient', 'physician', 'nurse', 'receptionist', 'family', 'paramedic', 'operator')),
  accent          TEXT NOT NULL DEFAULT 'american'
                    CHECK (accent IN ('american', 'british', 'neutral')),
  speed           TEXT NOT NULL DEFAULT 'normal'
                    CHECK (speed IN ('slow', 'normal', 'fast')),
  scenario        TEXT,
  tags            TEXT[] DEFAULT '{}',
  is_published    BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_audio_clips_speaker ON audio_clips(speaker);
CREATE INDEX idx_audio_clips_scenario ON audio_clips(scenario);

-- user_onboarding references courses, so it is defined after the content tables.
CREATE TABLE user_onboarding (
  user_id             UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  completed           BOOLEAN NOT NULL DEFAULT FALSE,
  step_completed      INT NOT NULL DEFAULT 0,
  selected_course_id  UUID REFERENCES courses(id),
  completed_at        TIMESTAMPTZ,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- PROGRESS & LEARNING
-- ----------------------------------------------------------------------------

CREATE TABLE user_progress (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  entity_type     TEXT NOT NULL CHECK (entity_type IN ('course', 'module', 'lesson')),
  entity_id       UUID NOT NULL,
  status          TEXT NOT NULL DEFAULT 'not_started'
                    CHECK (status IN ('not_started', 'in_progress', 'completed')),
  score           REAL,
  xp_earned       INT NOT NULL DEFAULT 0,
  attempts        INT NOT NULL DEFAULT 0,
  best_score      REAL,
  started_at      TIMESTAMPTZ,
  completed_at    TIMESTAMPTZ,
  last_active_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, entity_type, entity_id)
);
CREATE INDEX idx_user_progress_user ON user_progress(user_id, entity_type);
CREATE INDEX idx_user_progress_entity ON user_progress(entity_type, entity_id);

CREATE TABLE exercise_attempts (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  exercise_id     UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  lesson_id       UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  user_answer     TEXT,
  is_correct      BOOLEAN NOT NULL,
  time_spent_ms   INT NOT NULL DEFAULT 0,
  xp_earned       INT NOT NULL DEFAULT 0,
  hearts_lost     INT NOT NULL DEFAULT 0,
  metadata        JSONB DEFAULT '{}',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_exercise_attempts_user ON exercise_attempts(user_id, created_at DESC);
CREATE INDEX idx_exercise_attempts_exercise ON exercise_attempts(exercise_id);
CREATE INDEX idx_exercise_attempts_lesson ON exercise_attempts(user_id, lesson_id);

CREATE TABLE vocabulary_mastery (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  vocabulary_id     UUID NOT NULL REFERENCES vocabulary(id) ON DELETE CASCADE,
  mastery_level     INT NOT NULL DEFAULT 0,
  ease_factor       REAL NOT NULL DEFAULT 2.5,
  interval_days     INT NOT NULL DEFAULT 0,
  repetitions       INT NOT NULL DEFAULT 0,
  correct_count     INT NOT NULL DEFAULT 0,
  incorrect_count   INT NOT NULL DEFAULT 0,
  last_reviewed_at  TIMESTAMPTZ,
  next_review_at    TIMESTAMPTZ,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, vocabulary_id)
);
CREATE INDEX idx_vocab_mastery_user_review ON vocabulary_mastery(user_id, next_review_at);
CREATE INDEX idx_vocab_mastery_user_level ON vocabulary_mastery(user_id, mastery_level);

CREATE TABLE flashcard_reviews (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  vocabulary_id   UUID NOT NULL REFERENCES vocabulary(id) ON DELETE CASCADE,
  quality         INT NOT NULL CHECK (quality >= 0 AND quality <= 5),
  time_spent_ms   INT NOT NULL DEFAULT 0,
  previous_interval INT NOT NULL DEFAULT 0,
  new_interval    INT NOT NULL DEFAULT 0,
  previous_ease   REAL NOT NULL DEFAULT 2.5,
  new_ease        REAL NOT NULL DEFAULT 2.5,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_flashcard_reviews_user ON flashcard_reviews(user_id, created_at DESC);

-- ----------------------------------------------------------------------------
-- GAMIFICATION
-- ----------------------------------------------------------------------------

CREATE TABLE user_stats (
  user_id             UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  total_xp            BIGINT NOT NULL DEFAULT 0,
  level               INT NOT NULL DEFAULT 1,
  current_streak      INT NOT NULL DEFAULT 0,
  longest_streak      INT NOT NULL DEFAULT 0,
  streak_last_date    DATE,
  streak_freeze_count INT NOT NULL DEFAULT 0,
  hearts              INT NOT NULL DEFAULT 5,
  hearts_max          INT NOT NULL DEFAULT 5,
  hearts_last_refill  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  gems                BIGINT NOT NULL DEFAULT 0,
  coins               BIGINT NOT NULL DEFAULT 0,
  lessons_completed   INT NOT NULL DEFAULT 0,
  exercises_completed INT NOT NULL DEFAULT 0,
  words_learned       INT NOT NULL DEFAULT 0,
  time_spent_minutes  INT NOT NULL DEFAULT 0,
  perfect_lessons     INT NOT NULL DEFAULT 0,
  clinical_cases_done INT NOT NULL DEFAULT 0,
  ai_conversations    INT NOT NULL DEFAULT 0,
  current_league      TEXT NOT NULL DEFAULT 'bronze'
                        CHECK (current_league IN ('bronze', 'silver', 'gold', 'diamond', 'master')),
  weekly_xp           INT NOT NULL DEFAULT 0,
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE achievements (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug            TEXT UNIQUE NOT NULL,
  title           TEXT NOT NULL,
  description     TEXT NOT NULL,
  icon_url        TEXT,
  category        TEXT NOT NULL DEFAULT 'general'
                    CHECK (category IN ('general', 'streak', 'learning', 'social', 'clinical', 'specialty', 'milestone')),
  requirement     JSONB NOT NULL,
  xp_reward       INT NOT NULL DEFAULT 0,
  gem_reward      INT NOT NULL DEFAULT 0,
  sort_order      INT NOT NULL DEFAULT 0,
  is_secret       BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE user_achievements (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  achievement_id  UUID NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
  unlocked_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  notified        BOOLEAN NOT NULL DEFAULT FALSE,
  UNIQUE(user_id, achievement_id)
);
CREATE INDEX idx_user_achievements_user ON user_achievements(user_id);

CREATE TABLE daily_quests (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title           TEXT NOT NULL,
  description     TEXT NOT NULL,
  quest_type      TEXT NOT NULL
                    CHECK (quest_type IN ('complete_lessons', 'earn_xp', 'learn_words', 'perfect_lesson', 'review_flashcards', 'ai_conversation', 'streak')),
  target_value    INT NOT NULL,
  xp_reward       INT NOT NULL DEFAULT 25,
  gem_reward      INT NOT NULL DEFAULT 5,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE user_daily_quests (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  quest_id        UUID NOT NULL REFERENCES daily_quests(id) ON DELETE CASCADE,
  quest_date      DATE NOT NULL DEFAULT CURRENT_DATE,
  current_value   INT NOT NULL DEFAULT 0,
  is_completed    BOOLEAN NOT NULL DEFAULT FALSE,
  completed_at    TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, quest_id, quest_date)
);
CREATE INDEX idx_user_daily_quests_date ON user_daily_quests(user_id, quest_date);

CREATE TABLE leagues (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tier            TEXT NOT NULL CHECK (tier IN ('bronze', 'silver', 'gold', 'diamond', 'master')),
  week_start      DATE NOT NULL,
  week_end        DATE NOT NULL,
  max_members     INT NOT NULL DEFAULT 30,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(tier, week_start, id)
);
CREATE INDEX idx_leagues_active ON leagues(is_active, tier, week_start);

CREATE TABLE league_members (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  league_id       UUID NOT NULL REFERENCES leagues(id) ON DELETE CASCADE,
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  weekly_xp       INT NOT NULL DEFAULT 0,
  rank            INT,
  promoted        BOOLEAN NOT NULL DEFAULT FALSE,
  demoted         BOOLEAN NOT NULL DEFAULT FALSE,
  UNIQUE(league_id, user_id)
);
CREATE INDEX idx_league_members_league ON league_members(league_id, weekly_xp DESC);
CREATE INDEX idx_league_members_user ON league_members(user_id);

-- ----------------------------------------------------------------------------
-- SOCIAL
-- ----------------------------------------------------------------------------

CREATE TABLE friendships (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  friend_id       UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  status          TEXT NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending', 'accepted', 'blocked')),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  accepted_at     TIMESTAMPTZ,
  UNIQUE(user_id, friend_id),
  CHECK (user_id != friend_id)
);
CREATE INDEX idx_friendships_user ON friendships(user_id, status);
CREATE INDEX idx_friendships_friend ON friendships(friend_id, status);

CREATE TABLE challenges (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  challenger_id   UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  challenged_id   UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  lesson_id       UUID REFERENCES lessons(id),
  status          TEXT NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending', 'accepted', 'in_progress', 'completed', 'expired', 'declined')),
  challenger_score INT DEFAULT 0,
  challenged_score INT DEFAULT 0,
  winner_id       UUID REFERENCES profiles(id),
  xp_reward       INT NOT NULL DEFAULT 40,
  expires_at      TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '24 hours'),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at    TIMESTAMPTZ
);
CREATE INDEX idx_challenges_challenger ON challenges(challenger_id, status);
CREATE INDEX idx_challenges_challenged ON challenges(challenged_id, status);

-- ----------------------------------------------------------------------------
-- AI & CONVERSATIONS
-- ----------------------------------------------------------------------------

CREATE TABLE ai_conversations (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  conversation_type TEXT NOT NULL DEFAULT 'patient_consultation'
                    CHECK (conversation_type IN (
                      'patient_consultation', 'phone_triage', 'er_scenario',
                      'medical_interview', 'colleague_discussion', 'free_practice',
                      'clinical_case'
                    )),
  scenario        JSONB NOT NULL DEFAULT '{}',
  ai_provider     TEXT NOT NULL DEFAULT 'gemini',
  ai_model        TEXT NOT NULL DEFAULT 'gemini-2.0-flash',
  status          TEXT NOT NULL DEFAULT 'active'
                    CHECK (status IN ('active', 'completed', 'abandoned')),
  score           REAL,
  feedback        JSONB,
  duration_ms     INT DEFAULT 0,
  message_count   INT DEFAULT 0,
  xp_earned       INT NOT NULL DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at    TIMESTAMPTZ
);
CREATE INDEX idx_ai_conversations_user ON ai_conversations(user_id, created_at DESC);

CREATE TABLE ai_messages (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES ai_conversations(id) ON DELETE CASCADE,
  role            TEXT NOT NULL CHECK (role IN ('system', 'user', 'assistant')),
  content         TEXT NOT NULL,
  audio_url       TEXT,
  pronunciation_score REAL,
  grammar_score   REAL,
  vocabulary_score REAL,
  fluency_score   REAL,
  corrections     JSONB,
  tokens_used     INT DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_ai_messages_conversation ON ai_messages(conversation_id, created_at);

-- ----------------------------------------------------------------------------
-- COMMERCE
-- ----------------------------------------------------------------------------

CREATE TABLE subscriptions (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id             UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  platform            TEXT NOT NULL CHECK (platform IN ('ios', 'android', 'web', 'admin')),
  product_id          TEXT NOT NULL,
  original_transaction_id TEXT,
  status              TEXT NOT NULL DEFAULT 'active'
                        CHECK (status IN ('active', 'expired', 'cancelled', 'grace_period', 'billing_retry')),
  plan_type           TEXT NOT NULL DEFAULT 'monthly'
                        CHECK (plan_type IN ('monthly', 'annual', 'lifetime')),
  price_usd           REAL,
  currency            TEXT DEFAULT 'USD',
  starts_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at          TIMESTAMPTZ,
  cancelled_at        TIMESTAMPTZ,
  is_trial            BOOLEAN NOT NULL DEFAULT FALSE,
  trial_ends_at       TIMESTAMPTZ,
  revenue_cat_id      TEXT,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_subscriptions_user ON subscriptions(user_id, status);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);

CREATE TABLE shop_items (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug            TEXT UNIQUE NOT NULL,
  title           TEXT NOT NULL,
  description     TEXT NOT NULL,
  category        TEXT NOT NULL
                    CHECK (category IN ('consumable', 'cosmetic', 'power_up', 'unlock')),
  price_gems      INT NOT NULL DEFAULT 0,
  price_coins     INT NOT NULL DEFAULT 0,
  icon_url        TEXT,
  effect          JSONB NOT NULL DEFAULT '{}',
  is_available    BOOLEAN NOT NULL DEFAULT TRUE,
  max_owned       INT DEFAULT NULL,
  sort_order      INT NOT NULL DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE user_inventory (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  item_id         UUID NOT NULL REFERENCES shop_items(id) ON DELETE CASCADE,
  quantity        INT NOT NULL DEFAULT 1,
  is_equipped     BOOLEAN NOT NULL DEFAULT FALSE,
  acquired_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_user_inventory_user ON user_inventory(user_id);

-- ----------------------------------------------------------------------------
-- ANALYTICS
-- ----------------------------------------------------------------------------

CREATE TABLE analytics_events (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID REFERENCES profiles(id) ON DELETE SET NULL,
  event_name      TEXT NOT NULL,
  event_data      JSONB NOT NULL DEFAULT '{}',
  session_id      TEXT,
  platform        TEXT DEFAULT 'ios',
  app_version     TEXT,
  device_model    TEXT,
  os_version      TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_analytics_events_user ON analytics_events(user_id, created_at DESC);
CREATE INDEX idx_analytics_events_name ON analytics_events(event_name, created_at DESC);
CREATE INDEX idx_analytics_events_date ON analytics_events(created_at DESC);

CREATE TABLE content_ratings (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  entity_type     TEXT NOT NULL CHECK (entity_type IN ('lesson', 'exercise', 'course')),
  entity_id       UUID NOT NULL,
  rating          INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
  feedback        TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, entity_type, entity_id)
);

-- ----------------------------------------------------------------------------
-- ADMIN (CLAUDE-admin.md) — CMS access control
-- ----------------------------------------------------------------------------

CREATE TABLE admin_users (
  user_id         UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email           TEXT NOT NULL,
  role            TEXT NOT NULL DEFAULT 'editor'
                    CHECK (role IN ('editor', 'admin', 'super_admin')),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- STORAGE BUCKETS
-- ----------------------------------------------------------------------------

INSERT INTO storage.buckets (id, name, public) VALUES
  ('audio', 'audio', TRUE),
  ('images', 'images', TRUE),
  ('animations', 'animations', TRUE),
  ('user-recordings', 'user-recordings', FALSE),
  ('certificates', 'certificates', FALSE)
ON CONFLICT (id) DO NOTHING;
