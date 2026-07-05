"use client";

import { useState, useTransition, type FormEvent } from "react";
import { Eye, EyeOff, Trash2 } from "lucide-react";
import { createAudioClip, toggleAudioPublish, deleteAudioClip } from "@/lib/actions/audio";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent } from "@/components/ui/card";

const selectClass = "flex h-10 w-full rounded-md border border-neutral-300 dark:border-neutral-700 bg-transparent px-3 text-sm";

type Clip = { id: string; title: string; file_url: string; speaker: string; accent: string; is_published: boolean };

export function AudioUploadForm() {
  const [pending, start] = useTransition();
  const [error, setError] = useState<string | null>(null);

  function onSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const form = e.currentTarget;
    const fd = new FormData(form);
    start(async () => {
      const r = await createAudioClip(fd);
      if (r.ok) { form.reset(); setError(null); } else setError(r.error);
    });
  }

  return (
    <Card><CardContent className="pt-6">
      <form onSubmit={onSubmit} className="grid gap-4 sm:grid-cols-2">
        <div className="space-y-1.5"><Label>Title</Label><Input name="title" required /></div>
        <div className="space-y-1.5">
          <Label>Audio file (.m4a)</Label>
          <Input name="file" type="file" accept="audio/*" required />
        </div>
        <div className="space-y-1.5">
          <Label>Speaker</Label>
          <select name="speaker" className={selectClass} defaultValue="narrator">
            {["narrator", "patient", "physician", "nurse", "receptionist", "family", "paramedic", "operator"].map((s) => <option key={s} value={s}>{s}</option>)}
          </select>
        </div>
        <div className="space-y-1.5">
          <Label>Accent</Label>
          <select name="accent" className={selectClass} defaultValue="american">
            {["american", "british", "neutral"].map((a) => <option key={a} value={a}>{a}</option>)}
          </select>
        </div>
        <div className="sm:col-span-2 space-y-1.5"><Label>Transcript (EN)</Label><Input name="transcript_en" /></div>
        <div className="sm:col-span-2 flex items-center gap-3">
          <Button type="submit" disabled={pending}>{pending ? "Uploading…" : "Upload clip"}</Button>
          {error && <span className="text-sm text-red-500">{error}</span>}
        </div>
      </form>
    </CardContent></Card>
  );
}

export function AudioRow({ clip }: { clip: Clip }) {
  const [pending, start] = useTransition();
  return (
    <Card className="flex items-center justify-between gap-3 p-4">
      <div className="min-w-0">
        <p className="font-medium truncate">{clip.title}</p>
        <p className="text-xs text-neutral-500">{clip.speaker} · {clip.accent}</p>
      </div>
      <div className="flex items-center gap-2">
        <audio controls src={clip.file_url} className="h-8" preload="none" />
        <Button variant="ghost" size="sm" disabled={pending} aria-label={clip.is_published ? "Unpublish" : "Publish"}
          onClick={() => start(async () => { await toggleAudioPublish(clip.id, !clip.is_published); })}>
          {clip.is_published ? <Eye className="h-4 w-4 text-green-500" /> : <EyeOff className="h-4 w-4 text-neutral-400" />}
        </Button>
        <Button variant="ghost" size="sm" disabled={pending} aria-label="Delete"
          onClick={() => start(async () => { if (confirm("Delete clip?")) await deleteAudioClip(clip.id); })}>
          <Trash2 className="h-4 w-4 text-red-500" />
        </Button>
      </div>
    </Card>
  );
}
