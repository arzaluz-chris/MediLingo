# MediLingo — Gamification System

## Metrics

| Metric | Description | Display |
|--------|-------------|---------|
| **XP** | Experience points from exercises | Profile, Leaderboard |
| **Level** | Overall progression (1→∞) | Profile badge |
| **Streak** | Consecutive learning days | Home screen, notifications |
| **Hearts** | Mistake allowance (refill daily or buy) | Exercise screen |
| **Gems** | Virtual currency (earn from quests, buy via IAP) | Shop, Profile |
| **Coins** | Secondary currency for minor rewards | After exercises |

## XP Table

| Action | XP |
|--------|-----|
| Complete exercise | 10 |
| Complete lesson | 50 |
| Perfect lesson (no mistakes) | 75 |
| Complete daily quest | 25 |
| Win challenge | 40 |
| Clinical case completed | 100 |
| AI conversation (5+ min) | 60 |
| Flashcard review session | 20 |
| Streak milestone (7, 30, 100, 365) | 100–500 |

## Level Progression

```
Formula: XP_required(n) = floor(50 * n^1.5)

Level 1:   0 XP       Level 10:  5,000 XP
Level 2:   100 XP     Level 20:  20,000 XP
Level 3:   250 XP     Level 50:  100,000 XP
Level 5:   1,000 XP   Level 100: 500,000 XP
```

## Engagement Systems

### Daily Streak
Consecutive days with XP earned. Flame animation. Streak freeze buyable with gems. Notifications: reminder at preferred time, "at risk" 2h before midnight.

### Hearts
- Free: 5 max, refill 1 every 4h
- Premium: unlimited
- Wrong answer = -1 heart. 0 hearts = can't continue (paywall trigger)
- Refill with gems (50 gems = full refill)

### Daily Quests
3 objectives/day, random from pool. Examples: "Complete 2 lessons", "Learn 10 new words", "Review 15 flashcards". Refresh at midnight user timezone.

### Achievements (~50 badges)

| Category | Examples |
|----------|----------|
| Streak | 7-Day Streak, 30-Day Streak, 100-Day Streak, 365-Day Streak |
| Learning | First Lesson, 10 Lessons, 50 Lessons, 100 Lessons |
| Vocabulary | 100 Words, 500 Words, 1000 Words |
| Clinical | First Diagnosis, 5 Cases, Perfect Case |
| Social | First Friend, Challenge Won, League Promoted |
| Specialty | Emergency English Certified, Cardiology English Certified |
| Milestone | Level 10, Level 25, Level 50, Level 100 |

Achievement requirement format (JSONB):
```json
{"type": "streak", "value": 7}
{"type": "lessons_completed", "value": 100}
{"type": "course_completed", "course_slug": "emergency-medicine-english"}
```

### Leagues
Weekly competitive leagues. 30 users/group. Rank by weekly XP.

| Tier | Promotion | Demotion |
|------|-----------|----------|
| Bronze | Top 10 → Silver | — |
| Silver | Top 10 → Gold | Bottom 5 → Bronze |
| Gold | Top 10 → Diamond | Bottom 5 → Silver |
| Diamond | Top 10 → Master | Bottom 5 → Gold |
| Master | — | Bottom 5 → Diamond |

Reset weekly (Monday). League assignment via Edge Function cron.

### Friends
Add by username/referral code. See friend progress, streak, level. Leaderboard separate from league.

### Challenges
Head-to-head timed quizzes. Challenger picks lesson. Both complete it. Higher score wins. 40 XP reward. 24h expiration.

### Shop

| Item | Price | Effect |
|------|-------|--------|
| Streak Freeze | 200 gems | Protects streak for 1 day of inactivity |
| Heart Refill | 50 gems | Restores all hearts immediately |
| Double XP (1 hour) | 100 gems | 2x XP for 60 minutes |
| Bonus Lesson Unlock | 150 gems | Unlock 1 premium lesson |
| Avatar Cosmetics | 50–500 gems | Visual customization |

### Certificates
Downloadable/shareable PDF on course completion. Includes: user name, course title, date, score, QR verification. Shareable on LinkedIn.

### Seasonal Events
Themed events (e.g. "Emergency Week", "Cardiology Month"). Exclusive achievements, bonus XP multipliers, limited-time courses, cosmetic rewards.