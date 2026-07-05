# MediLingo

Cross-platform medical-English learning app for Spanish-speaking healthcare professionals. Gamified, AI-powered, content-driven. iOS-first (SwiftUI), Supabase backend, Next.js admin panel.

> **Status:** Phase 0 Foundation scaffold. Buildable/runnable skeletons across all three subprojects; features are stubbed. See `docs/ROADMAP.md` for the full 16-week MVP plan.

## Repository layout

| Path | What |
|------|------|
| `ios/MediLingo/` | iOS app (SwiftUI, iOS 17+, MVVM + Repository + Service). Xcode project generated via XcodeGen. |
| `admin/` | Next.js 14 App Router CMS (TypeScript, Tailwind, shadcn/ui, Supabase). |
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

## Conventions

Read `CLAUDE.md` first. Per-subsystem specs: `CLAUDE-backend.md`, `CLAUDE-ios.md`, `CLAUDE-admin.md`, `CLAUDE-content.md`.
