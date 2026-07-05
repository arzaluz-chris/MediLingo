# MediLingo — Roadmap & MVP Scope

## MVP = "Medical English Essentials" Course

Ship ONE polished learning path with core gamification. Validate retention before expand.

### Must Have (MVP)

- [ ] Onboarding: role, level, goals, daily commitment
- [ ] Course "Medical English Essentials": 10 modules, ~50+ lessons
- [ ] Exercise engine: 8 core types (Multiple Choice, Image Selection, Listening, Fill in Blank, Translation, Sentence Ordering, Flashcard, Matching)
- [ ] Gamification: XP, Levels, Daily Streak, Hearts, Daily Quests, Achievements
- [ ] Vocabulary system: ~500 terms with audio, translation, examples
- [ ] Spaced repetition flashcard review (SM-2)
- [ ] Listening exercises with medical audio
- [ ] Basic pronunciation feedback (Speech Framework)
- [ ] User profile with stats and progress
- [ ] Auth: Sign in with Apple, Google, Email
- [ ] Premium paywall (StoreKit 2)
- [ ] Offline mode for downloaded lessons (Premium)
- [ ] Push notifications (streak reminders)
- [ ] Admin panel: CMS to create/edit courses, modules, lessons, exercises

### Nice to Have (MVP)

- [ ] Clinical Cases (3-5 simplified scenarios)
- [ ] AI Conversation (1 basic scenario)
- [ ] Friends & Leaderboard (basic)
- [ ] Widgets (streak, daily word)

### Post-MVP Phase 2

- [ ] Full AI Patient Simulator
- [ ] Specialty Paths (Emergency, Cardiology)
- [ ] Leagues system
- [ ] Challenges (head-to-head)
- [ ] Certificates
- [ ] Shop (gems economy)
- [ ] Seasonal Events
- [ ] Advanced Analytics Dashboard

### Post-MVP Phase 3

- [ ] Android app (Kotlin + Jetpack Compose)
- [ ] Web app (learner-facing)
- [ ] B2B/Institutional version
- [ ] Advanced clinical cases with branching narratives
- [ ] ENARM mode, USMLE mode
- [ ] Apple Intelligence integration

---

## Milestones

### Phase 0: Foundation (Weeks 1-3)
- [ ] Repo setup, project structure
- [ ] Supabase project + initial migrations
- [ ] iOS scaffold (SwiftUI, SwiftData, MVVM)
- [ ] Design system (colors, typography, core components)
- [ ] Auth flow (Apple, Google, Email)
- [ ] Admin panel scaffold (Next.js + Supabase client)

### Phase 1: Core Engine (Weeks 4-8)
- [ ] Exercise engine (8 types)
- [ ] Course/Module/Lesson data model + rendering
- [ ] Basic gamification (XP, Streak, Hearts)
- [ ] Admin CMS: CRUD for courses, modules, lessons, exercises
- [ ] Audio playback system
- [ ] First 30 lessons created

### Phase 2: Learning Experience (Weeks 9-12)
- [ ] Spaced repetition system
- [ ] Vocabulary system with flashcards
- [ ] Pronunciation evaluation (basic)
- [ ] Listening exercises with medical audio
- [ ] Progress tracking and sync
- [ ] Daily Quests
- [ ] Remaining lessons of "Medical English Essentials"

### Phase 3: Monetization & Polish (Weeks 13-16)
- [ ] StoreKit 2 + RevenueCat
- [ ] Premium paywall
- [ ] Offline mode
- [ ] Achievements system
- [ ] User profile with stats
- [ ] Push notifications
- [ ] Analytics integration
- [ ] App Store submission

### Phase 4: Growth (Weeks 17-24)
- [ ] Leagues and leaderboards
- [ ] Friends system
- [ ] AI Patient Simulator (basic)
- [ ] First specialty path (Emergency Medicine)
- [ ] Clinical Cases (5 scenarios)
- [ ] Certificates
- [ ] Referral program

### Phase 5: Scale (Month 7+)
- [ ] Additional specialty paths
- [ ] Advanced AI features
- [ ] Android development
- [ ] B2B / Institutional
- [ ] Web app (learners)

---

## Performance Budgets

### iOS App

| Metric | Target |
|--------|--------|
| Cold launch | < 2s |
| Warm launch | < 0.5s |
| Exercise load | < 300ms |
| Audio playback start | < 200ms |
| Lesson download (offline) | < 5s |
| Binary size | < 100 MB |
| Memory (active) | < 200 MB |

### Backend

| Metric | Target |
|--------|--------|
| API response (p95) | < 500ms |
| Edge Function cold start | < 1s |
| AI response (conversation) | < 3s |
| DB query (p95) | < 100ms |
| Uptime | 99.9% |

---

## Testing Strategy

| Layer | Type | Tool | Target |
|-------|------|------|--------|
| iOS | Unit | XCTest | 80%+ Services, Repos, Engine |
| iOS | UI | XCUITest | Critical flows |
| iOS | Snapshot | swift-snapshot-testing | Design system |
| Backend | DB | pgTAP / Supabase helpers | All RLS + functions |
| Backend | Edge Functions | Deno test runner | All endpoints |
| Admin | Unit | Jest + RTL | Component logic |
| Admin | E2E | Playwright | Content creation flow |

## CI/CD

```
iOS:    PR → Lint → Unit Tests → Build → UI Tests → TestFlight (on merge)
Admin:  PR → Lint → Type Check → Tests → Preview → Production (on merge)
Supa:   PR → Migration dry-run → Edge Function tests → Apply (on merge)
```