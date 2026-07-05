"use client";

import { useState, useTransition, type FormEvent } from "react";
import { Eye, EyeOff, Trash2 } from "lucide-react";
import { createVocabulary, toggleVocabPublish, deleteVocabulary } from "@/lib/actions/vocabulary";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent } from "@/components/ui/card";

const selectClass = "flex h-10 w-full rounded-md border border-neutral-300 dark:border-neutral-700 bg-transparent px-3 text-sm";
type Word = { id: string; word: string; translation_es: string; category: string; is_published: boolean };

export function VocabularyForm() {
  const [pending, start] = useTransition();
  const [error, setError] = useState<string | null>(null);
  function onSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const form = e.currentTarget;
    start(async () => {
      const r = await createVocabulary(new FormData(form));
      if (r.ok) { form.reset(); setError(null); } else setError(r.error);
    });
  }
  return (
    <Card><CardContent className="pt-6">
      <form onSubmit={onSubmit} className="grid gap-4 sm:grid-cols-2">
        <div className="space-y-1.5"><Label>Word (EN)</Label><Input name="word" required /></div>
        <div className="space-y-1.5"><Label>Translation (ES)</Label><Input name="translation_es" required /></div>
        <div className="space-y-1.5"><Label>Definition (EN)</Label><Input name="definition_en" required /></div>
        <div className="space-y-1.5"><Label>Example (EN)</Label><Input name="example_en" required /></div>
        <div className="space-y-1.5"><Label>Phonetic (IPA)</Label><Input name="phonetic" placeholder="/dɪspˈniːə/" /></div>
        <div className="space-y-1.5">
          <Label>Difficulty</Label>
          <select name="difficulty" className={selectClass} defaultValue="beginner">
            {["beginner", "intermediate", "advanced"].map((d) => <option key={d} value={d}>{d}</option>)}
          </select>
        </div>
        <div className="sm:col-span-2 flex items-center gap-3">
          <Button type="submit" disabled={pending}>{pending ? "Adding…" : "Add word"}</Button>
          {error && <span className="text-sm text-red-500">{error}</span>}
        </div>
      </form>
    </CardContent></Card>
  );
}

export function VocabRow({ word }: { word: Word }) {
  const [pending, start] = useTransition();
  return (
    <Card className="flex items-center justify-between gap-3 p-4">
      <div className="min-w-0">
        <p className="font-medium truncate">{word.word} <span className="text-neutral-500">— {word.translation_es}</span></p>
        <p className="text-xs text-neutral-500">{word.category}</p>
      </div>
      <div className="flex items-center gap-2">
        <Button variant="ghost" size="sm" disabled={pending} aria-label={word.is_published ? "Unpublish" : "Publish"}
          onClick={() => start(async () => { await toggleVocabPublish(word.id, !word.is_published); })}>
          {word.is_published ? <Eye className="h-4 w-4 text-green-500" /> : <EyeOff className="h-4 w-4 text-neutral-400" />}
        </Button>
        <Button variant="ghost" size="sm" disabled={pending} aria-label="Delete"
          onClick={() => start(async () => { if (confirm("Delete word?")) await deleteVocabulary(word.id); })}>
          <Trash2 className="h-4 w-4 text-red-500" />
        </Button>
      </div>
    </Card>
  );
}
