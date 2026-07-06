"use server";

import { revalidatePath } from "next/cache";
import { z } from "zod";
import { createAdminClient } from "@/lib/supabase/server";
import { assertAdmin } from "@/lib/auth";
import type { ActionResult } from "@/lib/actions/content";

const metaSchema = z.object({
  title: z.string().min(1),
  speaker: z.enum(["narrator", "patient", "physician", "nurse", "receptionist", "family", "paramedic", "operator"]).default("narrator"),
  accent: z.enum(["american", "british", "neutral"]).default("american"),
  transcript_en: z.string().optional(),
});

// Upload an audio file to the public `audio` bucket (service role bypasses
// storage RLS) and create the audio_clips row. Returns NOT ok on any failure.
export async function createAudioClip(formData: FormData): Promise<ActionResult> {
  const denied = await assertAdmin();
  if (denied) return { ok: false, error: denied };

  const file = formData.get("file");
  if (!(file instanceof File) || file.size === 0) return { ok: false, error: "Audio file required" };

  const parsed = metaSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) return { ok: false, error: parsed.error.issues[0]?.message ?? "Invalid input" };

  const supabase = createAdminClient();
  const ext = file.name.split(".").pop() || "m4a";
  const path = `uploads/${crypto.randomUUID()}.${ext}`;

  const { error: upErr } = await supabase.storage.from("audio").upload(path, file, {
    contentType: file.type || "audio/m4a",
    upsert: false,
  });
  if (upErr) return { ok: false, error: `Upload failed: ${upErr.message}` };

  const { data: pub } = supabase.storage.from("audio").getPublicUrl(path);

  const { error } = await supabase.from("audio_clips").insert({
    title: parsed.data.title,
    file_url: pub.publicUrl,
    speaker: parsed.data.speaker,
    accent: parsed.data.accent,
    transcript_en: parsed.data.transcript_en || null,
  });
  if (error) {
    // Roll back the orphaned upload.
    await supabase.storage.from("audio").remove([path]);
    return { ok: false, error: error.message };
  }

  revalidatePath("/audio");
  return { ok: true };
}

export async function toggleAudioPublish(id: string, isPublished: boolean): Promise<ActionResult> {
  const denied = await assertAdmin();
  if (denied) return { ok: false, error: denied };

  const supabase = createAdminClient();
  const { error } = await supabase.from("audio_clips").update({ is_published: isPublished }).eq("id", id);
  if (error) return { ok: false, error: error.message };
  revalidatePath("/audio");
  return { ok: true };
}

export async function deleteAudioClip(id: string): Promise<ActionResult> {
  const denied = await assertAdmin();
  if (denied) return { ok: false, error: denied };

  const supabase = createAdminClient();
  const { error } = await supabase.from("audio_clips").delete().eq("id", id);
  if (error) return { ok: false, error: error.message };
  revalidatePath("/audio");
  return { ok: true };
}
