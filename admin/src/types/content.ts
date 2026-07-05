// Content domain types (mirror of the content tables). Hand-maintained until
// Supabase type generation is wired (see database.ts).

export interface Course {
  id: string;
  slug: string;
  title: string;
  description: string;
  short_desc: string;
  color_hex: string;
  difficulty: "beginner" | "intermediate" | "advanced" | "mixed";
  category: "general" | "specialty" | "scenario" | "exam_prep" | "professional";
  estimated_hours: number;
  sort_order: number;
  is_premium: boolean;
  is_published: boolean;
  is_featured: boolean;
  created_at: string;
  updated_at: string;
}

export interface Module {
  id: string;
  course_id: string;
  slug: string;
  title: string;
  description: string;
  sort_order: number;
  is_published: boolean;
}

export interface Lesson {
  id: string;
  module_id: string;
  slug: string;
  title: string;
  description: string;
  lesson_type: string;
  difficulty: "beginner" | "intermediate" | "advanced";
  estimated_minutes: number;
  xp_reward: number;
  sort_order: number;
  is_published: boolean;
}
