# MediLingo iOS

SwiftUI app (iOS 17+), MVVM + Repository + Service. The Xcode project is
generated from `project.yml` with [XcodeGen](https://github.com/yonch/xcodegen)
so the `.xcodeproj` is never committed.

## First run

```bash
brew install xcodegen          # one-time
cd ios/MediLingo
xcodegen generate              # produces MediLingo.xcodeproj
open MediLingo.xcodeproj
```

The first build resolves the SPM packages (Supabase, RevenueCat, Lottie,
PostHog, Firebase) — needs network and a few minutes.

## Configuration

`AppConfig` reads `SupabaseURL` / `SupabaseAnonKey` from Info.plist, populated by
`Resources/Secrets.xcconfig` (copy `Secrets.xcconfig.example`). Defaults point at
a local `supabase start` instance, so it runs without secrets for local dev.

## Structure

```
App/            Entry, DI container (AppDependencies), routing, config
Core/
  Models/       Domain value types + SwiftData Cached* cache models
  Services/     Protocols + impls (SupabaseAuthService is wired; rest are stubs)
  Repositories/ Protocols + Phase-0 stub repositories
  Engine/       Exercise engine, SM-2 spaced repetition, lesson flow
DesignSystem/   Colors, typography, haptics, sound, ML* components
Features/       One folder per feature; Auth is wired, others are placeholders
Resources/      Localizable.xcstrings (UI in Spanish), Secrets example
```

## Phase-0 status

- **Wired:** design system, DI, models, exercise/SR engine, email/password auth against Supabase.
- **Stubbed:** all repositories, AI/subscription/analytics/sync services, Apple/Google sign-in, and every feature screen except Auth + the Home tab shell.
- **Swift language mode 5.0** for now; move to 6.0 (strict concurrency) once services adopt full isolation.
