# MediLingo iOS Redesign — 2026

A full UX + visual redesign of the iOS app. Goal: the polish and engagement of
Duolingo with a professional medical identity — beautiful, minimal, fast,
premium. Inspiration: Duolingo, Apple Health/Fitness, Calm, Headspace, Flighty.

Everything below preserves core functionality: view models, repositories,
services and the exercise engine contracts are untouched (one additive change:
`LearningViewModel` now loads lesson-completion state that the repository
already exposed).

---

## Design System (DesignSystem/)

### What was wrong

- **Hardcoded dark palette.** `mlBackground` was a fixed dark navy — the app
  ignored Light Mode entirely and fought the system appearance.
- **Fixed-size typography.** `MLFont.title(28)` used `Font.system(size:)`,
  which does not scale with Dynamic Type — an accessibility failure.
- **No elevation, no gradients, no motion language.** Flat surfaces, one corner
  radius used inconsistently, `easeInOut` everywhere.

### The new system

| Token file | Contents |
|---|---|
| `Color+ML.swift` | Adaptive palette (every color resolves for light **and** dark via `UIColor` dynamic providers). Deep blue `mlPrimary`, emerald `mlEmerald`, cyan/mint accents. Surfaces map to the **system grouped background stack** so elevation semantics, high-contrast and dark mode come free. `MLGradient` presets (brand, hero, emerald, streak, premium) — used sparingly. |
| `MLFont.swift` | Typography built **only** on Dynamic Type text styles (`.largeTitle → .caption2`), rounded design for display text, default SF for body. `MLSpacing`, `MLRadius` (continuous corners), `MLShadow` (3 soft levels), `MLMotion` (3 shared spring curves — the whole app moves with one voice). |
| `MLHaptic.swift` | Adds `selection()` and `medium()` so option taps feel like pickers and big moments feel weightier. |

### Component library (all reusable)

- `MLButton` — 56pt min target, gradient primary, `soft`/`outline`/`secondary`/
  `destructive` variants, icon support, spring press-down
  (`MLPressableButtonStyle`, shared by every tappable element).
- `MLCard` / `.mlCardStyle()` / `MLHeroCard` — soft shadow + hairline stroke
  (dark-mode definition), 22–28pt continuous corners; hero variant for gradient
  focal cards.
- `MLProgressBar` — gradient fill + "pill shine" highlight, animated.
- `MLProgressRing` — circular goal/score ring with angular gradient.
- `MLStatPill` / `MLHeartDisplay` / `MLXPBadge` — gamification chips with
  `numericText` content transitions.
- `MLSkeleton` / `MLSkeletonList` — shimmering loading placeholders (static
  under Reduce Motion) replacing bare spinners.
- `MLEmptyState` — friendly tinted-circle icon with one-shot symbol bounce,
  optional action.
- `MLErrorView` — humanized error with retry.
- `MLConfettiView` — Canvas-based celebration (no assets, ~90 particles,
  disabled entirely under Reduce Motion).

---

## Screen-by-screen

### 1. Auth (`AuthView`)

