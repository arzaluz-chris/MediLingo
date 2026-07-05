# Shared Exercise Schemas

JSON Schema (draft 2020-12) definitions for the `metadata` JSONB field of each
exercise type. These are the **single source of truth** for the shape of
type-specific exercise config, consumed by:

- the **iOS exercise engine** (`ios/MediLingo/Core/Engine/`) when decoding `metadata`;
- the **admin CMS** (`admin/src/lib/ai/schemas.ts`), which mirrors these as Zod schemas for the exercise editor + AI generators.

## The `exercise_type` → renderer mapping

Every exercise row has an `exercise_type` (see the `exercises.exercise_type`
CHECK constraint in `supabase/migrations/…_initial_schema.sql`). The client
reads that field to pick the view/component, then validates `metadata` against
the matching schema here.

| exercise_type | schema | notes |
|---------------|--------|-------|
| `multiple_choice` | `multiple_choice.schema.json` | options in `exercise_options` |
| `image_selection` | `image_selection.schema.json` | options carry `option_image_url` |
| `listening` | `listening.schema.json` | audio in `exercises.prompt_audio_url` |
| `fill_in_blank` | `fill_in_blank.schema.json` | answer in `exercises.correct_answer` |
| `translation` | `translation.schema.json` | optional AI eval |
| `sentence_ordering` | `sentence_ordering.schema.json` | word tiles |
| `flashcard` | `flashcard.schema.json` | SM-2 spaced repetition |
| `matching` | `matching.schema.json` | pairs grouped by `match_pair_id` |
| `typing` | `typing.schema.json` | free text |
| `pronunciation` | `pronunciation.schema.json` | scored via `evaluate-pronunciation` Edge Function |

## MVP scope

The 10 schemas above are the MVP exercise types. The remaining spec types —
`role_playing`, `ai_conversation`, `clinical_case`, `patient_interview`,
`memory_game` — are Phase 1+/post-MVP and are documented in `CLAUDE-content.md`
but not yet schematized here.

## Validating

Each file is standalone. Validate a metadata object with any draft-2020-12
validator, e.g. [ajv](https://ajv.js.org/):

```bash
npx ajv-cli validate -s multiple_choice.schema.json -d some-metadata.json
```
