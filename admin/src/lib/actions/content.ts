"use server";

import { revalidatePath } from "next/cache";
import { z } from "zod";
import { createAdminClient } from "@/lib/supabase/server";
import { assertAdmin } from "@/lib/auth";
import { isExerciseMetaType, parseExerciseMetadata } from "@/lib/ai/schemas";

// Content mutations run with the service-role client (bypasses RLS) — this is
// the admin write path (CLAUDE-backend.md § RLS: "content writes are admin-only").
// Every action FIRST verifies the caller is in admin_users (assertAdmin),
// validates input with Zod, then revalidates the affected route.

export type ActionResult = { ok: true } | { ok: false; error: string };

function fail(error: string): ActionResult {
  return { ok: false, error };
}

// ── Courses ────────────────────────────────────────────────────────────────
const courseSchema = z.object({
  slug: z.string().min(1).regex(/^[a-z0-9-]+$/, "lowercase, digits and dashes only"),
  title: z.string().min(1),
  short_desc: z.string().default(""),
  difficulty: z.enum(["beginner", "intermediate", "advanced", "mixed"]).default("beginner"),
});

export async function createCourse(formData: FormData): Promise<ActionResult> {
  const denied = await assertAdmin();
  if (denied) return fail(denied);

  const parsed = courseSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) return fail(parsed.error.issues[0]?.message ?? "Invalid input");

  const supabase = createAdminClient();
  const { error } = await supabase.from("courses").insert(parsed.data);
  if (error) return fail(error.message);

  revalidatePath("/courses");
  return { ok: true };
}

// ── Modules ────────────────────────────────────────────────────────────────
const moduleSchema = z.object({
  course_id: z.string().uuid(),
  slug: z.string().min(1).regex(/^[a-z0-9-]+$/),
  title: z.string().min(1),
  sort_order: z.coerce.number().int().default(0),
});

export async function createModule(formData: FormData): Promise<ActionResult> {
  const denied = await assertAdmin();
  if (denied) return fail(denied);

  const parsed = moduleSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) return fail(parsed.error.issues[0]?.message ?? "Invalid input");

  const supabase = createAdminClient();
  const { error } = await supabase.from("modules").insert(parsed.data);
  if (error) return fail(error.message);

  revalidatePath(`/courses/${parsed.data.course_id}`);
  return { ok: true };
}

// ── Lessons ────────────────────────────────────────────────────────────────
const lessonSchema = z.object({
  module_id: z.string().uuid(),
  slug: z.string().min(1).regex(/^[a-z0-9-]+$/),
  title: z.string().min(1),
  lesson_type: z.enum([
    "standard", "review", "clinical_case", "listening",
    "pronunciation", "writing", "conversation", "test",
  ]).default("standard"),
  xp_reward: z.coerce.number().int().default(50),
  sort_order: z.coerce.number().int().default(0),
});

export async function createLesson(courseId: string, formData: FormData): Promise<ActionResult> {
  const denied = await assertAdmin();
  if (denied) return fail(denied);

  const parsed = lessonSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) return fail(parsed.error.issues[0]?.message ?? "Invalid input");

  const supabase = createAdminClient();
  const { error } = await supabase.from("lessons").insert(parsed.data);
  if (error) return fail(error.message);

  revalidatePath(`/courses/${courseId}/modules/${parsed.data.module_id}`);
  return { ok: true };
}

// ── Exercises (+ options + metadata) ─────────────────────────────────────────
const exerciseSchema = z.object({
  lesson_id: z.string().uuid(),
  exercise_type: z.enum([
    "multiple_choice", "image_selection", "listening", "fill_in_blank",
    "translation", "sentence_ordering", "flashcard", "matching", "typing", "pronunciation",
  ]),
  prompt: z.string().min(1),
  correct_answer: z.string().optional(),
  explanation: z.string().optional(),
  explanation_es: z.string().optional(),
  xp_reward: z.coerce.number().int().default(10),
  sort_order: z.coerce.number().int().default(0),
});

// Options arrive as parallel arrays option_text[] + option_correct[] (checkbox index).
// `metadata` arrives as a JSON string validated against the per-type Zod mirror
// of /shared/schemas (lib/ai/schemas.ts) before landing in the JSONB column.
export async function createExercise(basePath: string, formData: FormData): Promise<ActionResult> {
  const denied = await assertAdmin();
  if (denied) return fail(denied);

  const parsed = exerciseSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) return fail(parsed.error.issues[0]?.message ?? "Invalid input");

  const rawMeta = formData.get("metadata");
  const meta = parseExerciseMetadata(
    parsed.data.exercise_type,
    typeof rawMeta === "string" ? rawMeta : "",
  );
  if ("error" in meta) return fail(meta.error);

  const supabase = createAdminClient();
  const { data: exercise, error } = await supabase
    .from("exercises")
    .insert({ ...parsed.data, metadata: meta.data })
    .select("id")
    .single();
  if (error || !exercise) return fail(error?.message ?? "Insert failed");

  const optionTexts = formData.getAll("option_text").map(String).filter((t) => t.trim() !== "");
  const correctIdx = new Set(formData.getAll("option_correct").map((v) => Number(v)));
  if (optionTexts.length > 0) {
    const rows = optionTexts.map((text, i) => ({
      exercise_id: exercise.id,
      option_text: text,
      is_correct: correctIdx.has(i),
      sort_order: i,
    }));
    const { error: optErr } = await supabase.from("exercise_options").insert(rows);
    if (optErr) return fail(optErr.message);
  }

  revalidatePath(basePath);
  return { ok: true };
}