- **Critique:** flat icon + fields floating on a dark void; OAuth buttons were
  generic outlines (Apple's button has HIG requirements); no hierarchy.
- **Redesign:** gradient squircle brand mark with spring entrance → title →
  form in a floating card with icon-labeled fields → "o continúa con" divider →
  Apple button (black in light / white in dark per HIG) and Google button.
  Errors render inline in the form card with an icon.
- **Motion:** hero pop-in; sign-up name field slides in when toggling modes.
- **Accessibility:** fields combine icon+label; keyboard dismisses
  interactively.

### 2. Onboarding (`OnboardingView`)

- **Critique:** bare titles, flat selection tiles, no subtitles explaining why
  each question is asked, hidden back affordance shifting layout.
- **Redesign:** title + purpose subtitle per step; role grid and option rows
  get tinted icon circles that fill with the brand gradient when selected;
  radio affordance (`circle` → `checkmark.circle.fill` with symbol replace);
  steps push left/right with asymmetric transitions; footer CTA floats on
  `.bar` material. Every option got a meaningful SF Symbol.
- **Accessibility:** `.isSelected` traits, combined labels, 44pt+ targets.

### 3. Tab shell + Home (`HomeView`)

- **Critique:** dashboard was three tiny stat cards + quest rows; no focal
  point, no path back into learning, static title.
- **Redesign:** time-aware greeting title; streak + hearts pills in the nav
  bar; three stat tiles (streak/XP/gems); a **gradient "Sigue aprendiendo"
  hero card** that cross-navigates to the Learn tab (new `Tab` enum +
  selection binding); a **daily-goal ring card** (completed quests / total)
  and quest rows with icon states and animated progress. Pull-to-refresh.
- **Motion:** numeric content transitions on stats, symbol-replace on quest
  completion checkmarks.

### 4. Learning path (`LearningView`)

- **Critique:** a flat list of identical "play" rows — no sense of journey,
  progress, or "what's next", the core of a Duolingo-class experience.
- **Redesign:** a **winding vertical path of circular lesson nodes**
  (0, +64, 0, −64 rhythm). Node states from real completion data (repository
  method already existed, now wired): completed = emerald gradient check,
  current = blue gradient star with pulsing halo + "Empieza" balloon,
  upcoming = neutral. Emerald hero header shows course title + X/Y progress.
  Newly unlocked achievements now surface in a **celebration sheet with
  confetti** (data existed, was silently dropped before).
- **Accessibility:** node labels announce state, duration and XP.

### 5. Lesson flow (`LessonFlowView`, `MLExerciseHeader`)

- **Critique:** abrupt exercise swaps; out-of-hearts screen was plain text.
- **Redesign:** exercises slide in from trailing edge; animated gradient
  progress bar; hearts pill. Out-of-hearts got a proper tinted icon state with
  haptic + sound.

### 6. Lesson complete (`LessonCompleteView`)

- **Critique:** static icon + two cards; the single most important
  reward moment had zero celebration.
- **Redesign:** **confetti**, seal pops in with a bouncy spring, stats slide
  up staggered, **XP counts up** with `numericText` transitions, success
  haptic + sound. Reduce Motion: everything appears instantly, no confetti.

### 7. Exercise system (`ExercisePieces` + 10 type views)

- **Critique:** answer state was color-only (WCAG failure for color-blind
  users); the feedback banner was a cramped text row; no haptics on check;
  text fields and chips styled ad hoc per view.
- **Redesign:**
  - `AnswerButton`: card-like choices with press springs, and **icon +
    color** correctness (checkmark/x) — not color alone.
  - `ExerciseFooter`: Duolingo-style **tinted feedback panel** springs up from
    the bottom on check; owns the correct/incorrect **haptic + sound** so all
    10 exercise types feel identical; Continue button flips to
    emerald/red.
  - `ExerciseTextField`, `FlowChips`: shared input + word-bank chips.
  - Listening: big round gradient **speaker button** as the focal point with
    symbol bounce per replay.
  - Sentence ordering: chosen words are **removable chips** (tap to return to
    the bank) instead of an invisible "tap sentence to undo last".
  - Matching: wrong pairs **flash red** briefly; matched tiles turn emerald.
  - Flashcard: real **3D flip** (crossfade under Reduce Motion).
  - Pronunciation: word on a display card, gradient mic with **pulsing ring**
    while recording, score shown in an `MLProgressRing`, state hints.

### 8. Flashcards review (`FlashcardReviewView`)

- **Critique:** flat card, four cramped color-only quality buttons, done-state
  was an empty-state component.
- **Redesign:** **card stack** (two upcoming cards peek behind), 3D flip,
  phonetics on the front, progress bar + counter, SM-2 quality buttons with
  icon + label + color semantics (again/hard/good/easy), and a confetti
  session summary.

### 9. Profile (`ProfileView`)

- **Critique:** floating icon avatar, six identical nav cards visually equal
  to stat cards — no grouping, no identity.
- **Redesign:** identity card with gradient initials avatar, level chip and XP
  pill; 2×2 stat grid with tinted icon squares; navigation consolidated into
  **one grouped card with inset dividers** (Apple Settings pattern); sign-out
  demoted to outline.

### 10. Achievements (`AchievementsView`)

- **Redesign:** summary card with progress ring; unlocked medals get the
  streak gradient medallion, locked stay dimmed with a lock; XP/gem rewards
  aligned trailing.

### 11. Vocabulary (`VocabularyView`)

- **Redesign:** real search field (magnifier, clear button), richer term rows
  (word + phonetic + translation), add-to-deck springs into an emerald
  check with symbol replace + success haptic.

### 12. Referral (`ReferralView`)

- **Redesign:** premium-gradient invite hero, **ticket-style code card** with
  dashed border, gradient share CTA, separate redeem card with inline
  success/error feedback.

### 13. League (`SocialView`)

- **Critique:** rows only; promotion rule was invisible (green rank numbers
  meant nothing).
- **Redesign:** trophy medallion header explaining the weekly stakes, medal
  badges for top 3 (gold/silver/bronze), an explicit **"Zona de ascenso"
  divider** after rank 10, XP bold and trailing.

### 14. Shop (`ShopView`)

- **Redesign:** gradient gem-balance hero with animated count, item cards with
  category icons, capsule buy buttons.

### 15. Paywall (`PaywallView`)

- **Critique:** products rendered as identical primary buttons — no
  comparison, no anchor, benefits list unstyled.
- **Redesign:** premium gradient hero, benefits card with tinted icon circles,
  **selectable pricing cards** with annual pre-selected and a "MEJOR PRECIO"
  badge, one prominent CTA, restore as quiet text link. Standard
  App Store-featured paywall anatomy.

### 16. AI Conversation (`AIConversationView`)

- **Critique:** symmetric rectangles for bubbles, spinner as typing indicator,
  no auto-scroll.
- **Redesign:** chat anatomy — assistant avatar, asymmetric bubble corners
  (`UnevenRoundedRectangle`), user bubbles in the brand gradient, **animated
  three-dot typing indicator**, auto-scroll to latest, material input bar with
  circular gradient send button.

---

## HIG compliance summary

- **Dynamic Type:** every label uses text styles; no fixed font sizes remain.
- **Dark Mode:** all tokens adaptive; surfaces use system grouped backgrounds.
- **Reduce Motion:** confetti, pulses, shimmer, flips and count-ups all check
  `accessibilityReduceMotion` and degrade to static/crossfade.
- **VoiceOver:** interactive elements have labels; composite rows use
  `.accessibilityElement(children: .combine)`; selected states expose
  `.isSelected`; decorative art is hidden.
- **Touch targets:** 44pt minimum everywhere (buttons 56pt).
- **Color:** correctness/status never communicated by color alone.
- **Materials:** `.bar` materials for pinned footers/input bars.

## Follow-ups (not in this pass)

- Swift Charts XP-over-time graph in Profile (needs a history endpoint).
- Streak calendar heatmap on Home (needs daily activity data).
- Word-of-the-day card + widget.
- Lottie brand characters in empty states once illustration assets exist.
