import { z } from "zod";

// Zod mirror of /shared/schemas/*.schema.json — the exercise `metadata` shapes.
// Used by the exercise editor forms (validate before persisting to the
// exercises.metadata JSONB column) and the AI content generators.
// Keep in lockstep with the canonical JSON Schemas in /shared/schemas.

export const multipleChoiceMeta = z.object({
  shuffle_options: z.boolean().default(true),
  show_audio_for_options: z.boolean().default(false),
});

export const imageSelectionMeta = z.object({
  columns: z.number().int().min(1).max(4).default(2),
  shuffle_options: z.boolean().default(true),
});

const playbackSpeed = z.union([
  z.literal(0.5),
  z.literal(0.75),
  z.literal(1.0),
  z.literal(1.25),
  z.literal(1.5),
]);

export const listeningMeta = z.object({
  allow_replay: z.boolean().default(true),
  max_replays: z.number().int().min(0).default(3),
  playback_speeds: z.array(playbackSpeed).default([0.75, 1.0, 1.25]),
  transcript: z.string().optional(),
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

export const sentenceOrderingMeta = z.object({
  words: z.array(z.string()).min(2),
  extra_words: z.array(z.string()).default([]),
  show_punctuation: z.boolean().default(true),
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

export const matchingMeta = z.object({
  columns: z.number().int().min(2).max(2).default(2),
  timer_seconds: z.number().int().min(0).nullable().default(null),
});

export const typingMeta = z.object({
  acceptable_answers: z.array(z.string()).min(1),
  case_sensitive: z.boolean().default(false),
  max_length: z.number().int().min(1).default(100),
  placeholder: z.string().default("Type your answer..."),
  show_keyboard_hints: z.boolean().default(true),
});

export const pronunciationMeta = z.object({
  word: z.string(),
  phonetic: z.string().optional(),
  minimum_score: z.number().int().min(0).max(100).default(60),
  syllables: z.array(z.string()).optional(),
  common_mistakes: z
    .array(z.object({ mistake: z.string(), correction: z.string() }))
    .optional(),
  definition_es: z.string().optional(),
});

// Registry keyed by exercise_type — one entry per MVP_EXERCISE_TYPES value.
export const EXERCISE_META_SCHEMAS = {
  multiple_choice: multipleChoiceMeta,
  image_selection: imageSelectionMeta,
  listening: listeningMeta,
  fill_in_blank: fillInBlankMeta,
  translation: translationMeta,
  sentence_ordering: sentenceOrderingMeta,
  flashcard: flashcardMeta,
  matching: matchingMeta,
  typing: typingMeta,
  pronunciation: pronunciationMeta,
} as const;

export type ExerciseMetaType = keyof typeof EXERCISE_META_SCHEMAS;

export function isExerciseMetaType(value: string): value is ExerciseMetaType {
  return value in EXERCISE_META_SCHEMAS;
}

// Per-type starter templates used to seed the metadata JSON editor.
export const EXERCISE_META_TEMPLATES: Record<ExerciseMetaType, Record<string, unknown>> = {
  multiple_choice: { shuffle_options: true, show_audio_for_options: false },
  image_selection: { columns: 2, shuffle_options: true },
  listening: { allow_replay: true, max_replays: 3, playback_speeds: [0.75, 1.0, 1.25], transcript: "" },
  fill_in_blank: { acceptable_answers: [""], case_sensitive: false, blank_position: "inline" },
  translation: {
    source_language: "es",
    target_language: "en",
    source_text: "",
    acceptable_translations: [""],
    use_ai_evaluation: false,
  },
  sentence_ordering: { words: ["", ""], extra_words: [], show_punctuation: true },
  flashcard: {
    front: { text: "" },
    back: { text: "", translation: "" },
    auto_flip_seconds: null,
    show_pronunciation: true,
  },
  matching: { columns: 2, timer_seconds: null },
  typing: { acceptable_answers: [""], case_sensitive: false, max_length: 100, placeholder: "Type your answer..." },
  pronunciation: { word: "", phonetic: "", minimum_score: 60 },
};

// Validates a raw JSON string against the schema for the given exercise type.
// Empty input is treated as "{}" so types with all-optional metadata pass.
export function parseExerciseMetadata(
  exerciseType: ExerciseMetaType,
  raw: string,
): { data: Record<string, unknown> } | { error: string } {
  let json: unknown;
  try {
    json = JSON.parse(raw.trim() === "" ? "{}" : raw);
  } catch {
    return { error: "Metadata is not valid JSON" };
  }
  const parsed = EXERCISE_META_SCHEMAS[exerciseType].safeParse(json);
  if (!parsed.success) {
    const issue = parsed.error.issues[0];
    const path = issue?.path.join(".") || "metadata";
    return { error: `Metadata invalid at "${path}": ${issue?.message ?? "unknown error"}` };
  }
  return { data: parsed.data as Record<string, unknown> };
}
