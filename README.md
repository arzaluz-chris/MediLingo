# MediLingo

Cross-platform medical-English learning app for Spanish-speaking healthcare professionals. Gamified, AI-powered, content-driven. iOS-first (SwiftUI), Supabase backend, Next.js admin panel.

> **Status:** MVP feature-complete on iOS + backend + admin. The iOS app builds
> and runs the full exercise engine, gamification (server-authoritative XP,
> hearts, quests, achievements, leagues), StoreKit 2 subscriptions, native
> Apple/Google sign-in, offline content cache, and referrals. Backend has 13
> migrations, 8 Edge Functions, and a 10-module / 50-lesson / 210-exercise
> curriculum (AI-drafted, pending physician validation). Admin CMS is fully
> functional. Android is an auth-only skeleton (Phase 5). **Before it runs
> against real services you must supply keys/accounts — see `SETUP.md`.**

## Repository layout

| Path | What |
|------|------|
| `ios/MediLingo/` | iOS app (SwiftUI, iOS 17+, MVVM + Repository + Service). Xcode project generated via XcodeGen. |
| `admin/` | Next.js 14 App Router CMS (TypeScript, Tailwind, shadcn/ui, Supabase). |
| `android/` | Android app (Kotlin/Compose). Auth-only skeleton (Phase 5). |
| `supabase/` | Postgres migrations, RLS policies, seed data, Edge Functions. |
| `shared/schemas/` | Exercise-type JSON schemas shared by iOS engine + admin. |
| `docs/` | Vision, roadmap, gamification, monetization. |
| `CLAUDE*.md` | Conventions + subsystem specs (source of truth). |

## Quick start

### Backend (Supabase)
```bash
cd supabase
supabase start          # boots local Postgres + Studio (Docker required)
supabase db reset       # applies migrations + seed.sql
supabase functions serve
```

### Admin (Next.js)
```bash
cd admin
cp .env.local.example .env.local   # fill in Supabase URL + keys
pnpm install
pnpm dev                           # http://localhost:3000
```

### iOS
Requires XcodeGen (`brew install xcodegen`).
```bash
cd ios/MediLingo
xcodegen generate                  # produces MediLingo.xcodeproj
open MediLingo.xcodeproj
```
Provide `Resources/Secrets.xcconfig` (see `Resources/Secrets.xcconfig.example`) with `SUPABASE_URL`, `SUPABASE_ANON_KEY`, etc.

### First admin (CMS login)
`admin_users` starts empty. After signing up in the app/admin, promote yourself
from the Supabase SQL editor (service role):
```sql
select public.promote_to_admin('you@example.com');
```

## What you must provide

Everything runs locally against `supabase start` with no keys. To use real AI,
subscriptions, OAuth, or a hosted deployment, you must supply your own
accounts/keys — see **`SETUP.md`** for the full checklist.

## Conventions

Read `CLAUDE.md` first. Per-subsystem specs: `CLAUDE-backend.md`, `CLAUDE-ios.md`, `CLAUDE-admin.md`, `CLAUDE-content.md`.
