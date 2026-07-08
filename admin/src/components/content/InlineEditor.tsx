"use client";

import { useState, useTransition, type FormEvent } from "react";
import { Pencil } from "lucide-react";
import type { ActionResult } from "@/lib/actions/content";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

const selectClass =
  "flex h-10 w-full rounded-md border border-neutral-300 dark:border-neutral-700 bg-transparent px-3 text-sm";

// One editable field. `select` renders a dropdown from `options`.
export type EditField = {
  name: string;
  label: string;
  type?: "text" | "number" | "select";
  options?: readonly string[];
  defaultValue: string | number;
};

// Pencil toggle that reveals an inline form of `fields`; on submit builds a
// FormData and hands it to `submit` (a closure that binds the row id + path).
// Mirrors the AchievementRow edit pattern so the CMS feels consistent.
export function InlineEditor({
  fields, submit, ariaLabel,
}: {
  fields: EditField[];
  submit: (fd: FormData) => Promise<ActionResult>;
  ariaLabel: string;
}) {
  const [editing, setEditing] = useState(false);
  const [pending, start] = useTransition();
  const [error, setError] = useState<string | null>(null);

  function onSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const form = e.currentTarget;
    start(async () => {
      const r = await submit(new FormData(form));
      if (r.ok) { setEditing(false); setError(null); }
      else setError(r.error);
    });
  }

  return (
    <>
      <Button
        variant="ghost"
        size="sm"
        onClick={() => setEditing((v) => !v)}
        aria-label={ariaLabel}
      >
        <Pencil className="h-4 w-4" />
      </Button>

      {editing && (
        <form onSubmit={onSubmit} className="mt-3 grid w-full gap-3 sm:grid-cols-2 basis-full">
          {fields.map((f) => (
            <div key={f.name} className="space-y-1.5">
              <Label>{f.label}</Label>
              {f.type === "select" ? (
                <select name={f.name} className={selectClass} defaultValue={String(f.defaultValue)}>
                  {(f.options ?? []).map((o) => <option key={o} value={o}>{o}</option>)}
                </select>
              ) : (
                <Input name={f.name} type={f.type === "number" ? "number" : "text"} defaultValue={f.defaultValue} />
              )}
            </div>
          ))}
          <div className="sm:col-span-2 flex items-center gap-3">
            <Button type="submit" disabled={pending}>{pending ? "Saving…" : "Save"}</Button>
            {error && <span className="text-sm text-red-500">{error}</span>}
          </div>
        </form>
      )}
    </>
  );
}
