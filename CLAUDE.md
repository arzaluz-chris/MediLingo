# CLAUDE.md — MediLingo

Cross-platform medical English app for Spanish-speaking healthcare pros. Gamified, AI-powered, content-driven. iOS-first (SwiftUI), Supabase backend, Next.js admin panel.

## Architecture

MVVM + Repository + Service. Content = data, not code — lessons/exercises from database, never hardcoded. No App Store update for new content.

```
Clients (iOS SwiftUI · Android Compose future · Web Admin Next.js)
    ↓
Supabase (Auth · PostgreSQL · Storage · Edge Functions · Realtime)
    ↓
AI Providers (Gemini primary · OpenAI fallback · Claude specialty)
    ↓
Analytics (Firebase · PostHog · RevenueCat · Crashlytics)
```

## Repository Structure

```
MediLingo/
├── CLAUDE.md                    ← Conventions only (this file)
├── CLAUDE-backend.md            ← DB schema, RLS, Edge Functions, API
├── CLAUDE-ios.md                ← iOS architecture, features, services
├── CLAUDE-admin.md              ← Next.js admin CMS
├── CLAUDE-content.md            ← Exercise engine, SR algorithm, AI prompts
├── docs/
│   ├── VISION.md                ← Philosophy, users, value proposition
│   ├── GAMIFICATION.md          ← XP, streaks, leagues, achievements
│   ├── ROADMAP.md               ← MVP scope, milestones, phases
│   └── MONETIZATION.md          ← Pricing, subscriptions, revenue
├── ios/MediLingo/
│   ├── App/                     ← Entry, DI
│   ├── Core/{Models,Services,Repositories,Engine,Extensions}/
│   ├── Features/{Auth,Home,Learning,Exercises,AIConversation,
│   │            Flashcards,Pronunciation,Profile,Social,Shop,Subscription}/
│   ├── DesignSystem/            ← Colors, typography, components
│   └── Resources/               ← Assets, Lottie/Rive, localization
├── admin/src/{app,components,lib,types,hooks}/
├── supabase/{migrations,functions,seed.sql,config.toml}/
└── shared/schemas/              ← Exercise JSON schemas
```

## Tech Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| iOS UI | SwiftUI (iOS 17+) | Native, existing expertise |
| State | @Observable | Modern, no Combine for new code |
| Local cache | SwiftData | Offline-first, Apple-native |
| Concurrency | async/await, Actors | Structured concurrency, no Combine |
| Backend | Supabase | Fast to market, built-in auth/storage/realtime |
| Database | PostgreSQL 15+ | Supabase default, JSONB for exercise metadata |
| Auth | Supabase Auth | Apple Sign In + Google + Email |
| Edge Functions | Deno/TypeScript | AI proxy, custom logic |
| AI abstraction | Multi-provider | Gemini primary, OpenAI/Claude fallback. Switch by config |
| Admin panel | Next.js 14+ App Router | Web CMS, TypeScript, Tailwind, Vercel |
| Subscriptions | StoreKit 2 + RevenueCat | Native + cross-platform analytics |
| Animations | Lottie/Rive | Small, scalable, interactive. No video |
| Illustrations | Vector only | No photographs. Brand characters |
| Ads | None | Professional audience, freemium model |

## Swift/iOS Conventions

- MVVM + Repository + Service. Protocols for all services.
- iOS 17+ min. Use @Observable, SwiftData, new SwiftUI APIs.
- async/await everywhere. No Combine for new code.
- Swift API Design Guidelines. No abbreviations.
- `enum AppError: LocalizedError` — typed, never force unwrap (`!`).
- Every interactive element gets accessibility labels/traits.
- All strings in `Localizable.xcstrings`. UI Spanish; learning content English.
- Minimize deps. Prefer Apple frameworks. SPM only.
- No magic numbers — constants in dedicated files.
- SwiftLint enforced. Zero warnings after MVP.

## Backend Conventions

- RLS on ALL tables. No exceptions.
- Migrations: `YYYYMMDDHHMMSS_description.sql`, never modify after deploy.
- `snake_case` in DB, `camelCase` in TypeScript/JSON.
- API envelope: `{ data, error, metadata }` all responses.
- Edge Functions: TypeScript, validate inputs, rate-limit AI endpoints.
- Secrets in Supabase Vault / env vars. Never in client code.
- Service role key: server-side only (admin). Client uses anon key.

## Admin Conventions

- Next.js 14+ App Router. TypeScript strict mode.
- Tailwind CSS + shadcn/ui.
- Server Components default, Client Components only when needed.
- TanStack Query for server state. React Hook Form + Zod for forms.
- Deploy: Vercel. Domain: `admin.medilingo.app`.

## Content Rules

- Exercises = DATA, not views. Rendered from JSON/DB via exercise engine.
- AI drafts → physician validates → admin publishes.
- Weekly content updates. No App Store submission needed.
- Audio: 44.1kHz mono AAC (.m4a), normalized to -16 LUFS.
- Illustrations: vector only, brand character style (Duolingo/Headspace inspired).

## Environment Variables

```
# iOS (config files, not code)
SUPABASE_URL, SUPABASE_ANON_KEY, REVENUE_CAT_API_KEY, POSTHOG_API_KEY

# Edge Functions
GEMINI_API_KEY, OPENAI_API_KEY, ANTHROPIC_API_KEY

# Admin (.env.local)
NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY
```

## Reference Docs

Read only when working relevant subsystem:

| Working on... | Read |
|---------------|------|
| Database, API, Supabase | `CLAUDE-backend.md` |
| iOS app features | `CLAUDE-ios.md` |
| Admin panel / CMS | `CLAUDE-admin.md` |
| Exercise types, AI, spaced repetition | `CLAUDE-content.md` |
| Product vision, target users | `docs/VISION.md` |
| XP, streaks, leagues, achievements | `docs/GAMIFICATION.md` |
| MVP scope, milestones, timeline | `docs/ROADMAP.md` |
| Pricing, subscriptions, revenue | `docs/MONETIZATION.md` |