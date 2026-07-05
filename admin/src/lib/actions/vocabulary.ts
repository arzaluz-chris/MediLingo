"use server";

import { revalidatePath } from "next/cache";
import { z } from "zod";
import { createAdminClient } from "@/lib/supabase/server";
import type { ActionResult } from "@/lib/actions/content";

const schema = z.object({
  word: z.string().min(1),
  translation_es: z.string().min(1),
  definition_en: z.string().min(1),
  example_en: z.string().min(1),
  phonetic: z.string().optional(),
  category: z.string().default("general"),
  difficulty: z.enum(["beginner", "intermediate", "advanced"]).default("beginner"),
});

export async function createVocabulary(formData: FormData): Promise<ActionResult> {
  const parsed = schema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) return { ok: false, error: parsed.error.issues[0]?.message ?? "Invalid input" };

  const supabase = createAdminClient();
  const { error } = await supabase.from("vocabulary").insert(parsed.data);
  if (error) return { ok: false, error: error.message };

  revalidatePath("/vocabulary");
  return { ok: true };
}

export async function toggleVocabPublish(id: string, isPublished: boolean): Promise<ActionResult> {
  const supabase = createAdminClient();
  const { error } = await supabase.from("vocabulary").update({ is_published: isPublished }).eq("id", id);
  if (error) return { ok: false, error: error.message };
  revalidatePath("/vocabulary");
  return { ok: true };
}

export async function deleteVocabulary(id: string): Promise<ActionResult> {
  const supabase = createAdminClient();
  const { error } = await supabase.from("vocabulary").delete().eq("id", id);
  if (error) return { ok: false, error: error.message };
  revalidatePath("/vocabulary");
  return { ok: true };
}
