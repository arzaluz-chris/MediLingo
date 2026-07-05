// Exercise domain types. `metadata` shapes are defined canonically in
// /shared/schemas/*.schema.json and mirrored as Zod in lib/ai/schemas.ts.

import type { MVP_EXERCISE_TYPES } from "@/lib/constants";

export type ExerciseType = (typeof MVP_EXERCISE_TYPES)[number];

export interface ExerciseOption {
  id: string;
  exercise_id: string;
  option_text: string;
  option_audio_url?: string | null;
  option_image_url?: string | null;
  is_correct: boolean;
  sort_order: number;
  match_pair_id?: string | null;
}

export interface Exercise {
  id: string;
  lesson_id: string;
  exercise_type: ExerciseType;
  prompt: string;
  prompt_audio_url?: string | null;
  prompt_image_url?: string | null;
  correct_answer?: string | null;
  explanation?: string | null;
  explanation_es?: string | null;
  hint?: string | null;
  difficulty: "beginner" | "intermediate" | "advanced";
  xp_reward: number;
  sort_order: number;
  metadata: Record<string, unknown>;
  is_published: boolean;
  options?: ExerciseOption[];
}