// ── Inline text edits (course / module / lesson) ─────────────────────────────
// Presentation fields only — publish state and structure keep their own actions.
const courseEditSchema = z.object({
  title: z.string().min(1),
  short_desc: z.string().default(""),
  difficulty: z.enum(["beginner", "intermediate", "advanced", "mixed"]),
  sort_order: z.coerce.number().int().default(0),
});

export async function updateCourse(
  id: string, revalidate: string, formData: FormData,
): Promise<ActionResult> {
  const denied = await assertAdmin();
  if (denied) return fail(denied);

  const parsed = courseEditSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) return fail(parsed.error.issues[0]?.message ?? "Invalid input");

  const supabase = createAdminClient();
  const { error } = await supabase.from("courses").update(parsed.data).eq("id", id);
  if (error) return fail(error.message);

  revalidatePath(revalidate);
  return { ok: true };
}

const moduleEditSchema = z.object({
  title: z.string().min(1),
  slug: z.string().min(1).regex(/^[a-z0-9-]+$/, "lowercase, digits and dashes only"),
  sort_order: z.coerce.number().int().default(0),
});

export async function updateModule(
  id: string, revalidate: string, formData: FormData,
): Promise<ActionResult> {
  const denied = await assertAdmin();
  if (denied) return fail(denied);

  const parsed = moduleEditSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) return fail(parsed.error.issues[0]?.message ?? "Invalid input");

  const supabase = createAdminClient();
  const { error } = await supabase.from("modules").update(parsed.data).eq("id", id);
  if (error) return fail(error.message);

  revalidatePath(revalidate);
  return { ok: true };
}

const lessonEditSchema = z.object({
  title: z.string().min(1),
  slug: z.string().min(1).regex(/^[a-z0-9-]+$/, "lowercase, digits and dashes only"),
  lesson_type: z.enum([
    "standard", "review", "clinical_case", "listening",
    "pronunciation", "writing", "conversation", "test",
  ]),
  xp_reward: z.coerce.number().int().default(50),
  sort_order: z.coerce.number().int().default(0),
});

export async function updateLesson(
  id: string, revalidate: string, formData: FormData,
): Promise<ActionResult> {
  const denied = await assertAdmin();
  if (denied) return fail(denied);

  const parsed = lessonEditSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) return fail(parsed.error.issues[0]?.message ?? "Invalid input");

  const supabase = createAdminClient();
  const { error } = await supabase.from("lessons").update(parsed.data).eq("id", id);
  if (error) return fail(error.message);

  revalidatePath(revalidate);
  return { ok: true };
}

// Edit the metadata JSONB of an existing exercise (validated per-type).
export async function updateExerciseMetadata(
  id: string, exerciseType: string, metadataJson: string, revalidate: string,
): Promise<ActionResult> {
  const denied = await assertAdmin();
  if (denied) return fail(denied);

  if (!isExerciseMetaType(exerciseType)) return fail("Unknown exercise type");
  const meta = parseExerciseMetadata(exerciseType, metadataJson);
  if ("error" in meta) return fail(meta.error);

  const supabase = createAdminClient();
  const { error } = await supabase.from("exercises").update({ metadata: meta.data }).eq("id", id);
  if (error) return fail(error.message);

  revalidatePath(revalidate);
  return { ok: true };
}

// ── Shared: publish toggle + delete ──────────────────────────────────────────
const TABLES = ["courses", "modules", "lessons", "exercises"] as const;
type ContentTable = (typeof TABLES)[number];

export async function togglePublish(
  table: ContentTable, id: string, isPublished: boolean, revalidate: string,
): Promise<ActionResult> {
  const denied = await assertAdmin();
  if (denied) return fail(denied);

  if (!TABLES.includes(table)) return fail("Invalid table");
  const supabase = createAdminClient();
  const patch: Record<string, unknown> = { is_published: isPublished };
  if (table === "courses" && isPublished) patch.published_at = new Date().toISOString();
  const { error } = await supabase.from(table).update(patch).eq("id", id);
  if (error) return fail(error.message);

  revalidatePath(revalidate);
  return { ok: true };
}

export async function deleteRow(
  table: ContentTable, id: string, revalidate: string,
): Promise<ActionResult> {
  const denied = await assertAdmin();
  if (denied) return fail(denied);

  if (!TABLES.includes(table)) return fail("Invalid table");
  const supabase = createAdminClient();
  const { error } = await supabase.from(table).delete().eq("id", id);
  if (error) return fail(error.message);

  revalidatePath(revalidate);
  return { ok: true };
}
