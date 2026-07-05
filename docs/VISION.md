# MediLingo — Vision & Product Definition

## Problem

Medical English ≠ general English. Healthcare pro say "I have a dog" but no parse "The patient presents with acute onset dyspnea associated with productive cough." No platform target medical English for Spanish-speaking healthcare pros.

## Value Proposition

> Learn English you use in healthcare, not generic English.

Use cases: read papers, talk English-speaking patients, remote medical assistant work, ENARM/USMLE prep, hotel/cruise ship medicine, lab/imaging reports, medical notes.

## Core Beliefs

1. **Content over code** — App = delivery. Content = product.
2. **Platform, not app** — One backend, engine, gamification, CMS power all paths.
3. **Data-driven** — Every decision from analytics. Every interaction measurable.
4. **AI enhances, physician validates** — AI draft, physician approve.
5. **Offline-first** — Healthcare pros have unpredictable schedules.
6. **Native UI** — SwiftUI on iOS, Jetpack Compose on Android (future).
7. **Ship small, iterate weekly** — Weekly content. Bi-weekly features. Measure obsessively.

## Target Users (Priority Order)

| # | Persona | Goals | Pain Points |
|---|---------|-------|-------------|
| 1 | **Medical Students** | ENARM prep, papers, exchange programs | No structured medical English course |
| 2 | **General Practitioners** | Consultations, research, job mobility | No understand English literature |
| 3 | **Specialists** | Conferences, publish papers | Struggle English presentations |
| 4 | **Nurses** | Private hospitals, tourism, cruise ships | Basic English no cover clinical terms |
| 5 | **Medical Assistants (Remote)** | US healthcare companies | Need insurance/billing/HIPAA vocab |
| 6 | **Dentists** | International patients | Dental terminology gap |
| 7 | **Physical Therapists** | Sports medicine, rehab | Exercise/anatomy terminology |
| 8 | **EMTs/Paramedics** | Emergency situations | Rapid-response medical English |

## Onboarding Data Collection

User select during onboarding (drive initial course, difficulty, content focus, daily XP target):

1. **Role** (Student, Doctor, Nurse, Dentist, Therapist, Paramedic, Assistant, Other)
2. **English Level** (Beginner, Intermediate, Advanced)
3. **Primary Goal** (ENARM, Research, Patient Care, Remote Work, Travel Medicine, USMLE, General)
4. **Specialty Interest** (optional)
5. **Daily Commitment** (5 min, 10 min, 15 min, 20+ min)

## Five Learning Pillars

### 1. Medical Vocabulary
Thousands terms by specialty. Each word: pronunciation audio, IPA, translation, contextual example, medical explanation, etymology (Latin/Greek roots).

### 2. Listening
Patient conversations, physician consults, ER/ICU audio, phone calls, radiology reports. Multiple accents/speeds. Dictation mode.

### 3. Reading
Clinical cases, SOAP notes, paper abstracts, lab/imaging reports, prescriptions. Graduated difficulty (simplified → authentic). Annotation mode.

### 4. Speaking (AI-powered)
Speech Framework + server-side AI eval. Scores: pronunciation, fluency, vocabulary, grammar. Role-play: doctor-patient, nurse-physician, phone triage. Accent training.

### 5. Writing
SOAP notes, progress notes, referrals, discharge summaries, patient instructions. AI evaluate structure, terminology, grammar. Template → freeform progression.

## Unique Differentiators

1. **Interactive Clinical Cases** — Full scenarios: history → exam → labs → diagnose → treat. Branching narrative.
2. **AI Patient Simulator** — Natural conversation, adaptive difficulty.
3. **Specialty Learning Paths** — Emergency, Internal Medicine, Pediatrics, Surgery, Cardiology, OB/GYN, ICU, Dermatology, Psychiatry.
4. **Contextual Modes** — ENARM English, Cruise Ship Physician, Hotel Physician, Telemedicine, Medical Assistant, USMLE English.
5. **Medical Pronunciation Engine** — Phoneme-level eval for medical terms.
6. **Medical Abbreviation System** — CBC, CMP, MRI, CT, ECG, NPO, PRN, BID, etc.
7. **Spaced Repetition Flashcards** — SM-2 variant built-in.
8. **Content by Real Physician** — Trust signal. Competitive moat.

## Visual Design Principles

- **NO photographs** — Vector illustrations only.
- **Style**: Duolingo, Headspace, Google Illustrations.
- **Characters**: Dr. James, Dr. Emily, Nurse Sarah, Patient John, Patient Maria, Receptionist Linda.
- **Animations**: Lottie/Rive. Confetti, streak flame, level-up. Under 500KB each.
- **Haptics**: Correct/incorrect, achievements, level ups.
- **Sound**: Subtle effects for XP gain, correct answers, level ups.
- **Reduce motion**: Honor system accessibility setting.

## Security & Compliance

- RLS on ALL tables. HTTPS/TLS. JWT with refresh rotation.
- GDPR-ready: account deletion purge all data.
- Privacy manifest (Apple requirement).
- Rate limiting on AI endpoints. Input validation. Prompt injection prevention.
- Anti-cheat: XP verified server-side.
- **Medical disclaimer**: Educational tool, not medical reference. Shown in onboarding + Settings.

## Long-Term Vision

MediLingo → platform: Nursing, Dentistry, Veterinary, Pharmacy, Radiology, Lab, EMT. Same backend, engine, gamification, CMS. B2B/institutional version with admin dashboards for hospitals and universities.