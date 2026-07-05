# CLAUDE-admin.md — MediLingo Admin Panel Specification

> Full spec for Next.js admin panel / CMS.
> Create, manage, publish all MediLingo educational content.

---

## Table of Contents

1. [Purpose & Philosophy](#purpose--philosophy)
2. [Tech Stack](#tech-stack)
3. [Project Structure](#project-structure)
4. [Authentication & Authorization](#authentication--authorization)
5. [Pages & Routes](#pages--routes)
6. [Core Features](#core-features)
7. [Content Management](#content-management)
8. [AI Content Generation Tools](#ai-content-generation-tools)
9. [Analytics Dashboard](#analytics-dashboard)
10. [User Management](#user-management)
11. [Design & UI Components](#design--ui-components)
12. [API Integration](#api-integration)
13. [Deployment](#deployment)

---

## Purpose & Philosophy

Admin panel = **control center** for MediLingo. Where:

1. **Content is created** — Courses, modules, lessons, exercises, vocabulary
2. **Content is managed** — Edit, reorder, publish/unpublish
3. **AI assists** — Generate exercise drafts, vocabulary, clinical cases
4. **Quality is controlled** — Draft → Review → Publish workflow
5. **Performance is monitored** — User analytics, content engagement
6. **Users are managed** — View profiles, manage subscriptions (manual overrides)

### Key Principles

- **No SQL editing** — All through visual CMS interface
- **WYSIWYG where possible** — Preview content on mobile
- **AI-assisted, physician-approved** — AI drafts; admin reviews and publishes
- **Batch operations** — Create, edit, reorder many items at once
- **Audit trail** — Track who created/modified what, when

---

## Tech Stack

| Technology | Purpose |
|-----------|---------|
| **Next.js 14+** | React framework, App Router |
| **TypeScript** | Type safety (strict mode) |
| **Tailwind CSS** | Utility-first styling |
| **shadcn/ui** | Component library (on Radix UI + Tailwind) |
| **Supabase JS Client** | Database, Auth, Storage access |
| **Supabase Service Role** | Admin-level access (bypasses RLS) |
| **TanStack Table** | Data tables: sort, filter, paginate |
| **TanStack Query** | Server state + caching |
| **React Hook Form + Zod** | Forms + validation |
| **Tiptap** | Rich text editor (lesson intros, explanations) |
| **Vercel** | Deploy + hosting |
| **next-themes** | Dark mode |
| **Lucide React** | Icons |

---

## Project Structure

```
admin/
├── src/
│   ├── app/                         ← App Router pages
│   │   ├── layout.tsx               ← Root layout with sidebar
│   │   ├── page.tsx                 ← Dashboard (redirect or overview)
│   │   ├── login/
│   │   │   └── page.tsx
│   │   ├── dashboard/
│   │   │   └── page.tsx             ← Analytics overview
│   │   ├── courses/
│   │   │   ├── page.tsx             ← Course list
│   │   │   ├── new/page.tsx         ← Create course
│   │   │   └── [courseId]/
│   │   │       ├── page.tsx         ← Course detail/edit
│   │   │       └── modules/
│   │   │           ├── page.tsx     ← Module list for course
│   │   │           └── [moduleId]/
│   │   │               ├── page.tsx ← Module detail
│   │   │               └── lessons/
│   │   │                   ├── page.tsx
│   │   │                   └── [lessonId]/
│   │   │                       ├── page.tsx  ← Lesson editor
│   │   │                       └── exercises/
│   │   │                           ├── page.tsx
│   │   │                           └── [exerciseId]/page.tsx
│   │   ├── vocabulary/
│   │   │   ├── page.tsx             ← Vocabulary list (searchable, filterable)
│   │   │   ├── new/page.tsx
│   │   │   └── [wordId]/page.tsx
│   │   ├── audio/
│   │   │   ├── page.tsx             ← Audio library
│   │   │   └── upload/page.tsx
│   │   ├── achievements/
│   │   │   ├── page.tsx
│   │   │   └── [achievementId]/page.tsx
│   │   ├── quests/
│   │   │   ├── page.tsx
│   │   │   └── [questId]/page.tsx
│   │   ├── ai-tools/
│   │   │   ├── page.tsx             ← AI content generation hub
│   │   │   ├── vocabulary-generator/page.tsx
│   │   │   ├── exercise-generator/page.tsx
│   │   │   ├── clinical-case-generator/page.tsx
│   │   │   └── dialogue-generator/page.tsx
│   │   ├── users/
│   │   │   ├── page.tsx             ← User list
│   │   │   └── [userId]/page.tsx    ← User detail
│   │   ├── analytics/
│   │   │   ├── page.tsx             ← Engagement metrics
│   │   │   ├── content/page.tsx     ← Content performance
│   │   │   └── revenue/page.tsx     ← Revenue metrics
│   │   └── settings/
│   │       └── page.tsx             ← App settings, feature flags
│   │
│   ├── components/
│   │   ├── ui/                      ← shadcn/ui components
│   │   │   ├── button.tsx
│   │   │   ├── card.tsx
│   │   │   ├── dialog.tsx
│   │   │   ├── dropdown-menu.tsx
│   │   │   ├── form.tsx
│   │   │   ├── input.tsx
│   │   │   ├── select.tsx
│   │   │   ├── table.tsx
│   │   │   ├── tabs.tsx
│   │   │   ├── badge.tsx
│   │   │   ├── toast.tsx
│   │   │   └── ... (other shadcn components)
│   │   ├── layout/
│   │   │   ├── sidebar.tsx          ← Navigation sidebar
│   │   │   ├── header.tsx           ← Top bar with breadcrumbs
│   │   │   ├── breadcrumbs.tsx
│   │   │   └── page-header.tsx
│   │   ├── content/
│   │   │   ├── course-form.tsx      ← Course create/edit form
│   │   │   ├── module-form.tsx
│   │   │   ├── lesson-form.tsx
│   │   │   ├── exercise-form.tsx    ← Dynamic form based on exercise type
│   │   │   ├── vocabulary-form.tsx
│   │   │   ├── exercise-preview.tsx ← Mobile preview of exercise
│   │   │   ├── sortable-list.tsx    ← Drag-and-drop reordering
│   │   │   ├── audio-uploader.tsx
│   │   │   ├── image-uploader.tsx
│   │   │   └── publish-toggle.tsx   ← Publish/unpublish switch
│   │   ├── ai/
│   │   │   ├── ai-generator-form.tsx
│   │   │   ├── ai-result-review.tsx
│   │   │   └── ai-batch-import.tsx
│   │   ├── analytics/
│   │   │   ├── stat-card.tsx
│   │   │   ├── chart-card.tsx
│   │   │   ├── retention-chart.tsx
│   │   │   └── engagement-table.tsx
│   │   └── shared/
│   │       ├── data-table.tsx       ← Reusable data table wrapper
│   │       ├── confirm-dialog.tsx
│   │       ├── empty-state.tsx
│   │       ├── loading-skeleton.tsx
│   │       ├── status-badge.tsx     ← Published/Draft/Review badges
│   │       └── search-input.tsx
│   │
│   ├── lib/
│   │   ├── supabase/
│   │   │   ├── client.ts            ← Browser client (anon key)
│   │   │   ├── server.ts            ← Server client (service role key)
│   │   │   └── middleware.ts        ← Auth middleware
│   │   ├── ai/
│   │   │   ├── provider.ts          ← AI provider abstraction
│   │   │   ├── prompts.ts           ← Prompt templates
│   │   │   └── schemas.ts           ← Zod schemas for AI outputs
│   │   ├── utils.ts                 ← General utilities
│   │   └── constants.ts             ← App constants
│   │
│   ├── types/
│   │   ├── database.ts              ← Generated Supabase types
│   │   ├── content.ts               ← Content domain types
│   │   ├── exercise.ts              ← Exercise type definitions
│   │   ├── user.ts                  ← User types
│   │   └── analytics.ts             ← Analytics types
│   │
│   └── hooks/
│       ├── use-courses.ts           ← TanStack Query hooks
│       ├── use-modules.ts
│       ├── use-lessons.ts
│       ├── use-exercises.ts
│       ├── use-vocabulary.ts
│       ├── use-users.ts
│       └── use-analytics.ts
│
├── public/
│   └── ... (static assets)
├── package.json
├── tsconfig.json
├── tailwind.config.ts
├── next.config.ts
└── .env.local
```

---

## Authentication & Authorization

### Admin Access

- Only pre-authorized emails access admin panel
- Supabase Auth with **email/password** for admin login
- Store admin role in dedicated `admin_users` table or use Supabase custom claims

```sql
-- Admin users table (not exposed to mobile app RLS)
CREATE TABLE admin_users (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email       TEXT NOT NULL UNIQUE,
  role        TEXT NOT NULL DEFAULT 'editor'
                CHECK (role IN ('editor', 'admin', 'super_admin')),
  full_name   TEXT NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS: Only admin users can read admin_users
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can read admin_users"
  ON admin_users FOR SELECT
  USING (auth.uid() IN (SELECT id FROM admin_users));
```

### Roles

| Role | Permissions |
|------|------------|
| **Editor** | Create/edit content, use AI tools, view analytics |
| **Admin** | Editor + manage users, publish content, manage settings |
| **Super Admin** | Admin + manage admin accounts, delete data |

### Middleware

```typescript
// middleware.ts
import { createMiddlewareClient } from '@/lib/supabase/middleware'
import { NextResponse } from 'next/server'

export async function middleware(req: NextRequest) {
  const { supabase, response } = createMiddlewareClient(req)

  const { data: { session } } = await supabase.auth.getSession()

  if (!session && !req.nextUrl.pathname.startsWith('/login')) {
    return NextResponse.redirect(new URL('/login', req.url))
  }

  if (session) {
    // Verify user is an admin
    const { data: adminUser } = await supabase
      .from('admin_users')
      .select('role')
      .eq('id', session.user.id)
      .single()

    if (!adminUser && !req.nextUrl.pathname.startsWith('/login')) {
      return NextResponse.redirect(new URL('/login?error=unauthorized', req.url))
    }
  }

  return response
}
```

---

## Pages & Routes

### Navigation Structure (Sidebar)

```
📊 Dashboard
📚 Content
  ├── 📖 Courses
  ├── 📝 Vocabulary
  ├── 🔊 Audio Library
  ├── 🏆 Achievements
  └── 📋 Daily Quests
🤖 AI Tools
  ├── 📝 Vocabulary Generator
  ├── 🧩 Exercise Generator
  ├── 🏥 Clinical Case Generator
  └── 💬 Dialogue Generator
👥 Users
📈 Analytics
  ├── 📊 Engagement
  ├── 📄 Content Performance
  └── 💰 Revenue
⚙️ Settings
```

---

## Core Features

### 1. Course Management

**Course List** (`/courses`)
- Data table columns: Title, Category, Difficulty, Modules, Lessons, Status (Published/Draft), Last Updated
- Filters: Category, Difficulty, Status
- Sort: Title, Updated, Lessons count
- Actions: Edit, Publish/Unpublish, Delete, Duplicate

**Course Editor** (`/courses/[courseId]`)
- Fields: Title, Slug (auto-generated), Description, Short Description, Icon, Color, Difficulty, Category, Target Roles (multi-select), Estimated Hours, Is Premium, Is Featured
- Module list with drag-and-drop reordering
- "Add Module" button
- Publish toggle with confirmation

### 2. Module Management

**Module Editor** (`/courses/[courseId]/modules/[moduleId]`)
- Fields: Title, Slug, Description, Icon, Prerequisite Module (dropdown)
- Lesson list with drag-and-drop reordering
- "Add Lesson" button

### 3. Lesson Management

**Lesson Editor** (`/courses/.../lessons/[lessonId]`)
- Fields: Title, Slug, Description, Type (Standard/Review/Clinical Case/etc.), Difficulty, Estimated Minutes, XP Reward, Is Premium, Prerequisite Lesson
- Intro Text (rich text editor)
- Completion Text (rich text editor)
- **Exercise list with drag-and-drop reordering**
- "Add Exercise" button → opens exercise type selector
- **Vocabulary association** — search and link vocabulary words to lesson
- **Preview button** — mobile-like preview of lesson flow

### 4. Exercise Editor (Dynamic)

Exercise editor changes fields by selected exercise type:

```typescript
// Exercise type → form fields mapping
const exerciseFormConfig: Record<ExerciseType, FormField[]> = {
  multiple_choice: [
    { name: 'prompt', type: 'textarea', label: 'Question', required: true },
    { name: 'prompt_audio_url', type: 'audio_upload', label: 'Question Audio' },
    { name: 'prompt_image_url', type: 'image_upload', label: 'Question Image' },
    { name: 'options', type: 'option_list', label: 'Options', min: 2, max: 6 },
    { name: 'explanation', type: 'textarea', label: 'Explanation (English)' },
    { name: 'explanation_es', type: 'textarea', label: 'Explanation (Spanish)' },
    { name: 'hint', type: 'input', label: 'Hint' },
    { name: 'difficulty', type: 'select', label: 'Difficulty', options: ['beginner', 'intermediate', 'advanced'] },
  ],
  listening: [
    { name: 'prompt', type: 'textarea', label: 'Instructions' },
    { name: 'prompt_audio_url', type: 'audio_upload', label: 'Audio Clip', required: true },
    { name: 'correct_answer', type: 'textarea', label: 'Correct Transcript' },
    { name: 'options', type: 'option_list', label: 'Answer Options' },
    // ...
  ],
  pronunciation: [
    { name: 'prompt', type: 'textarea', label: 'Word or Phrase to Pronounce' },
    { name: 'prompt_audio_url', type: 'audio_upload', label: 'Reference Pronunciation', required: true },
    { name: 'correct_answer', type: 'input', label: 'Expected Text' },
    { name: 'metadata', type: 'json', label: 'Pronunciation Config',
      schema: { acceptableScore: 'number', phonemes: 'string[]' } },
    // ...
  ],
  fill_in_blank: [
    { name: 'prompt', type: 'textarea', label: 'Sentence (use ___ for blank)' },
    { name: 'correct_answer', type: 'input', label: 'Correct Word(s)' },
    { name: 'metadata', type: 'json', label: 'Config',
      schema: { acceptableAnswers: 'string[]', caseSensitive: 'boolean' } },
    // ...
  ],
  sentence_ordering: [
    { name: 'prompt', type: 'textarea', label: 'Instructions' },
    { name: 'correct_answer', type: 'textarea', label: 'Correct Sentence' },
    { name: 'metadata', type: 'json', label: 'Config',
      schema: { words: 'string[]', extraWords: 'string[]' } },
    // ...
  ],
  matching: [
    { name: 'prompt', type: 'textarea', label: 'Instructions' },
    { name: 'options', type: 'matching_pairs', label: 'Matching Pairs' },
    // ...
  ],
  clinical_case: [
    { name: 'prompt', type: 'richtext', label: 'Case Presentation' },
    { name: 'metadata', type: 'json', label: 'Case Config',
      schema: {
        patientProfile: 'object',
        stages: 'Stage[]',
        correctDiagnosis: 'string',
        differentialDiagnoses: 'string[]'
      }
    },
    // ...
  ],
  // ... (all 15 types)
}
```

### 5. Vocabulary Manager

**Vocabulary List** (`/vocabulary`)
- Searchable, filterable data table
- Columns: Word, Translation, Category, Difficulty, Lessons Used In, Published
- Bulk actions: Publish, Unpublish, Delete, Export CSV
- **Import from CSV** — bulk vocabulary upload

**Vocabulary Editor** (`/vocabulary/[wordId]`)
- Fields: Word, Phonetic (IPA), Translation, English Definition, Spanish Definition, Example (EN), Example (ES), Etymology, Category, Difficulty, Tags
- Audio upload for pronunciation
- Related words selector (search and link)
- Preview card: how it looks on mobile

### 6. Audio Library

**Audio Manager** (`/audio`)
- Upload audio files (drag-and-drop, supports mp3/m4a/wav)
- Auto-normalize audio levels
- Table: Title, Speaker, Accent, Speed, Duration, Scenario, Used In
- Inline audio preview player
- Bulk upload support

### 7. Achievements & Quests

**Achievement Editor** — Title, Description, Icon, Category, Requirement (JSON builder), XP/Gem rewards, Is Secret

**Quest Editor** — Title, Description, Type, Target Value, XP/Gem rewards

---

## AI Content Generation Tools

### Vocabulary Generator (`/ai-tools/vocabulary-generator`)

```
Input:
  - Medical specialty (e.g., "Cardiology")
  - Difficulty level
  - Count (how many words to generate)
  - Optional: specific topic (e.g., "heart failure medications")

Output:
  - List of vocabulary words with:
    - Word
    - IPA pronunciation
    - Spanish translation
    - English definition
    - Example sentence
    - Etymology
    - Category
    - Difficulty

Workflow:
  1. Admin fills form and clicks "Generate"
  2. AI generates vocabulary list
  3. Admin reviews each word (edit, approve, reject)
  4. Approved words are saved as drafts in the database
  5. Admin publishes when ready
```

### Exercise Generator (`/ai-tools/exercise-generator`)

```
Input:
  - Vocabulary words or topic
  - Exercise type(s) to generate
  - Difficulty
  - Count

Output:
  - Ready-to-use exercise JSON for each type
  - Including options, correct answers, explanations

Workflow:
  1. Admin selects vocabulary or topic
  2. Chooses exercise types to generate
  3. AI creates exercises
  4. Admin reviews, edits, and approves
  5. Exercises are added to selected lessons
```

### Clinical Case Generator (`/ai-tools/clinical-case-generator`)

```
Input:
  - Specialty
  - Difficulty
  - Chief complaint (optional)
  - Target vocabulary (optional)

Output:
  - Complete clinical case with:
    - Patient demographics
    - Chief complaint
    - History of present illness
    - Past medical history
    - Physical exam findings
    - Lab results
    - Imaging results
    - Stage-by-stage questions
    - Correct diagnosis
    - Differential diagnoses
    - Treatment plan
```

### Dialogue Generator (`/ai-tools/dialogue-generator`)

```
Input:
  - Scenario (e.g., "ER triage", "Phone call with specialist")
  - Characters (Patient, Doctor, Nurse)
  - Key vocabulary to include
  - Difficulty

Output:
  - Multi-turn dialogue
  - With notes on pronunciation challenges
  - Comprehension questions
  - Translation exercise pairs
```

### AI Integration Implementation

```typescript
// lib/ai/provider.ts

interface AIContentRequest {
  type: 'vocabulary' | 'exercise' | 'clinical_case' | 'dialogue';
  params: Record<string, any>;
  model?: string;
}

interface AIContentResponse {
  content: any;
  tokensUsed: number;
  provider: string;
  generatedAt: string;
}

export async function generateContent(request: AIContentRequest): Promise<AIContentResponse> {
  // Call Supabase Edge Function which proxies to AI providers
  const supabase = createServerClient();

  const { data, error } = await supabase.functions.invoke('generate-content', {
    body: request
  });

  if (error) throw error;
  return data;
}
```

---

## Analytics Dashboard

### Overview (`/dashboard`)

| Metric | Description | Chart Type |
|--------|-------------|------------|
| DAU / WAU / MAU | Active users | Line chart |
| New signups today/week | Registration rate | Number + sparkline |
| Lessons completed today | Learning activity | Number |
| Premium conversions | New subscribers | Number + conversion rate |
| Revenue (MRR) | Monthly recurring revenue | Line chart |
| Retention (D1, D7, D30) | User retention | Cohort chart |

### Content Performance (`/analytics/content`)

| Metric | Description |
|--------|-------------|
| Lesson completion rate | % users who finish each lesson |
| Exercise accuracy | % correct per exercise |
| Drop-off points | Where users quit lessons |
| Average lesson time | Time per lesson |
| Content ratings | User ratings per lesson |
| Vocabulary mastery distribution | How many words users mastered |

### Revenue (`/analytics/revenue`)

- MRR, ARR, LTV
- Subscriber count by plan (monthly/annual)
- Conversion funnel: Download → Active → Trial → Subscriber
- Churn rate
- Revenue by region

---

## User Management

### User List (`/users`)
- Data table: Display Name, Email, Role, Level, XP, Streak, Premium Status, Signup Date, Last Active
- Filters: Premium/Free, Role, Activity (Active, Inactive, Churned)
- Search by email or name

### User Detail (`/users/[userId]`)
- Profile info
- Learning progress (courses, lessons completed)
- Gamification stats (XP, streak, level, achievements)
- Subscription history
- Activity timeline
- Admin actions: Grant Premium (manual), Reset progress, Ban user

---

## Design & UI Components

### Theme

- **Dark mode** default (medical professional aesthetic)
- **shadcn/ui** for consistent component library
- Color palette aligned with MediLingo brand
- Clean, dense layout for productivity

### Key Components

```
shadcn/ui components to install:
  button, card, dialog, dropdown-menu, form, input, label,
  select, separator, sheet, skeleton, table, tabs, textarea,
  toast, toggle, badge, command, popover, switch, tooltip,
  avatar, progress, scroll-area, alert, calendar
```

---

## API Integration

### Supabase Clients

```typescript
// lib/supabase/server.ts
// Uses SERVICE_ROLE_KEY — bypasses RLS for admin operations

import { createClient } from '@supabase/supabase-js'
import type { Database } from '@/types/database'

export function createServerClient() {
  return createClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,  // ⚠️ Server-side only!
    {
      auth: { persistSession: false }
    }
  )
}
```

```typescript
// lib/supabase/client.ts
// Uses ANON_KEY — for client-side auth state

import { createBrowserClient } from '@supabase/ssr'
import type { Database } from '@/types/database'

export function createBrowserSupabase() {
  return createBrowserClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
```

### Type Generation

```bash
# Generate TypeScript types from Supabase schema
npx supabase gen types typescript --project-id YOUR_PROJECT_ID > src/types/database.ts
```

### TanStack Query Hooks

```typescript
// hooks/use-courses.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'

export function useCourses() {
  return useQuery({
    queryKey: ['courses'],
    queryFn: async () => {
      const res = await fetch('/api/courses')
      return res.json()
    }
  })
}

export function useCreateCourse() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (course: CreateCourseInput) => {
      const res = await fetch('/api/courses', {
        method: 'POST',
        body: JSON.stringify(course)
      })
      return res.json()
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['courses'] })
    }
  })
}
```

---

## Deployment

### Vercel Configuration

```json
// vercel.json
{
  "framework": "nextjs",
  "buildCommand": "next build",
  "devCommand": "next dev",
  "installCommand": "npm install",
  "regions": ["iad1"],
  "env": {
    "NEXT_PUBLIC_SUPABASE_URL": "@supabase-url",
    "NEXT_PUBLIC_SUPABASE_ANON_KEY": "@supabase-anon-key",
    "SUPABASE_SERVICE_ROLE_KEY": "@supabase-service-role-key"
  }
}
```

### Environment Variables

```
# .env.local (development)
NEXT_PUBLIC_SUPABASE_URL=http://127.0.0.1:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...

# Vercel (production)
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...  # ⚠️ Secret — never expose to client
```

### Domain

- Admin panel at: `admin.medilingo.app`
- Protected by Vercel authentication + Supabase admin auth