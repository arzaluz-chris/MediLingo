import { z } from "zod";

// Zod mirror of /shared/schemas/*.schema.json — the exercise `metadata` shapes.
// Used by the exercise editor forms and the AI content generators to validate
// output before persisting. Extend as more exercise types are implemented.

export const multipleChoiceMeta = z.object({
  shuffle_options: z.boolean().default(true),
  show_audio_for_options: z.boolean().default(false),
});

export const fillInBlankMeta = z.object({
  acceptable_answers: z.array(z.string()).min(1),
  case_sensitive: z.boolean().default(false),
  blank_position: z.enum(["inline", "end"]).default("inline"),
  context: z.string().optional(),
  word_bank: z.array(z.string()).optional(),
});

export const translationMeta = z.object({
  source_language: z.enum(["es", "en"]),
  target_language: z.enum(["es", "en"]),
  source_text: z.string(),
  acceptable_translations: z.array(z.string()).min(1),
  key_terms: z.array(z.string()).optional(),
  use_ai_evaluation: z.boolean().default(false),
});

export const flashcardMeta = z.object({
  front: z.object({ text: z.string(), subtext: z.string().optional() }),
  back: z.object({
    text: z.string(),
    translation: z.string().optional(),
    explanation: z.string().optional(),
    example: z.string().optional(),
  }),
  auto_flip_seconds: z.number().int().nullable().default(null),
  show_pronunciation: z.boolean().default(true),
});

export const pronunciationMeta = z.object({
  word: z.string(),
  phonetic: z.string().optional(),
  minimum_score: z.number().int().min(0).max(100).default(60),
  syllables: z.array(z.string()).optional(),
  definition_es: z.string().optional(),
});

// Registry keyed by exercise_type for lookup in editor forms.
export const EXERCISE_META_SCHEMAS = {
  multiple_choice: multipleChoiceMeta,
  fill_in_blank: fillInBlankMeta,
  translation: translationMeta,
  flashcard: flashcardMeta,
  pronunciation: pronunciationMeta,
} as const;
