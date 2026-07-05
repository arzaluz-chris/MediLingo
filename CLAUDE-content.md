# CLAUDE-content.md — MediLingo Content Engine, Exercises & AI Specification

> Full spec: exercise engine, content pipeline,
> spaced repetition algorithm, AI integration, clinical case system.

---

## Table of Contents

1. [Content Architecture](#content-architecture)
2. [Exercise Engine Specification](#exercise-engine-specification)
3. [Exercise Type Schemas](#exercise-type-schemas)
4. [Spaced Repetition Algorithm](#spaced-repetition-algorithm)
5. [AI Integration](#ai-integration)
6. [Clinical Case Engine](#clinical-case-engine)
7. [Content Pipeline](#content-pipeline)
8. [Content Versioning](#content-versioning)
9. [Localization Strategy](#localization-strategy)
10. [Visual Design & Characters](#visual-design--characters)
11. [Audio Production Guidelines](#audio-production-guidelines)
12. [Sample Content: Medical English Essentials](#sample-content)

---

## Content Architecture

### Hierarchy

```
Course (e.g., "Medical English Essentials")
  └── Module (e.g., "Patient History")
       └── Lesson (e.g., "Chief Complaint")
            ├── Exercise 1 (Multiple Choice)
            ├── Exercise 2 (Listening)
            ├── Exercise 3 (Fill in Blank)
            ├── Exercise 4 (Pronunciation)
            ├── Exercise 5 (Translation)
            └── Vocabulary Words (linked, not owned)
```

### Content Rules

1. **Everything is data** — No hardcoded exercises. All content from database.
2. **Lessons are atomic** — Each lesson one concept/topic, 3-7 min.
3. **5-10 exercises per lesson** — Enough to learn, not fatigue.
4. **Progressive difficulty** — Within module, lessons get harder.
5. **Spaced review** — App auto-requeues vocabulary for spaced repetition.
6. **Contextual learning** — Vocabulary always taught in medical context, never isolation.
7. **Multimodal** — Every lesson combines reading + listening + active recall. Speaking, writing added for higher difficulty.
8. **Physician-validated** — Every published lesson physician-reviewed.

---

## Exercise Engine Specification

### Exercise Data Model

Every exercise stored as JSON-compatible structure in database. `metadata` JSONB field holds type-specific config.

```typescript
interface Exercise {
  id: string;
  lesson_id: string;
  exercise_type: ExerciseType;
  prompt: string;                    // Main instruction text
  prompt_audio_url?: string;         // Audio for the prompt
  prompt_image_url?: string;         // Image for the prompt
  correct_answer?: string;           // Simple correct answer
  explanation?: string;              // Shown after answering (English)
  explanation_es?: string;           // Explanation in Spanish
  hint?: string;                     // Optional hint
  difficulty: 'beginner' | 'intermediate' | 'advanced';
  xp_reward: number;
  sort_order: number;
  metadata: ExerciseMetadata;        // Type-specific config
  options?: ExerciseOption[];        // For choice-based exercises
}

type ExerciseType =
  | 'multiple_choice'
  | 'image_selection'
  | 'listening'
  | 'pronunciation'
  | 'fill_in_blank'
  | 'sentence_ordering'
  | 'translation'
  | 'flashcard'
  | 'matching'
  | 'typing'
  | 'role_playing'
  | 'ai_conversation'
  | 'clinical_case'
  | 'patient_interview'
  | 'memory_game';

interface ExerciseOption {
  id: string;
  option_text: string;
  option_audio_url?: string;
  option_image_url?: string;
  is_correct: boolean;
  sort_order: number;
  match_pair_id?: string;
}
```

### Exercise Rendering Pipeline

```
1. Client fetches exercises for a lesson (sorted by sort_order)
2. ExerciseContainerView receives an Exercise model
3. Reads exercise_type to determine which view to render
4. Reads metadata for type-specific configuration
5. Renders the appropriate exercise view
6. User interacts and submits answer
7. Answer is validated (client-side for simple types, server-side for AI types)
8. Feedback shown (correct/incorrect + explanation)
9. Result recorded (exercise_attempts table)
10. Next exercise loaded
```

---

## Exercise Type Schemas

### 1. Multiple Choice

```json
{
  "exercise_type": "multiple_choice",
  "prompt": "What does 'dyspnea' mean?",
  "prompt_audio_url": null,
  "correct_answer": "Difficulty breathing",
  "explanation": "'Dyspnea' comes from Greek: dys- (difficult) + pnein (to breathe). It refers to the subjective sensation of difficulty breathing.",
  "explanation_es": "'Dyspnea' viene del griego: dys- (difícil) + pnein (respirar). Se refiere a la sensación subjetiva de dificultad para respirar.",
  "metadata": {
    "shuffle_options": true,
    "show_audio_for_options": false
  },
  "options": [
    { "option_text": "Difficulty breathing", "is_correct": true },
    { "option_text": "Chest pain", "is_correct": false },
    { "option_text": "High blood pressure", "is_correct": false },
    { "option_text": "Rapid heart rate", "is_correct": false }
  ]
}
```

### 2. Image Selection

```json
{
  "exercise_type": "image_selection",
  "prompt": "Select the image that represents 'stethoscope'",
  "metadata": {
    "columns": 2,
    "shuffle_options": true
  },
  "options": [
    { "option_text": "Stethoscope", "option_image_url": "/images/stethoscope.webp", "is_correct": true },
    { "option_text": "Sphygmomanometer", "option_image_url": "/images/bp_cuff.webp", "is_correct": false },
    { "option_text": "Otoscope", "option_image_url": "/images/otoscope.webp", "is_correct": false },
    { "option_text": "Thermometer", "option_image_url": "/images/thermometer.webp", "is_correct": false }
  ]
}
```

### 3. Listening

```json
{
  "exercise_type": "listening",
  "prompt": "Listen to the patient and select what symptom they are describing.",
  "prompt_audio_url": "/audio/patient_chest_pain.m4a",
  "metadata": {
    "allow_replay": true,
    "max_replays": 3,
    "playback_speeds": [0.75, 1.0, 1.25],
    "transcript": "I've been having this sharp pain in my chest for the past two hours. It gets worse when I breathe deeply."
  },
  "options": [
    { "option_text": "Chest pain worsened by deep breathing", "is_correct": true },
    { "option_text": "Abdominal pain after eating", "is_correct": false },
    { "option_text": "Headache with visual changes", "is_correct": false },
    { "option_text": "Back pain radiating to the legs", "is_correct": false }
  ]
}
```

### 4. Pronunciation

```json
{
  "exercise_type": "pronunciation",
  "prompt": "Say this word aloud:",
  "prompt_audio_url": "/audio/pronunciation/tachycardia.m4a",
  "correct_answer": "tachycardia",
  "metadata": {
    "word": "tachycardia",
    "phonetic": "/ˌtækɪˈkɑːrdiə/",
    "minimum_score": 60,
    "syllables": ["ta", "chy", "car", "di", "a"],
    "common_mistakes": [
      { "mistake": "ta-KAR-dia", "correction": "Stress should be on 'car': ta-kee-CAR-dee-ah" }
    ],
    "definition_es": "Frecuencia cardíaca rápida (>100 lpm)"
  }
}
```

### 5. Fill in the Blank

```json
{
  "exercise_type": "fill_in_blank",
  "prompt": "The patient presents with acute onset ___ associated with productive cough.",
  "correct_answer": "dyspnea",
  "metadata": {
    "acceptable_answers": ["dyspnea", "dyspnoea"],
    "case_sensitive": false,
    "blank_position": "inline",
    "context": "clinical_note",
    "word_bank": ["dyspnea", "tachycardia", "hemoptysis", "cyanosis"]
  }
}
```

### 6. Sentence Ordering

```json
{
  "exercise_type": "sentence_ordering",
  "prompt": "Arrange the words to form a correct clinical sentence:",
  "correct_answer": "The patient was admitted with acute myocardial infarction",
  "metadata": {
    "words": ["patient", "The", "acute", "with", "was", "admitted", "myocardial", "infarction"],
    "extra_words": ["chronic", "discharged"],
    "show_punctuation": true
  }
}
```

### 7. Translation

```json
{
  "exercise_type": "translation",
  "prompt": "Translate to English:",
  "metadata": {
    "source_language": "es",
    "target_language": "en",
    "source_text": "El paciente presenta dolor torácico agudo que empeora con la respiración.",
    "acceptable_translations": [
      "The patient presents with acute chest pain that worsens with breathing.",
      "The patient has acute chest pain that gets worse with breathing.",
      "The patient presents acute thoracic pain worsened by breathing."
    ],
    "key_terms": ["chest pain", "acute", "worsens", "breathing"],
    "use_ai_evaluation": true
  }
}
```

### 8. Flashcard

```json
{
  "exercise_type": "flashcard",
  "prompt": "Review this term:",
  "metadata": {
    "front": {
      "text": "CBC",
      "subtext": "Abbreviation"
    },
    "back": {
      "text": "Complete Blood Count",
      "translation": "Biometría hemática completa",
      "explanation": "A blood test that measures red blood cells, white blood cells, hemoglobin, hematocrit, and platelets.",
      "example": "Order a CBC to evaluate for anemia and infection."
    },
    "auto_flip_seconds": null,
    "show_pronunciation": true
  }
}
```

### 9. Matching

```json
{
  "exercise_type": "matching",
  "prompt": "Match the medical term with its meaning:",
  "metadata": {
    "columns": 2,
    "timer_seconds": 60
  },
  "options": [
    { "option_text": "Tachycardia", "match_pair_id": "A", "is_correct": true },
    { "option_text": "Fast heart rate", "match_pair_id": "A", "is_correct": true },
    { "option_text": "Bradycardia", "match_pair_id": "B", "is_correct": true },
    { "option_text": "Slow heart rate", "match_pair_id": "B", "is_correct": true },
    { "option_text": "Hypertension", "match_pair_id": "C", "is_correct": true },
    { "option_text": "High blood pressure", "match_pair_id": "C", "is_correct": true },
    { "option_text": "Hypotension", "match_pair_id": "D", "is_correct": true },
    { "option_text": "Low blood pressure", "match_pair_id": "D", "is_correct": true }
  ]
}
```

### 10. Typing (Free Text)

```json
{
  "exercise_type": "typing",
  "prompt": "Write the English term for: 'Dolor de cabeza'",
  "correct_answer": "headache",
  "metadata": {
    "acceptable_answers": ["headache", "cephalalgia", "cephalgia"],
    "case_sensitive": false,
    "max_length": 100,
    "placeholder": "Type your answer...",
    "show_keyboard_hints": true
  }
}
```

### 11. Role Playing

```json
{
  "exercise_type": "role_playing",
  "prompt": "You are the doctor. Complete the conversation:",
  "metadata": {
    "scenario": "initial_consultation",
    "dialogue": [
      { "speaker": "patient", "text": "Good morning, doctor.", "audio_url": "/audio/rp/greeting.m4a" },
      { "speaker": "doctor", "text": null, "expected": "Good morning. What brings you in today?",
        "acceptable_responses": [
          "Good morning. What brings you in today?",
          "Hello. How can I help you?",
          "Good morning. What seems to be the problem?"
        ]},
      { "speaker": "patient", "text": "I've been having terrible headaches for the past week.",
        "audio_url": "/audio/rp/headache.m4a" },
      { "speaker": "doctor", "text": null,
        "expected": "Can you describe the headaches? Where exactly is the pain?",
        "acceptable_responses": [
          "Can you describe the headache?",
          "Where is the pain located?",
          "Tell me more about the headaches."
        ]}
    ],
    "evaluation_mode": "text_match",
    "use_speech_input": true
  }
}
```

### 12. AI Conversation

```json
{
  "exercise_type": "ai_conversation",
  "prompt": "Conduct a patient interview. The patient has been experiencing shortness of breath.",
  "metadata": {
    "conversation_type": "patient_consultation",
    "patient_profile": {
      "name": "John Smith",
      "age": 58,
      "gender": "male",
      "occupation": "construction worker",
      "chief_complaint": "shortness of breath",
      "history": "Hypertension, Type 2 Diabetes, smoker 20 pack-years",
      "current_symptoms": "Progressive dyspnea on exertion x 3 weeks, orthopnea, bilateral lower extremity edema",
      "personality": "anxious, cooperative"
    },
    "objectives": [
      "Take a focused history",
      "Ask about cardiac risk factors",
      "Assess severity of symptoms",
      "Identify red flags"
    ],
    "target_vocabulary": ["dyspnea", "orthopnea", "edema", "exertion", "onset"],
    "min_turns": 6,
    "max_turns": 15,
    "ai_model": "gemini-2.0-flash",
    "scoring_criteria": {
      "history_completeness": 30,
      "vocabulary_usage": 25,
      "grammar": 20,
      "fluency": 15,
      "professionalism": 10
    }
  }
}
```

### 13. Clinical Case

```json
{
  "exercise_type": "clinical_case",
  "prompt": "A 65-year-old male presents to the Emergency Department.",
  "metadata": {
    "case_id": "em-001",
    "stages": [
      {
        "stage": 1,
        "title": "Initial Presentation",
        "narrative": "A 65-year-old male is brought to the ED by ambulance with complaints of sudden onset crushing chest pain radiating to the left arm. He appears diaphoretic and anxious.",
        "question": "What is your first priority?",
        "options": [
          { "text": "Obtain an ECG immediately", "is_correct": true, "xp": 20, "feedback": "Correct! An ECG should be obtained within 10 minutes of arrival for suspected ACS." },
          { "text": "Order a chest X-ray", "is_correct": false, "xp": 0, "feedback": "A chest X-ray is important but not the first priority in suspected ACS." },
          { "text": "Take a detailed history", "is_correct": false, "xp": 5, "feedback": "History is important but should not delay the ECG in this presentation." },
          { "text": "Administer morphine", "is_correct": false, "xp": 0, "feedback": "Pain management is important but ECG takes priority." }
        ]
      },
      {
        "stage": 2,
        "title": "ECG Results",
        "narrative": "The ECG shows ST elevation in leads II, III, and aVF.",
        "image_url": "/images/cases/stemi_inferior.webp",
        "question": "What is your interpretation?",
        "options": [
          { "text": "Inferior STEMI", "is_correct": true, "xp": 20 },
          { "text": "Anterior STEMI", "is_correct": false, "xp": 0 },
          { "text": "Normal sinus rhythm", "is_correct": false, "xp": 0 },
          { "text": "Atrial fibrillation", "is_correct": false, "xp": 0 }
        ]
      },
      {
        "stage": 3,
        "title": "Management",
        "narrative": "You have confirmed an inferior STEMI. The patient is hemodynamically stable.",
        "question": "Select ALL appropriate initial interventions:",
        "options": [
          { "text": "Aspirin 325 mg", "is_correct": true, "xp": 10 },
          { "text": "Heparin", "is_correct": true, "xp": 10 },
          { "text": "Activate cardiac catheterization lab", "is_correct": true, "xp": 10 },
          { "text": "Supplemental oxygen", "is_correct": true, "xp": 5 },
          { "text": "Oral antibiotics", "is_correct": false, "xp": 0 },
          { "text": "CT abdomen", "is_correct": false, "xp": 0 }
        ],
        "multi_select": true
      }
    ],
    "final_diagnosis": "Inferior ST-Elevation Myocardial Infarction (STEMI)",
    "learning_points": [
      "ECG should be obtained within 10 minutes for suspected ACS",
      "Inferior STEMI shows ST elevation in leads II, III, aVF",
      "Door-to-balloon time should be less than 90 minutes",
      "MONA protocol: Morphine, Oxygen, Nitroglycerin, Aspirin"
    ],
    "target_vocabulary": ["STEMI", "ECG", "catheterization", "aspirin", "heparin", "diaphoretic"]
  }
}
```

### 14. Patient Interview

Like AI Conversation but structured with specific required questions + scoring rubric.

### 15. Memory Game

```json
{
  "exercise_type": "memory_game",
  "prompt": "Match the abbreviation with its meaning:",
  "metadata": {
    "grid_size": "4x3",
    "timer_seconds": 120,
    "pairs": [
      { "card_a": "CBC", "card_b": "Complete Blood Count" },
      { "card_a": "CMP", "card_b": "Comprehensive Metabolic Panel" },
      { "card_a": "MRI", "card_b": "Magnetic Resonance Imaging" },
      { "card_a": "CT", "card_b": "Computed Tomography" },
      { "card_a": "ECG", "card_b": "Electrocardiogram" },
      { "card_a": "NPO", "card_b": "Nothing by Mouth" }
    ]
  }
}
```

---

## Spaced Repetition Algorithm

### SM-2 Variant (SuperMemo 2)

MediLingo uses modified SM-2 algorithm for vocabulary flashcard review.

### Algorithm Implementation

```swift
struct SpacedRepetitionEngine {

    /// Quality ratings:
    /// 0 = Complete blackout (couldn't remember at all)
    /// 1 = Incorrect, but upon seeing answer, remembered
    /// 2 = Incorrect, but answer seemed easy to recall
    /// 3 = Correct with serious difficulty
    /// 4 = Correct after hesitation
    /// 5 = Perfect recall

    struct ReviewResult {
        let newInterval: Int         // days until next review
        let newEaseFactor: Double    // updated ease factor
        let newRepetitions: Int      // updated repetition count
        let newMasteryLevel: Int     // 0-5 mastery level
    }

    static func calculateReview(
        quality: Int,                // 0-5 rating
        repetitions: Int,            // current repetition count
        previousInterval: Int,       // current interval in days
        easeFactor: Double           // current ease factor (default 2.5)
    ) -> ReviewResult {

        var newEF = easeFactor
        var newInterval: Int
        var newReps: Int

        if quality >= 3 {
            // Correct response
            switch repetitions {
            case 0:
                newInterval = 1      // First correct: review tomorrow
            case 1:
                newInterval = 6      // Second correct: review in 6 days
            default:
                newInterval = Int(round(Double(previousInterval) * easeFactor))
            }
            newReps = repetitions + 1
        } else {
            // Incorrect response — reset
            newInterval = 1
            newReps = 0
        }

        // Update ease factor
        // EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
        newEF = easeFactor + (0.1 - Double(5 - quality) * (0.08 + Double(5 - quality) * 0.02))
        newEF = max(1.3, newEF)  // Never go below 1.3

        // Calculate mastery level (0-5) based on consecutive correct + ease factor
        let masteryLevel: Int
        switch newReps {
        case 0: masteryLevel = 0           // New / Reset
        case 1: masteryLevel = 1           // Learning
        case 2...3: masteryLevel = 2       // Familiar
        case 4...6: masteryLevel = 3       // Comfortable
        case 7...10: masteryLevel = 4      // Proficient
        default: masteryLevel = 5          // Mastered
        }

        return ReviewResult(
            newInterval: newInterval,
            newEaseFactor: newEF,
            newRepetitions: newReps,
            newMasteryLevel: masteryLevel
        )
    }
}
```

### Review Scheduling

```swift
// When a user reviews a flashcard:
func processFlashcardReview(vocabularyID: UUID, quality: Int) async throws {
    let mastery = try await flashcardRepository.getMastery(vocabularyID: vocabularyID)

    let result = SpacedRepetitionEngine.calculateReview(
        quality: quality,
        repetitions: mastery.repetitions,
        previousInterval: mastery.intervalDays,
        easeFactor: mastery.easeFactor
    )

    let nextReview = Calendar.current.date(
        byAdding: .day,
        value: result.newInterval,
        to: .now
    )

    // Update vocabulary_mastery
    try await flashcardRepository.updateMastery(
        vocabularyID: vocabularyID,
        masteryLevel: result.newMasteryLevel,
        easeFactor: result.newEaseFactor,
        intervalDays: result.newInterval,
        repetitions: result.newRepetitions,
        nextReviewAt: nextReview
    )

    // Log the review
    try await flashcardRepository.logReview(
        vocabularyID: vocabularyID,
        quality: quality,
        previousInterval: mastery.intervalDays,
        newInterval: result.newInterval,
        previousEase: mastery.easeFactor,
        newEase: result.newEaseFactor
    )
}
```

### Review Queue

```swift
// Fetch cards due for review
func getDueFlashcards(limit: Int = 20) async throws -> [FlashcardItem] {
    // 1. Get cards where next_review_at <= now, ordered by next_review_at ASC
    // 2. Also include NEW cards (never reviewed) — limit to 5 new per session
    // 3. Mix: due reviews first, then new cards
    // 4. Shuffle within each group for variety
}
```

### Mastery Levels Display

| Level | Name | Description | Color |
|-------|------|-------------|-------|
| 0 | New | Never reviewed | Gray |
| 1 | Learning | Reviewed once correctly | Red |
| 2 | Familiar | 2-3 consecutive correct | Orange |
| 3 | Comfortable | 4-6 consecutive correct | Yellow |
| 4 | Proficient | 7-10 consecutive correct | Green |
| 5 | Mastered | 10+ consecutive correct, high ease factor | Blue/Gold |

---

## AI Integration

### AI Provider Abstraction

```swift
protocol AIProvider {
    func chat(messages: [AIMessage], options: AIOptions) async throws -> AIResponse
}

struct AIMessage {
    let role: AIRole        // .system, .user, .assistant
    let content: String
}

struct AIOptions {
    var model: String = "gemini-2.0-flash"
    var temperature: Double = 0.7
    var maxTokens: Int = 1024
    var responseFormat: AIResponseFormat = .text
}

enum AIResponseFormat {
    case text
    case json
}

struct AIResponse {
    let content: String
    let tokensUsed: Int
    let provider: String
}
```

### AI Use Cases in MediLingo

| Use Case | When | AI Provider | Edge Function |
|----------|------|-------------|---------------|
| Patient Simulation | AI Conversation exercise | Gemini/OpenAI | `ai-conversation` |
| Pronunciation Evaluation | After user speaks | Gemini | `evaluate-pronunciation` |
| Exercise Explanation | After wrong answer | Gemini | `generate-exercise-feedback` |
| Translation Evaluation | Free-text translation | OpenAI | via `ai-conversation` |
| Writing Evaluation | SOAP note exercises | Gemini/Claude | `evaluate-writing` |
| Content Generation | Admin panel | Any | `generate-content` |

### System Prompts

#### Patient Simulation

```
You are a virtual patient in MediLingo, a medical English learning app for
Spanish-speaking healthcare professionals.

YOUR ROLE:
- Act as the patient described below
- Respond ONLY in English
- Use natural, realistic patient language (not medical jargon)
- Adapt your language complexity to the user's level: {level}
- If the user makes English errors, subtly model correct phrasing

PATIENT PROFILE:
Name: {name}
Age: {age}
Gender: {gender}
Chief Complaint: {chief_complaint}
History: {history}
Personality: {personality}

RULES:
1. Never break character
2. Never provide medical advice
3. Answer only what is asked
4. Show appropriate emotional responses
5. If asked something unrelated to your visit, redirect politely
6. Include realistic details when describing symptoms
```

#### Pronunciation Evaluation

```
You are a medical English pronunciation evaluator for MediLingo.

TASK: Evaluate the user's pronunciation of the word/phrase: "{expected_text}"

The user said: "{transcription}"
Confidence score from STT: {confidence}

Evaluate:
1. Overall pronunciation score (0-100)
2. Individual word scores (for phrases)
3. Specific phoneme errors
4. Suggestions for improvement
5. Common mistakes for Spanish speakers pronouncing this term

Return JSON:
{
  "overall_score": number,
  "word_scores": [{ "word": string, "score": number }],
  "errors": [{ "phoneme": string, "expected": string, "detected": string }],
  "feedback": string,
  "tips": string[]
}
```

### Rate Limiting & Cost Control

```typescript
// Edge Function rate limiting
const RATE_LIMITS = {
  free_user: {
    ai_conversations_per_day: 3,
    pronunciation_evaluations_per_day: 10,
  },
  premium_user: {
    ai_conversations_per_day: 50,
    pronunciation_evaluations_per_day: 100,
  }
};

// Cost tracking per user per day
// Estimated costs:
// Gemini Flash: ~$0.001 per conversation turn
// OpenAI GPT-4o-mini: ~$0.002 per conversation turn
// Target: < $0.10 per user per month average
```

---

## Clinical Case Engine

### Case Structure

```swift
struct ClinicalCase: Codable {
    let caseID: String
    let title: String
    let specialty: String
    let difficulty: Difficulty
    let patientProfile: PatientProfile
    let stages: [CaseStage]
    let finalDiagnosis: String
    let differentialDiagnoses: [String]
    let learningPoints: [String]
    let targetVocabulary: [String]
    let estimatedMinutes: Int
    let totalXP: Int
}

struct CaseStage: Codable {
    let stageNumber: Int
    let title: String
    let narrative: String               // Story text
    let narrativeAudioURL: String?      // Narrated audio
    let imageURL: String?               // Clinical image (illustration)
    let question: String
    let options: [CaseOption]
    let isMultiSelect: Bool
    let requiredCorrectToAdvance: Bool
}

struct CaseOption: Codable {
    let text: String
    let isCorrect: Bool
    let xpReward: Int
    let feedback: String
}
```

### Case Flow

```
1. Introduction screen: Patient profile + chief complaint (illustration)
2. Stage 1: Read narrative → Answer question → Feedback
3. Stage 2: New information → Answer question → Feedback
4. Stage 3: Results/Labs → Interpret → Answer
5. ... (variable number of stages)
6. Final: Diagnosis reveal → Learning points → Score summary
7. XP awarded based on performance across all stages
```

### Scoring

```
Total Case XP = Σ(stage XP for correct answers)
Bonus XP = First attempt correct on ALL stages → 50% bonus
Time Bonus = Completed under estimated time → 25% bonus
Perfect Case Badge = All stages correct on first attempt
```

---

## Content Pipeline

### Workflow: Idea → Published Lesson

```
1. PLAN
   - Identify topic, specialty, vocabulary focus
   - Define learning objectives (2-3 per lesson)
   - Choose exercise types (variety within lesson)

2. DRAFT (AI-Assisted)
   - Use Admin Panel → AI Tools to generate:
     - Vocabulary entries
     - Exercise drafts (multiple types)
     - Dialogue scripts
     - Clinical case outline
   - AI generates JSON-ready content

3. REVIEW (Physician)
   - Medical accuracy check
   - English quality check
   - Difficulty appropriateness
   - Cultural sensitivity
   - Correct common Spanish-speaker error patterns

4. RECORD (Audio)
   - Record pronunciation for vocabulary
   - Record dialogue audio clips
   - Record listening exercise audio
   - Normalize audio levels

5. ILLUSTRATE (Visual)
   - Create/assign vector illustrations
   - Create Lottie/Rive animations if needed
   - Ensure brand consistency

6. ASSEMBLE (Admin Panel)
   - Create lesson in admin panel
   - Add exercises in correct order
   - Link vocabulary words
   - Upload audio and images
   - Set difficulty, XP, prerequisites

7. TEST
   - Preview on mobile device
   - Check audio playback
   - Verify answer validation
   - Test all exercise types

8. PUBLISH
   - Toggle publish in admin panel
   - Available to all users instantly
   - No App Store update required

9. MONITOR
   - Track completion rates
   - Track accuracy per exercise
   - Track drop-off points
   - Collect user ratings
   - Iterate based on data
```

### Content Calendar

```
Monday:    Plan next week's lessons
Tuesday:   AI draft generation + physician review
Wednesday: Audio recording + illustration
Thursday:  Assembly in admin panel + testing
Friday:    Publish + announce (social media)
Weekend:   Monitor metrics
```

---

## Content Versioning

### Strategy

- Content versioned at **database level** via `updated_at` timestamps
- Major changes (restructuring course) create new records, not modify existing
- Lesson completion data references specific lesson IDs, so changing lesson doesn't invalidate progress
- Substantially changed lesson can be marked "updated", users prompted to re-take

### Breaking Changes

If course structure changes (modules reordered, lessons moved):
1. Create migration that preserves user progress
2. Map old lesson IDs to new lesson IDs
3. Send notification to affected users

---

## Localization Strategy

### Interface Language
- **Spanish** (es-MX) — primary interface language
- Future: Portuguese (pt-BR), English (for bilingual users)

### Content Language
- **Learning content in English** (this is the product)
- **Explanations, translations in Spanish**
- UI elements (buttons, labels, navigation) in Spanish

### Implementation
- Use `Localizable.xcstrings` for iOS
- Content translations stored in database (`explanation_es` fields)
- Admin panel supports editing both English + Spanish content

---

## Visual Design & Characters

### Brand Characters

| Character | Role | Personality | Visual |
|-----------|------|-------------|--------|
| **Dr. James** | Male physician (mentor) | Kind, knowledgeable, encouraging | White coat, stethoscope, warm smile |
| **Dr. Emily** | Female physician | Confident, precise, professional | Scrubs, clipboard |
| **Nurse Sarah** | Nurse | Friendly, supportive, practical | Nursing uniform, warm expression |
| **Patient John** | Male patient | Cooperative, slightly anxious | Hospital gown, everyday appearance |
| **Patient Maria** | Female patient (Latina) | Expressive, relatable | Casual clothing |
| **Receptionist Linda** | Front desk | Efficient, helpful | Professional attire, headset |
| **Dr. Chris** (Easter egg) | The founder | Appears in special lessons | Developer + doctor |

### Illustration Style

- **Vector illustrations** (NO photographs)
- Clean, modern, slightly rounded style
- Inspiration: Duolingo, Headspace, Google Illustrations
- Consistent color palette across all characters, scenes
- Diverse representation (skin tones, body types)
- Medical accuracy in depicted equipment, settings

### Animation Strategy

- **Lottie** for simple animations (checkmarks, celebrations, loading)
- **Rive** for interactive character animations (talking, expressions)
- Correct-answer celebration: confetti burst + XP animation
- Streak flame animation (animated Lottie)
- Level-up cinematic (Rive character celebrating)
- Keep all animations under 500KB
- Reduce motion support: disable animations when system setting on

---

## Audio Production Guidelines

### Technical Specs

| Parameter | Value |
|-----------|-------|
| Format | AAC (.m4a) for production, WAV for masters |
| Sample Rate | 44,100 Hz |
| Bit Depth | 16-bit |
| Channels | Mono |
| Loudness | -16 LUFS (normalized) |
| Noise Floor | Below -60 dB |
| Max File Size | 5 MB per clip |

### Recording Guidelines

1. **Quiet environment** — no background noise
2. **Consistent mic distance** — 15-20 cm
3. **Natural pace** — slightly slower than conversational for beginner content
4. **Clear articulation** — especially medical terminology
5. **American English accent** — primary (British for select content)
6. **Multiple speakers** — different voices for different characters
7. **Emotional range** — patients sound realistic (anxious, calm, in pain)

### File Naming Convention

```
audio/
├── vocabulary/
│   ├── dyspnea.m4a
│   ├── tachycardia.m4a
│   └── leukocytosis.m4a
├── dialogues/
│   ├── er-triage-001.m4a
│   ├── er-triage-002.m4a
│   └── phone-call-specialist-001.m4a
├── listening/
│   ├── patient-chest-pain.m4a
│   └── nurse-handoff-report.m4a
└── pronunciation/
    ├── dyspnea-reference.m4a
    └── tachycardia-reference.m4a
```

---

## Sample Content

### Course: Medical English Essentials

```
Module 1: Greetings & Introduction
  ├── Lesson 1: Meeting the Patient (5 min)
  ├── Lesson 2: Introducing Yourself (5 min)
  ├── Lesson 3: Hospital Roles (5 min)
  └── Lesson 4: Review & Practice (3 min)

Module 2: Chief Complaint
  ├── Lesson 5: "What brings you in today?" (5 min)
  ├── Lesson 6: Common Symptoms (5 min)
  ├── Lesson 7: Pain Description (7 min)
  ├── Lesson 8: Duration & Onset (5 min)
  └── Lesson 9: Review & Clinical Case (7 min)

Module 3: Vital Signs
  ├── Lesson 10: Blood Pressure (5 min)
  ├── Lesson 11: Heart Rate & Temperature (5 min)
  ├── Lesson 12: Respiratory Rate & O2 Sat (5 min)
  └── Lesson 13: Reporting Vitals (5 min)

Module 4: Medical History
  ├── Lesson 14: Past Medical History (7 min)
  ├── Lesson 15: Surgical History (5 min)
  ├── Lesson 16: Medications & Allergies (7 min)
  ├── Lesson 17: Family & Social History (5 min)
  └── Lesson 18: Review & Patient Interview (7 min)

Module 5: Physical Examination
  ├── Lesson 19: General Appearance (5 min)
  ├── Lesson 20: HEENT Exam (7 min)
  ├── Lesson 21: Cardiac & Pulmonary Exam (7 min)
  ├── Lesson 22: Abdominal Exam (5 min)
  ├── Lesson 23: Neurological Basics (7 min)
  └── Lesson 24: Documenting Findings (5 min)

Module 6: Laboratory & Imaging
  ├── Lesson 25: Ordering Labs (5 min)
  ├── Lesson 26: CBC & CMP (7 min)
  ├── Lesson 27: Reading Lab Results (7 min)
  ├── Lesson 28: Imaging Orders (5 min)
  ├── Lesson 29: Imaging Reports (7 min)
  └── Lesson 30: Abbreviations (5 min)

Module 7: Diagnosis & Treatment
  ├── Lesson 31: Differential Diagnosis (7 min)
  ├── Lesson 32: Explaining the Diagnosis (5 min)
  ├── Lesson 33: Treatment Plan (7 min)
  ├── Lesson 34: Medications & Prescriptions (7 min)
  └── Lesson 35: Follow-up Instructions (5 min)

Module 8: Medical Documentation
  ├── Lesson 36: SOAP Notes Introduction (7 min)
  ├── Lesson 37: Writing the S & O (7 min)
  ├── Lesson 38: Writing the A & P (7 min)
  ├── Lesson 39: Progress Notes (5 min)
  └── Lesson 40: Discharge Summary (7 min)

Module 9: Emergency Basics
  ├── Lesson 41: Triage Language (7 min)
  ├── Lesson 42: Emergency Procedures (7 min)
  ├── Lesson 43: Code Blue (5 min)
  ├── Lesson 44: Trauma Assessment (7 min)
  └── Lesson 45: Clinical Case: ER (10 min)

Module 10: Professional Communication
  ├── Lesson 46: Phone Calls & Referrals (7 min)
  ├── Lesson 47: Nurse-Physician Handoff (5 min)
  ├── Lesson 48: Informed Consent (7 min)
  ├── Lesson 49: Difficult Conversations (7 min)
  └── Lesson 50: Final Assessment (10 min)

Total: 50 lessons, ~300 minutes, ~500 exercises, ~500 vocabulary words
```

---

## Improvement Suggestions (Beyond Original Spec)

### 1. Learning Analytics Engine
Recommendation engine suggests next lessons based on:
- Weak areas (exercise types with low accuracy)
- Spaced repetition due cards
- Learning pace
- Time-of-day patterns

### 2. Collaborative Learning
- Study groups / "clinics" where users learn together
- Discussion forums per lesson
- Community-contributed mnemonics

### 3. Certification Exams
- Timed assessment exams per course
- Official MediLingo certificates (PDF, shareable on LinkedIn)
- Badge verification system (QR code on certificate)

### 4. Adaptive Difficulty
- User consistently scores >90% → increase difficulty
- User consistently scores <60% → offer simpler exercises
- Dynamic XP by difficulty: harder = more XP

### 5. Content Personalization
- Track vocabulary categories user struggles with
- Auto-generate review lessons focusing on weak areas
- Personalized daily word selection

### 6. Microlearning Notifications
- Send vocabulary word as push notification
- User "learns" it directly from notification (interactive)
- Counts toward daily quest

### 7. Apple Watch Companion
- Quick flashcard reviews on wrist
- Streak status complication
- Daily word notification

### 8. Podcast Mode
- Auto-generate audio lessons from course content
- Learn while commuting (eyes-free mode)
- Background audio playback support