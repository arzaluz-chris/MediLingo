# SETUP — what you must provide

The code is complete and builds; it runs fully against a **local** Supabase with
no external keys. To use AI, subscriptions, OAuth, analytics, or to deploy, you
must supply the accounts/keys/assets below. Nothing here can be created from
code alone — it needs your accounts, billing, or design assets.

Legend: 🔴 required for a real deployment · 🟡 needed only for that feature ·
🟢 optional / future.

---

## 1. Supabase (hosted) — 🔴

1. Create a project at supabase.com.
2. Link and push: `supabase link --project-ref <ref>` then `supabase db push`.
3. Deploy functions: `supabase functions deploy` (all under `supabase/functions/`).
4. Enable the **pg_cron** and **pg_net** extensions (Dashboard → Database →
   Extensions) so the weekly league rollover fires.
5. Grab the API keys (Dashboard → Settings → API):
   - `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`,
     `SUPABASE_SERVICE_ROLE_KEY` → `admin/.env.local`
   - `SUPABASE_URL`, `SUPABASE_ANON_KEY` → iOS `Resources/Secrets.xcconfig`
6. Create the first admin: sign up, then in the SQL editor run
   `select public.promote_to_admin('you@example.com');`

## 2. AI providers — 🟡 (needed for AI chat, exercise feedback, pronunciation)

At least Gemini. Set as Supabase function secrets
(`supabase secrets set --env-file supabase/functions/.env`; template in
`supabase/functions/.env.example`):
- `GEMINI_API_KEY` — aistudio.google.com (primary)
- `OPENAI_API_KEY` — platform.openai.com (fallback, optional)
- `ANTHROPIC_API_KEY` — console.anthropic.com (fallback, optional)

Without any key the AI Edge Functions return a clean "not configured" error and
the rest of the app works.

## 3. Apple Developer — 🔴 for the App Store, 🟡 for device testing

- **Apple Developer Program** membership ($99/yr).
- **Sign in with Apple**: enable the capability for App ID `com.medilingo.app`
  and add the Services ID as a provider in Supabase (Auth → Providers → Apple).
- **StoreKit subscriptions**: in App Store Connect create the auto-renewable
  products with IDs exactly matching `StoreKitSubscriptionService.productIDs`:
  - `com.medilingo.app.premium.monthly`
  - `com.medilingo.app.premium.annual`
  (Local testing already works via `Resources/Products.storekit`.)
- **APNs** (only for future remote push): an APNs key/cert. Local streak
  reminders need nothing.

## 4. Google Sign-In — 🟡

1. Create an OAuth client (Google Cloud Console).
2. Supabase → Auth → Providers → Google: paste client ID/secret.
3. The iOS callback scheme `com.medilingo.app://callback` is already registered
   in `Info.plist`; add it to the allowed redirect URLs in Supabase Auth.

## 5. RevenueCat — 🟢 (optional; StoreKit works standalone)

Only if you want cross-platform subscription analytics + the server-side premium
mirror:
1. Create a RevenueCat app, wire the StoreKit products.
2. In the iOS client, `Purchases.logIn(<supabase user id>)` so webhook events
   map to the right user (not yet wired — see note below).
3. Set a webhook to `POST <project>/functions/v1/revenuecat-webhook` with header
   `Authorization: Bearer <secret>`, and set the same secret as
   `REVENUECAT_WEBHOOK_SECRET` in the function env.

## 6. Analytics / crash reporting — 🟢

Declared as iOS SPM deps but **not yet wired** (analytics is a no-op stub):
- PostHog: `POSTHOG_API_KEY`
- Firebase Analytics + Crashlytics: `GoogleService-Info.plist`
Provide these when you want the analytics layer implemented.

## 7. Design assets — 🟡 (content/brand)

None are in the repo (vector-only, no photos per brand rules):
- Brand-character **illustrations** (vector).
- **Lottie/Rive** animations (declared dep, none wired).
- **Sound effects** — drop `.wav` files named per `MLSound.filename` into
  `ios/MediLingo/Resources/Sounds/`; playback degrades silently until then.
- **Audio clips** for listening exercises (44.1kHz mono AAC, −16 LUFS).

## 8. Content validation — 🟡 (editorial, not code)

The 10-module curriculum is **AI-drafted, pending physician validation**. A
clinician should review before publishing to real users. Editing happens in the
admin CMS (courses → modules → lessons → exercises), no code change or app
release required.

---

## What is already done (no action needed)

- iOS app: builds green; full exercise engine, gamification, StoreKit 2, native
  Apple/Google sign-in flows, offline cache, referrals, achievements, leagues.
- Backend: 13 migrations, RLS on every table, 8 Edge Functions, server-side
  gamification RPCs (XP/hearts/quests/achievements/leagues cannot be forged),
  premium can only be granted server-side, weekly league cron.
- Admin CMS: auth-gated (admin_users role), full content authoring incl. per-type
  exercise metadata, quests/achievements/users/analytics/settings.
- Content: 10 modules / 50 lessons / 210 exercises / 95 vocabulary terms.

## Known gaps (tracked, non-blocking)

- Analytics/Crashlytics wiring (needs keys, §6).
- RevenueCat client `logIn` call (webhook + tables ready).
- Remote push send path (tables + local reminders ready; needs APNs, §3).
- iOS certificate UI (issue_certificate RPC exists, no screen).
- Full course-tree navigation (currently first course/module surfaced).
- Android beyond auth (Phase 5).
- Automated tests (CI builds/lints all subprojects; no unit tests yet).
