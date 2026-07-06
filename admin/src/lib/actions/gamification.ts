"use server";

import { revalidatePath } from "next/cache";
import { z } from "zod";
import { createAdminClient } from "@/lib/supabase/server";
import { assertAdmin } from "@/lib/auth";
import { QUEST_TYPES } from "@/lib/constants";
import type { ActionResult } from "@/lib/actions/content";

function fail(error: string): ActionResult {
  return { ok: false, error };
}

// ── Daily quests ─────────────────────────────────────────────────────────────
const questSchema = z.object({
  title: z.string().min(1),
  description: z.string().min(1),
  quest_type: z.enum(QUEST_TYPES),
  target_value: z.coerce.number().int().min(1),
  xp_reward: z.coerce.number().int().min(0).default(25),
  gem_reward: z.coerce.number().int().min(0).default(5),
});

export async function createQuest(formData: FormData): Promise<ActionResult> {
  const denied = await assertAdmin();
  if (denied) return fail(denied);

  const parsed = questSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) return fail(parsed.error.issues[0]?.message ?? "Invalid input");

  const supabase = createAdminClient();
  const { error } = await supabase.from("daily_quests").insert(parsed.data);
  if (error) return fail(error.message);

  revalidatePath("/quests");
  return { ok: true };
}

export async function updateQuest(id: string, formData: FormData): Promise<ActionResult> {
  const denied = await assertAdmin();
  if (denied) return fail(denied);

  const parsed = questSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) return fail(parsed.error.issues[0]?.message ?? "Invalid input");

  const supabase = createAdminClient();
  const { error } = await supabase.from("daily_quests").update(parsed.data).eq("id", id);
  if (error) return fail(error.message);

  revalidatePath("/quests");
  return { ok: true };
}

export async function toggleQuestActive(id: string, isActive: boolean): Promise<ActionResult> {
  const denied = await assertAdmin();
  if (denied) return fail(denied);

  const supabase = createAdminClient();
  const { error } = await supabase.from("daily_quests").update({ is_active: isActive }).eq("id", id);
  if (error) return fail(error.message);

  revalidatePath("/quests");
  return { ok: true };
}

// ── Achievements ─────────────────────────────────────────────────────────────
// Only presentation + reward fields are editable from the CMS; the requirement
// JSONB drives unlock logic and stays read-only here (seeded via migrations).
const achievementSchema = z.object({
  title: z.string().min(1),
  description: z.string().min(1),
  xp_reward: z.coerce.number().int().min(0),
  gem_reward: z.coerce.number().int().min(0),
});

export async function updateAchievement(id: string, formData: FormData): Promise<ActionResult> {
  const denied = await assertAdmin();
  if (denied) return fail(denied);

  const parsed = achievementSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) return fail(parsed.error.issues[0]?.message ?? "Invalid input");

  // Unchecked checkboxes are absent from FormData — derive the flag directly.
  const is_secret = formData.get("is_secret") === "on";

  const supabase = createAdminClient();
  const { error } = await supabase
    .from("achievements")
    .update({ ...parsed.data, is_secret })
    .eq("id", id);
  if (error) return fail(error.message);

  revalidatePath("/achievements");
  return { ok: true };
}
