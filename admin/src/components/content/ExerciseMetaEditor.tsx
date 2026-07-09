"use client";

import { useState, useTransition } from "react";
import { Braces } from "lucide-react";
import { updateExerciseMetadata } from "@/lib/actions/content";
import { isExerciseMetaType, EXERCISE_META_TEMPLATES, type ExerciseMetaType } from "@/lib/ai/schemas";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";

// Inline editor for an existing exercise's metadata JSONB. Prefills with the
// row's current metadata (or the per-type template when empty), validates
// server-side against the type schema before saving.
export function ExerciseMetaEditor({
  id, exerciseType, metadata, revalidate,
}: {
  id: string;
  exerciseType: string;
  metadata: unknown;
  revalidate: string;
}) {
  const editable = isExerciseMetaType(exerciseType);
  const initial = seedJson(exerciseType, metadata);
  const [open, setOpen] = useState(false);
  const [value, setValue] = useState(initial);
  const [pending, start] = useTransition();
  const [error, setError] = useState<string | null>(null);
  const [saved, setSaved] = useState(false);

  if (!editable) return null; // unschematized types have no editable metadata here

  function save() {
    start(async () => {
      const r = await updateExerciseMetadata(id, exerciseType, value, revalidate);
      if (r.ok) { setError(null); setSaved(true); setOpen(false); }
      else { setError(r.error); setSaved(false); }
    });
  }

  return (
    <>
      <Button
        variant="ghost"
        size="sm"
        onClick={() => { setOpen((v) => !v); setSaved(false); }}
        aria-label="Edit exercise metadata"
      >
        <Braces className="h-4 w-4" />
      </Button>

      {open && (
        <div className="mt-3 w-full basis-full space-y-2">
          <Label>Metadata (JSON — validated against the {exerciseType} schema)</Label>
          <Textarea
            value={value}
            onChange={(e) => setValue(e.target.value)}
            rows={10}
            spellCheck={false}
            className="font-mono text-xs"
          />
          <div className="flex items-center gap-3">
            <Button type="button" onClick={save} disabled={pending}>{pending ? "Saving…" : "Save metadata"}</Button>
            {error && <span className="text-sm text-red-500">{error}</span>}
            {saved && <span className="text-sm text-green-500">Saved</span>}
          </div>
        </div>
      )}
    </>
  );
}

// Pretty-print the current metadata; fall back to the type template if empty.
function seedJson(exerciseType: string, metadata: unknown): string {
  const isEmpty =
    metadata == null ||
    (typeof metadata === "object" && Object.keys(metadata as object).length === 0);
  if (isEmpty && isExerciseMetaType(exerciseType)) {
    return JSON.stringify(EXERCISE_META_TEMPLATES[exerciseType as ExerciseMetaType], null, 2);
  }
  return JSON.stringify(metadata ?? {}, null, 2);
}
