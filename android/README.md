# MediLingo — Android (Phase 5 foundation)

Kotlin + Jetpack Compose, MVVM, Supabase-kt. Mirrors the iOS app's architecture
and brand. **Phase-0-equivalent scaffold**: auth + home shell; features port over
from iOS incrementally.

## Build

Open the `android/` folder in **Android Studio** (Ladybug+), which supplies the
Gradle wrapper + Android SDK, then Run. Or from the CLI once the wrapper is
generated (`gradle wrapper`), `./gradlew :app:assembleDebug`.

> This scaffold was authored without a local Android SDK, so it has not been
> compiled here — verify the first build in Android Studio (it resolves the
> Supabase-kt + Compose dependencies on first sync).

## Configuration

`app/build.gradle.kts` sets `SUPABASE_URL` / `SUPABASE_ANON_KEY` as
`buildConfigField`s. The default URL is `http://10.0.2.2:54321` (the Android
emulator's alias for the host's `127.0.0.1`, i.e. local Supabase). Replace the
anon key placeholder with your project's anon key (or wire via `local.properties`).

## Structure

```
app/src/main/java/app/medilingo/
├── MediLingoApplication.kt   App + DI container
├── MainActivity.kt           Compose host
├── AppDependencies.kt        DI (grows with repositories)
├── data/                     Supabase client + AuthRepository
├── ui/                       Theme + root nav (MediLingoApp)
└── feature/{auth,home}/      Screens + ViewModels
```

## Parity roadmap with iOS

Port next, in order: content repository + course tree, the exercise engine
(9 MVP types), flashcard SM-2 review, gamification (XP/streak/hearts), profile.
Shared source of truth stays the Supabase schema + `/shared/schemas`.
