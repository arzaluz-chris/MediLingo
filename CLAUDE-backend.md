# CLAUDE-backend.md — MediLingo Backend & Database Specification

> Full spec: Supabase backend, PostgreSQL schema, Row Level Security policies, Edge Functions, Storage, API contracts.

---

## Table of Contents

1. [Supabase Project Setup](#supabase-project-setup)
2. [Database Schema](#database-schema)
3. [Row Level Security (RLS)](#row-level-security-rls)
4. [Database Functions & Triggers](#database-functions--triggers)
5. [Edge Functions](#edge-functions)
6. [Storage Buckets](#storage-buckets)
7. [Realtime Subscriptions](#realtime-subscriptions)
8. [Authentication](#authentication)
9. [API Contracts](#api-contracts)
10. [Migration Strategy](#migration-strategy)
11. [Performance & Indexing](#performance--indexing)
12. [Monitoring & Observability](#monitoring--observability)

---

## Supabase Project Setup

### Initial Configuration (`supabase/config.toml`)

```toml
[project]
id = "medilingo"

[api]
port = 54321
schemas = ["public", "medilingo"]
extra_search_path = ["public", "extensions"]

[db]
port = 54322
major_version = 15

[auth]
site_url = "com.medilingo.app://"
additional_redirect_urls = ["com.medilingo.app://callback", "https://medilingo.app/auth/callback"]

[auth.external.apple]
enabled = true

[auth.external.google]
enabled = true

[storage]
file_size_limit = "50MiB"
```

### Supabase Services Used

| Service | Usage |
|---------|-------|
| **Auth** | User registration, login (Apple, Google, Email), JWT management |
| **Database** | PostgreSQL 15+ — all app data |
| **Storage** | Audio files, images, illustrations, user avatars |
| **Edge Functions** | AI proxy, pronunciation eval, leaderboard calc, analytics |
| **Realtime** | League updates, friend activity, live challenges |
| **Row Level Security** | Data access control — enabled on ALL tables |

---

## Database Schema

### Schema Overview (30+ Tables)

```
┌─────────────────────────────────────────────────────────────┐
│                    USERS & AUTH                              │
│  profiles · user_settings · user_onboarding                 │
├─────────────────────────────────────────────────────────────┤
│                    CONTENT                                   │
│  courses · modules · lessons · exercises · vocabulary        │
│  exercise_options · audio_clips · illustrations              │
├─────────────────────────────────────────────────────────────┤
│                    PROGRESS                                  │
│  user_progress · lesson_completions · exercise_attempts      │
│  vocabulary_mastery · flashcard_reviews                      │
├─────────────────────────────────────────────────────────────┤
│                    GAMIFICATION                              │
│  user_stats · achievements · user_achievements               │
│  daily_quests · user_daily_quests · leagues                  │
│  league_members · leaderboard_snapshots                      │
├─────────────────────────────────────────────────────────────┤
│                    SOCIAL                                     │
│  friendships · challenges · challenge_results                │
├─────────────────────────────────────────────────────────────┤
│                    AI & CONVERSATIONS                        │
│  ai_conversations · ai_messages                              │
├─────────────────────────────────────────────────────────────┤
│                    COMMERCE                                   │
│  subscriptions · transactions · shop_items · user_inventory  │
├─────────────────────────────────────────────────────────────┤
│                    ANALYTICS                                  │
│  analytics_events · content_ratings                          │
└─────────────────────────────────────────────────────────────┘
```

---

### 1. Users & Auth

#### `profiles`
Extends Supabase `auth.users`. Created via trigger on signup.

```sql
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
  specialty       TEXT,                     -- nullable, e.g., 'cardiology', 'emergency'
  daily_goal_xp   INT NOT NULL DEFAULT 50,  -- daily XP target (50, 100, 150, 200+)
  locale          TEXT NOT NULL DEFAULT 'es-MX',
  timezone        TEXT NOT NULL DEFAULT 'America/Mexico_City',
  is_premium      BOOLEAN NOT NULL DEFAULT FALSE,
  premium_until   TIMESTAMPTZ,
  referral_code   TEXT UNIQUE,
  referred_by     UUID REFERENCES profiles(id),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_profiles_referral_code ON profiles(referral_code);
CREATE INDEX idx_profiles_role ON profiles(role);
CREATE INDEX idx_profiles_is_premium ON profiles(is_premium);
```

#### `user_settings`

```sql
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
```

#### `user_onboarding`

```sql
CREATE TABLE user_onboarding (
  user_id             UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  completed           BOOLEAN NOT NULL DEFAULT FALSE,
  step_completed      INT NOT NULL DEFAULT 0,  -- 0-5 onboarding steps
  selected_course_id  UUID REFERENCES courses(id),
  completed_at        TIMESTAMPTZ,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

---

### 2. Content

#### `courses`

```sql
CREATE TABLE courses (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug            TEXT UNIQUE NOT NULL,       -- e.g., 'medical-english-essentials'
  title           TEXT NOT NULL,              -- e.g., 'Medical English Essentials'
  description     TEXT NOT NULL DEFAULT '',
  short_desc      TEXT NOT NULL DEFAULT '',   -- one-liner for cards
  icon_url        TEXT,
  color_hex       TEXT NOT NULL DEFAULT '#4F46E5',  -- brand color for this course
  difficulty      TEXT NOT NULL DEFAULT 'beginner'
                    CHECK (difficulty IN ('beginner', 'intermediate', 'advanced', 'mixed')),
  category        TEXT NOT NULL DEFAULT 'general'
                    CHECK (category IN ('general', 'specialty', 'scenario', 'exam_prep', 'professional')),
  target_role     TEXT[],                     -- e.g., {'student', 'doctor', 'nurse'}
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
```

#### `modules`

```sql
CREATE TABLE modules (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id       UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  slug            TEXT NOT NULL,
  title           TEXT NOT NULL,
  description     TEXT NOT NULL DEFAULT '',
  icon_url        TEXT,
  sort_order      INT NOT NULL DEFAULT 0,
  is_published    BOOLEAN NOT NULL DEFAULT FALSE,
  unlock_after    UUID REFERENCES modules(id),  -- prerequisite module
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(course_id, slug)
);

CREATE INDEX idx_modules_course ON modules(course_id, sort_order);
```

#### `lessons`

```sql
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
  unlock_after      UUID REFERENCES lessons(id),  -- prerequisite lesson
  intro_text        TEXT,                          -- shown before lesson starts
  completion_text   TEXT,                          -- shown after lesson ends
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(module_id, slug)
);

CREATE INDEX idx_lessons_module ON lessons(module_id, sort_order);
CREATE INDEX idx_lessons_type ON lessons(lesson_type);
```

#### `exercises`

```sql
CREATE TABLE exercises (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id       UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  exercise_type   TEXT NOT NULL
                    CHECK (exercise_type IN (
                      'multiple_choice',
                      'image_selection',
                      'listening',
                      'pronunciation',
                      'fill_in_blank',
                      'sentence_ordering',
                      'translation',
                      'flashcard',
                      'matching',
                      'typing',
                      'role_playing',
                      'ai_conversation',
                      'clinical_case',
                      'patient_interview',
                      'memory_game'
                    )),
  prompt          TEXT NOT NULL,                  -- main question/instruction text
  prompt_audio_url TEXT,                          -- optional audio for the prompt
  prompt_image_url TEXT,                          -- optional image for the prompt
  correct_answer  TEXT,                           -- correct answer (for simple types)
  explanation     TEXT,                           -- shown after answering
  explanation_es  TEXT,                           -- explanation in Spanish
  hint            TEXT,                           -- optional hint
  difficulty      TEXT NOT NULL DEFAULT 'beginner'
                    CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
  xp_reward       INT NOT NULL DEFAULT 10,
  sort_order      INT NOT NULL DEFAULT 0,
  metadata        JSONB NOT NULL DEFAULT '{}',   -- type-specific config (see CLAUDE-content.md)
  is_published    BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_exercises_lesson ON exercises(lesson_id, sort_order);
CREATE INDEX idx_exercises_type ON exercises(exercise_type);
```

#### `exercise_options`
For multiple choice, matching, image selection, etc.

```sql
CREATE TABLE exercise_options (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exercise_id     UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  option_text     TEXT NOT NULL,
  option_audio_url TEXT,
  option_image_url TEXT,
  is_correct      BOOLEAN NOT NULL DEFAULT FALSE,
  sort_order      INT NOT NULL DEFAULT 0,
  match_pair_id   TEXT,       -- for matching exercises: groups paired items
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_exercise_options_exercise ON exercise_options(exercise_id, sort_order);
```

#### `vocabulary`

```sql
CREATE TABLE vocabulary (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  word            TEXT NOT NULL,
  phonetic        TEXT,                       -- IPA pronunciation, e.g., /dɪspˈniːə/
  pronunciation_url TEXT,                     -- audio file URL
  translation_es  TEXT NOT NULL,              -- Spanish translation
  definition_en   TEXT NOT NULL,              -- English definition
  definition_es   TEXT,                       -- Spanish definition
  example_en      TEXT NOT NULL,              -- Example sentence in English
  example_es      TEXT,                       -- Example sentence in Spanish
  etymology       TEXT,                       -- Latin/Greek roots explanation
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
  tags            TEXT[] DEFAULT '{}',        -- e.g., {'enarm', 'usmle', 'icu'}
  related_words   UUID[] DEFAULT '{}',        -- references to other vocabulary IDs
  is_published    BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_vocabulary_category ON vocabulary(category);
CREATE INDEX idx_vocabulary_difficulty ON vocabulary(difficulty);
CREATE INDEX idx_vocabulary_word ON vocabulary(word);
CREATE INDEX idx_vocabulary_tags ON vocabulary USING GIN(tags);
```

#### `lesson_vocabulary`
Many-to-many, lessons ↔ vocabulary.

```sql
CREATE TABLE lesson_vocabulary (
  lesson_id     UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  vocabulary_id UUID NOT NULL REFERENCES vocabulary(id) ON DELETE CASCADE,
  sort_order    INT NOT NULL DEFAULT 0,
  PRIMARY KEY (lesson_id, vocabulary_id)
);
```

#### `audio_clips`

```sql
CREATE TABLE audio_clips (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title           TEXT NOT NULL,
  description     TEXT,
  file_url        TEXT NOT NULL,
  duration_ms     INT NOT NULL DEFAULT 0,
  transcript_en   TEXT,                       -- full transcript in English
  transcript_es   TEXT,                       -- full transcript in Spanish
  speaker         TEXT NOT NULL DEFAULT 'narrator'
                    CHECK (speaker IN ('narrator', 'patient', 'physician', 'nurse', 'receptionist', 'family', 'paramedic', 'operator')),
  accent          TEXT NOT NULL DEFAULT 'american'
                    CHECK (accent IN ('american', 'british', 'neutral')),
  speed           TEXT NOT NULL DEFAULT 'normal'
                    CHECK (speed IN ('slow', 'normal', 'fast')),
  scenario        TEXT,                       -- e.g., 'emergency_room', 'phone_call'
  tags            TEXT[] DEFAULT '{}',
  is_published    BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audio_clips_speaker ON audio_clips(speaker);
CREATE INDEX idx_audio_clips_scenario ON audio_clips(scenario);
```

---

### 3. Progress & Learning

#### `user_progress`
Tracks courses/modules/lessons user started/completed.

```sql
CREATE TABLE user_progress (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  entity_type     TEXT NOT NULL
                    CHECK (entity_type IN ('course', 'module', 'lesson')),
  entity_id       UUID NOT NULL,              -- references courses.id, modules.id, or lessons.id
  status          TEXT NOT NULL DEFAULT 'not_started'
                    CHECK (status IN ('not_started', 'in_progress', 'completed')),
  score           REAL,                       -- 0.0 to 1.0 (percentage correct)
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
```

#### `exercise_attempts`

```sql
CREATE TABLE exercise_attempts (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  exercise_id     UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  lesson_id       UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  user_answer     TEXT,                       -- what the user answered
  is_correct      BOOLEAN NOT NULL,
  time_spent_ms   INT NOT NULL DEFAULT 0,     -- time to answer in milliseconds
  xp_earned       INT NOT NULL DEFAULT 0,
  hearts_lost     INT NOT NULL DEFAULT 0,     -- 0 if correct, 1 if wrong
  metadata        JSONB DEFAULT '{}',         -- type-specific data (e.g., pronunciation score)
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_exercise_attempts_user ON exercise_attempts(user_id, created_at DESC);
CREATE INDEX idx_exercise_attempts_exercise ON exercise_attempts(exercise_id);
CREATE INDEX idx_exercise_attempts_lesson ON exercise_attempts(user_id, lesson_id);
```

#### `vocabulary_mastery`
Tracks how well user knows each word (spaced repetition).

```sql
CREATE TABLE vocabulary_mastery (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  vocabulary_id     UUID NOT NULL REFERENCES vocabulary(id) ON DELETE CASCADE,
  mastery_level     INT NOT NULL DEFAULT 0,     -- 0 (new) to 5 (mastered)
  ease_factor       REAL NOT NULL DEFAULT 2.5,  -- SM-2 ease factor
  interval_days     INT NOT NULL DEFAULT 0,     -- days until next review
  repetitions       INT NOT NULL DEFAULT 0,     -- consecutive correct reviews
  correct_count     INT NOT NULL DEFAULT 0,
  incorrect_count   INT NOT NULL DEFAULT 0,
  last_reviewed_at  TIMESTAMPTZ,
  next_review_at    TIMESTAMPTZ,                -- when to show again
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, vocabulary_id)
);

CREATE INDEX idx_vocab_mastery_user_review ON vocabulary_mastery(user_id, next_review_at);
CREATE INDEX idx_vocab_mastery_user_level ON vocabulary_mastery(user_id, mastery_level);
```

#### `flashcard_reviews`
Log of individual flashcard review sessions.

```sql
CREATE TABLE flashcard_reviews (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  vocabulary_id   UUID NOT NULL REFERENCES vocabulary(id) ON DELETE CASCADE,
  quality         INT NOT NULL CHECK (quality >= 0 AND quality <= 5),  -- SM-2 quality (0=blackout, 5=perfect)
  time_spent_ms   INT NOT NULL DEFAULT 0,
  previous_interval INT NOT NULL DEFAULT 0,
  new_interval    INT NOT NULL DEFAULT 0,
  previous_ease   REAL NOT NULL DEFAULT 2.5,
  new_ease        REAL NOT NULL DEFAULT 2.5,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_flashcard_reviews_user ON flashcard_reviews(user_id, created_at DESC);
```

---

### 4. Gamification

#### `user_stats`

```sql
CREATE TABLE user_stats (
  user_id             UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  total_xp            BIGINT NOT NULL DEFAULT 0,
  level               INT NOT NULL DEFAULT 1,
  current_streak      INT NOT NULL DEFAULT 0,
  longest_streak      INT NOT NULL DEFAULT 0,
  streak_last_date    DATE,                     -- last date user earned XP
  streak_freeze_count INT NOT NULL DEFAULT 0,   -- available streak freezes
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
  weekly_xp           INT NOT NULL DEFAULT 0,   -- reset weekly for leagues
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

#### `achievements`

```sql
CREATE TABLE achievements (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug            TEXT UNIQUE NOT NULL,
  title           TEXT NOT NULL,
  description     TEXT NOT NULL,
  icon_url        TEXT,
  category        TEXT NOT NULL DEFAULT 'general'
                    CHECK (category IN ('general', 'streak', 'learning', 'social', 'clinical', 'specialty', 'milestone')),
  requirement     JSONB NOT NULL,             -- e.g., {"type": "streak", "value": 7}
  xp_reward       INT NOT NULL DEFAULT 0,
  gem_reward      INT NOT NULL DEFAULT 0,
  sort_order      INT NOT NULL DEFAULT 0,
  is_secret       BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Example requirements:
-- {"type": "streak", "value": 7}
-- {"type": "lessons_completed", "value": 100}
-- {"type": "words_learned", "value": 500}
-- {"type": "course_completed", "course_slug": "emergency-medicine-english"}
-- {"type": "perfect_lessons", "value": 10}
-- {"type": "clinical_cases", "value": 5}
```

#### `user_achievements`

```sql
CREATE TABLE user_achievements (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  achievement_id  UUID NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
  unlocked_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  notified        BOOLEAN NOT NULL DEFAULT FALSE,
  UNIQUE(user_id, achievement_id)
);

CREATE INDEX idx_user_achievements_user ON user_achievements(user_id);
```

#### `daily_quests`

```sql
CREATE TABLE daily_quests (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title           TEXT NOT NULL,
  description     TEXT NOT NULL,
  quest_type      TEXT NOT NULL
                    CHECK (quest_type IN ('complete_lessons', 'earn_xp', 'learn_words', 'perfect_lesson', 'review_flashcards', 'ai_conversation', 'streak')),
  target_value    INT NOT NULL,               -- e.g., 3 lessons, 100 XP, 10 words
  xp_reward       INT NOT NULL DEFAULT 25,
  gem_reward      INT NOT NULL DEFAULT 5,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

#### `user_daily_quests`

```sql
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
```

#### `leagues`

```sql
CREATE TABLE leagues (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tier            TEXT NOT NULL
                    CHECK (tier IN ('bronze', 'silver', 'gold', 'diamond', 'master')),
  week_start      DATE NOT NULL,              -- Monday of the league week
  week_end        DATE NOT NULL,              -- Sunday of the league week
  max_members     INT NOT NULL DEFAULT 30,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(tier, week_start, id)
);

CREATE INDEX idx_leagues_active ON leagues(is_active, tier, week_start);
```

#### `league_members`

```sql
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
```

---

### 5. Social

#### `friendships`

```sql
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
```

#### `challenges`

```sql
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
```

---

### 6. AI & Conversations

#### `ai_conversations`

```sql
CREATE TABLE ai_conversations (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  conversation_type TEXT NOT NULL DEFAULT 'patient_consultation'
                    CHECK (conversation_type IN (
                      'patient_consultation', 'phone_triage', 'er_scenario',
                      'medical_interview', 'colleague_discussion', 'free_practice',
                      'clinical_case'
                    )),
  scenario        JSONB NOT NULL DEFAULT '{}', -- scenario config (patient profile, symptoms, etc.)
  ai_provider     TEXT NOT NULL DEFAULT 'gemini',
  ai_model        TEXT NOT NULL DEFAULT 'gemini-2.0-flash',
  status          TEXT NOT NULL DEFAULT 'active'
                    CHECK (status IN ('active', 'completed', 'abandoned')),
  score           REAL,                        -- overall performance score (0-100)
  feedback        JSONB,                       -- structured AI feedback
  duration_ms     INT DEFAULT 0,
  message_count   INT DEFAULT 0,
  xp_earned       INT NOT NULL DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at    TIMESTAMPTZ
);

CREATE INDEX idx_ai_conversations_user ON ai_conversations(user_id, created_at DESC);
```

#### `ai_messages`

```sql
CREATE TABLE ai_messages (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES ai_conversations(id) ON DELETE CASCADE,
  role            TEXT NOT NULL CHECK (role IN ('system', 'user', 'assistant')),
  content         TEXT NOT NULL,
  audio_url       TEXT,                        -- if user spoke, the recording URL
  pronunciation_score REAL,                    -- pronunciation evaluation (0-100)
  grammar_score   REAL,                        -- grammar evaluation (0-100)
  vocabulary_score REAL,                       -- vocabulary evaluation (0-100)
  fluency_score   REAL,                        -- fluency evaluation (0-100)
  corrections     JSONB,                       -- specific corrections suggested
  tokens_used     INT DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ai_messages_conversation ON ai_messages(conversation_id, created_at);
```

---

### 7. Commerce

#### `subscriptions`

```sql
CREATE TABLE subscriptions (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id             UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  platform            TEXT NOT NULL CHECK (platform IN ('ios', 'android', 'web', 'admin')),
  product_id          TEXT NOT NULL,            -- App Store product identifier
  original_transaction_id TEXT,                 -- App Store original transaction
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
  revenue_cat_id      TEXT,                    -- RevenueCat customer ID
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_subscriptions_user ON subscriptions(user_id, status);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);
```

#### `shop_items`

```sql
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
  effect          JSONB NOT NULL DEFAULT '{}',  -- e.g., {"type": "streak_freeze", "duration_days": 1}
  is_available    BOOLEAN NOT NULL DEFAULT TRUE,
  max_owned       INT DEFAULT NULL,             -- NULL = unlimited
  sort_order      INT NOT NULL DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

#### `user_inventory`

```sql
CREATE TABLE user_inventory (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  item_id         UUID NOT NULL REFERENCES shop_items(id) ON DELETE CASCADE,
  quantity        INT NOT NULL DEFAULT 1,
  is_equipped     BOOLEAN NOT NULL DEFAULT FALSE,  -- for cosmetics
  acquired_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_user_inventory_user ON user_inventory(user_id);
```

---

### 8. Analytics

#### `analytics_events`

```sql
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

-- Partitioned by month for performance
-- Consider using TimescaleDB extension or simple partitioning

CREATE INDEX idx_analytics_events_user ON analytics_events(user_id, created_at DESC);
CREATE INDEX idx_analytics_events_name ON analytics_events(event_name, created_at DESC);
CREATE INDEX idx_analytics_events_date ON analytics_events(created_at DESC);
```

#### `content_ratings`

```sql
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
```

---

## Row Level Security (RLS)

**CRITICAL: RLS MUST be enabled on EVERY table. No exceptions.**

### Policy Patterns

```sql
-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;
-- ... (repeat for ALL tables)

-- ============================================================
-- PROFILES
-- ============================================================

-- Users can read their own profile
CREATE POLICY "Users can read own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

-- Users can read basic info of other users (for friends/leagues)
CREATE POLICY "Users can read public profiles"
  ON profiles FOR SELECT
  USING (TRUE);
  -- Note: Use a view or column-level security to limit exposed fields

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Profiles are created via trigger (not direct insert)
CREATE POLICY "Profiles created via trigger"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- ============================================================
-- CONTENT (courses, modules, lessons, exercises, vocabulary)
-- ============================================================

-- All published content is readable by everyone
CREATE POLICY "Published content is public"
  ON courses FOR SELECT
  USING (is_published = TRUE);

CREATE POLICY "Published modules are public"
  ON modules FOR SELECT
  USING (is_published = TRUE);

CREATE POLICY "Published lessons are public"
  ON lessons FOR SELECT
  USING (is_published = TRUE);

CREATE POLICY "Published exercises are public"
  ON exercises FOR SELECT
  USING (is_published = TRUE);

CREATE POLICY "Published vocabulary is public"
  ON vocabulary FOR SELECT
  USING (is_published = TRUE);

-- Content modification is admin-only (via service role key in admin panel)
-- No INSERT/UPDATE/DELETE policies for regular users on content tables

-- ============================================================
-- USER DATA (progress, attempts, flashcards, stats)
-- ============================================================

-- Users can only access their own data
CREATE POLICY "Users manage own progress"
  ON user_progress FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users manage own exercise attempts"
  ON exercise_attempts FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users manage own vocabulary mastery"
  ON vocabulary_mastery FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users manage own stats"
  ON user_stats FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- SOCIAL (friendships, challenges)
-- ============================================================

-- Users can see friendships where they are involved
CREATE POLICY "Users see own friendships"
  ON friendships FOR SELECT
  USING (auth.uid() = user_id OR auth.uid() = friend_id);

-- Users can create friendship requests
CREATE POLICY "Users create friendship requests"
  ON friendships FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update friendships they received (accept/block)
CREATE POLICY "Users update received friendships"
  ON friendships FOR UPDATE
  USING (auth.uid() = friend_id);

-- ============================================================
-- LEAGUES
-- ============================================================

-- Everyone can see league standings
CREATE POLICY "Leagues are public"
  ON leagues FOR SELECT USING (TRUE);

CREATE POLICY "League members are public"
  ON league_members FOR SELECT USING (TRUE);

-- League membership managed by Edge Functions (service role)
```

---

## Database Functions & Triggers

### Auto-create profile on signup

```sql
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, email, display_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1))
  );

  INSERT INTO user_settings (user_id) VALUES (NEW.id);
  INSERT INTO user_stats (user_id) VALUES (NEW.id);
  INSERT INTO user_onboarding (user_id) VALUES (NEW.id);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
```

### Update streak on XP gain

```sql
CREATE OR REPLACE FUNCTION update_streak()
RETURNS TRIGGER AS $$
DECLARE
  today DATE := CURRENT_DATE;
  last_date DATE;
BEGIN
  SELECT streak_last_date INTO last_date
  FROM user_stats WHERE user_id = NEW.user_id;

  IF last_date IS NULL OR last_date < today - 1 THEN
    -- Streak broken (unless freeze available)
    UPDATE user_stats SET
      current_streak = 1,
      streak_last_date = today,
      updated_at = NOW()
    WHERE user_id = NEW.user_id;
  ELSIF last_date = today - 1 THEN
    -- Streak continues
    UPDATE user_stats SET
      current_streak = current_streak + 1,
      longest_streak = GREATEST(longest_streak, current_streak + 1),
      streak_last_date = today,
      updated_at = NOW()
    WHERE user_id = NEW.user_id;
  END IF;
  -- If last_date = today, streak already counted today

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### Calculate user level from XP

```sql
CREATE OR REPLACE FUNCTION calculate_level(total_xp BIGINT)
RETURNS INT AS $$
BEGIN
  -- Formula: XP_required(n) = floor(50 * n^1.5)
  -- Inverse: level = floor((total_xp / 50)^(2/3))
  RETURN GREATEST(1, FLOOR(POWER(total_xp::FLOAT / 50.0, 2.0/3.0)));
END;
$$ LANGUAGE plpgsql IMMUTABLE;
```

### Heart refill logic

```sql
CREATE OR REPLACE FUNCTION refill_hearts(p_user_id UUID)
RETURNS INT AS $$
DECLARE
  current_hearts INT;
  max_hearts INT;
  last_refill TIMESTAMPTZ;
  hours_elapsed INT;
  hearts_to_add INT;
  new_hearts INT;
BEGIN
  SELECT hearts, hearts_max, hearts_last_refill
  INTO current_hearts, max_hearts, last_refill
  FROM user_stats WHERE user_id = p_user_id;

  IF current_hearts >= max_hearts THEN
    RETURN current_hearts;
  END IF;

  hours_elapsed := EXTRACT(EPOCH FROM (NOW() - last_refill)) / 3600;
  hearts_to_add := hours_elapsed / 4;  -- 1 heart every 4 hours

  IF hearts_to_add > 0 THEN
    new_hearts := LEAST(current_hearts + hearts_to_add, max_hearts);
    UPDATE user_stats SET
      hearts = new_hearts,
      hearts_last_refill = NOW(),
      updated_at = NOW()
    WHERE user_id = p_user_id;
    RETURN new_hearts;
  END IF;

  RETURN current_hearts;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## Edge Functions

### Directory Structure

```
supabase/functions/
├── _shared/
│   ├── ai-provider.ts          ← Multi-provider AI abstraction
│   ├── cors.ts                 ← CORS headers helper
│   ├── auth.ts                 ← Auth verification helper
│   └── types.ts                ← Shared TypeScript types
├── ai-conversation/
│   └── index.ts                ← AI patient conversation endpoint
├── evaluate-pronunciation/
│   └── index.ts                ← Pronunciation scoring
├── generate-exercise-feedback/
│   └── index.ts                ← AI-powered exercise explanations
├── leaderboard-update/
│   └── index.ts                ← Weekly league calculations (cron)
├── assign-daily-quests/
│   └── index.ts                ← Daily quest assignment (cron)
├── check-achievements/
│   └── index.ts                ← Achievement verification
├── webhook-revenuecat/
│   └── index.ts                ← RevenueCat subscription webhooks
├── delete-account/
│   └── index.ts                ← GDPR-compliant account deletion
└── referral/
    └── index.ts                ← Referral code redemption
```

### AI Provider Abstraction (`_shared/ai-provider.ts`)

```typescript
// Multi-provider AI abstraction
// Switch providers by configuration, not by code changes

interface AIProvider {
  chat(messages: Message[], options?: ChatOptions): Promise<AIResponse>;
  evaluate(text: string, criteria: EvaluationCriteria): Promise<EvaluationResult>;
}

interface Message {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

interface ChatOptions {
  model?: string;
  temperature?: number;
  maxTokens?: number;
  responseFormat?: 'text' | 'json';
}

interface AIResponse {
  content: string;
  tokensUsed: number;
  provider: string;
  model: string;
}

// Factory function
export function getAIProvider(provider: string = 'gemini'): AIProvider {
  switch (provider) {
    case 'gemini': return new GeminiProvider();
    case 'openai': return new OpenAIProvider();
    case 'claude': return new ClaudeProvider();
    default: return new GeminiProvider();
  }
}

// Fallback chain: try primary, fall back to secondary
export async function chatWithFallback(
  messages: Message[],
  options?: ChatOptions
): Promise<AIResponse> {
  const providers = ['gemini', 'openai', 'claude'];
  for (const provider of providers) {
    try {
      return await getAIProvider(provider).chat(messages, options);
    } catch (error) {
      console.error(`Provider ${provider} failed:`, error);
      continue;
    }
  }
  throw new Error('All AI providers failed');
}
```

### AI Conversation Endpoint (`ai-conversation/index.ts`)

```typescript
// POST /functions/v1/ai-conversation
// Body: { conversationId?, message, conversationType?, scenario? }
// Returns: { response, scores, conversationId }

// System prompt template for medical patient simulation:
const PATIENT_SYSTEM_PROMPT = `
You are a patient in a medical consultation simulation for MediLingo,
a medical English learning app. Your role:

1. Respond ONLY in English
2. Act as the patient described in the scenario
3. Use natural, realistic patient language
4. Include relevant symptoms, medical history, and concerns
5. Adapt complexity based on the user's English level: {level}
6. If the user makes a significant English error, subtly model
   the correct phrasing in your response
7. Stay in character — never break the simulation

Scenario: {scenario}
Patient Profile: {patientProfile}
`;
```

---

## Storage Buckets

```sql
-- Audio files (pronunciation, dialogues, listening exercises)
INSERT INTO storage.buckets (id, name, public)
VALUES ('audio', 'audio', TRUE);

-- Images and illustrations
INSERT INTO storage.buckets (id, name, public)
VALUES ('images', 'images', TRUE);

-- Lottie/Rive animations
INSERT INTO storage.buckets (id, name, public)
VALUES ('animations', 'animations', TRUE);

-- User-generated content (recordings)
INSERT INTO storage.buckets (id, name, public)
VALUES ('user-recordings', 'user-recordings', FALSE);

-- Certificates (generated PDFs)
INSERT INTO storage.buckets (id, name, public)
VALUES ('certificates', 'certificates', FALSE);
```

### Storage Policies

```sql
-- Public buckets: anyone can read
CREATE POLICY "Public audio access"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'audio');

-- User recordings: only owner can access
CREATE POLICY "User recordings access"
  ON storage.objects FOR ALL
  USING (bucket_id = 'user-recordings' AND auth.uid()::TEXT = (storage.foldername(name))[1]);
```

---

## Realtime Subscriptions

| Channel | Purpose | Tables |
|---------|---------|--------|
| `user_stats:{userId}` | Live XP/streak updates | `user_stats` |
| `league:{leagueId}` | Live league standings | `league_members` |
| `challenge:{challengeId}` | Live challenge scores | `challenges` |
| `friend_activity:{userId}` | Friend achievements/activity | `user_achievements`, `user_progress` |

---

## Authentication

### Supported Providers

1. **Sign in with Apple** (required by App Store)
2. **Google Sign-In**
3. **Email + Password** (with email verification)

### Auth Flow

```
1. User taps "Sign in with Apple/Google/Email"
2. Supabase Auth handles OAuth / email flow
3. On success, trigger creates profile + stats + settings
4. Client receives JWT + refresh token
5. Client stores tokens in Keychain (iOS)
6. All API calls include Authorization: Bearer {jwt}
7. Refresh token rotation handled by Supabase client SDK
```

### Account Deletion (GDPR/App Store requirement)

Edge Function `delete-account` purges:
1. All user data from every table (CASCADE from profiles)
2. User recordings from Storage
3. Supabase Auth user record
4. RevenueCat customer (optional, mark as deleted)

---

## API Contracts

### Response Envelope

All responses follow this shape:

```json
{
  "data": { ... },
  "error": null,
  "metadata": {
    "timestamp": "2026-07-03T20:00:00Z",
    "requestId": "uuid"
  }
}
```

### Error Response

```json
{
  "data": null,
  "error": {
    "code": "INSUFFICIENT_HEARTS",
    "message": "You don't have enough hearts to continue",
    "details": { "hearts": 0, "nextRefillAt": "2026-07-03T22:00:00Z" }
  },
  "metadata": { ... }
}
```

### Key Endpoints (via Supabase REST + Edge Functions)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/rest/v1/courses?is_published=eq.true` | List published courses |
| GET | `/rest/v1/modules?course_id=eq.{id}` | List modules for a course |
| GET | `/rest/v1/lessons?module_id=eq.{id}` | List lessons for a module |
| GET | `/rest/v1/exercises?lesson_id=eq.{id}` | List exercises for a lesson |
| POST | `/rest/v1/exercise_attempts` | Submit exercise answer |
| GET | `/rest/v1/vocabulary_mastery?user_id=eq.{id}&next_review_at=lte.{now}` | Get due flashcards |
| POST | `/rest/v1/flashcard_reviews` | Submit flashcard review |
| POST | `/functions/v1/ai-conversation` | AI conversation turn |
| POST | `/functions/v1/evaluate-pronunciation` | Evaluate pronunciation |
| GET | `/rest/v1/user_stats?user_id=eq.{id}` | Get user stats |
| GET | `/rest/v1/league_members?league_id=eq.{id}&order=weekly_xp.desc` | League standings |

---

## Migration Strategy

### Naming Convention

```
supabase/migrations/
├── 20260703000000_initial_schema.sql
├── 20260703000001_rls_policies.sql
├── 20260703000002_functions_triggers.sql
├── 20260703000003_seed_achievements.sql
├── 20260703000004_seed_daily_quests.sql
├── 20260710000000_add_clinical_cases.sql
└── ...
```

### Rules

1. **Never modify** a migration after applied to production
2. Create a **new migration** for every schema change
3. Migrations **idempotent** where possible (`CREATE IF NOT EXISTS`)
4. Always include **rollback comments** at top of each migration
5. Test migrations locally with `supabase db reset` before deploy

---

## Performance & Indexing

### Critical Queries and Their Indexes

| Query | Index |
|-------|-------|
| Fetch user's due flashcards | `idx_vocab_mastery_user_review(user_id, next_review_at)` |
| Fetch lesson exercises | `idx_exercises_lesson(lesson_id, sort_order)` |
| Fetch user progress | `idx_user_progress_user(user_id, entity_type)` |
| League standings | `idx_league_members_league(league_id, weekly_xp DESC)` |
| Recent exercise attempts | `idx_exercise_attempts_user(user_id, created_at DESC)` |
| Published content listing | `idx_courses_published(is_published, sort_order)` |

### Query Optimization Rules

- `SELECT` only columns needed (never `SELECT *` in production)
- Use Supabase built-in pagination (`.range()`)
- Cache frequent content (courses, modules) on client
- Use DB views for complex joins (e.g., lesson with exercise count + progress)

---

## Monitoring & Observability

### Supabase Dashboard
- DB health, query performance, storage usage
- Auth logs, Edge Function logs
- Realtime connection monitoring

### Custom Monitoring
- Edge Function error rates + latency (logged to analytics_events)
- AI provider costs tracked per conversation
- Daily active users, retention cohorts (via PostHog)
- Subscription metrics (via RevenueCat dashboard)

### Alerts (via Supabase or external monitoring)
- DB connection pool exhaustion (> 80%)
- Edge Function error rate > 5%
- AI provider cost exceeds daily budget
- Storage usage > 80% of limit