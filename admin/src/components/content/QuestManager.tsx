"use client";

import { useState, useTransition, type FormEvent } from "react";
import { Eye, EyeOff, Pencil } from "lucide-react";
import { createQuest, toggleQuestActive, updateQuest } from "@/lib/actions/gamification";
import { QUEST_TYPES } from "@/lib/constants";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent } from "@/components/ui/card";

const selectClass =
  "flex h-10 w-full rounded-md border border-neutral-300 dark:border-neutral-700 bg-transparent px-3 text-sm";

type Quest = {
  id: string;
  title: string;
  description: string;
  quest_type: string;
  target_value: number;
  xp_reward: number;
  gem_reward: number;
  is_active: boolean;
};

export function QuestForm() {
  const [pending, start] = useTransition();
  const [error, setError] = useState<string | null>(null);

  function onSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const form = e.currentTarget;
    start(async () => {
      const r = await createQuest(new FormData(form));
      if (r.ok) {
        form.reset();
        setError(null);
      } else {
        setError(r.error);
      }
    });
  }

  return (
    <Card>
      <CardContent className="pt-6">
        <form onSubmit={onSubmit} className="grid gap-4 sm:grid-cols-2">
          <div className="space-y-1.5">
            <Label>Title</Label>
            <Input name="title" required />
          </div>
          <div className="space-y-1.5">
            <Label>Description</Label>
            <Input name="description" required />
          </div>
          <div className="space-y-1.5">
            <Label>Quest type</Label>
            <select name="quest_type" className={selectClass} defaultValue="complete_lessons">
              {QUEST_TYPES.map((t) => (
                <option key={t} value={t}>
                  {t}
                </option>
              ))}
            </select>
          </div>
          <div className="space-y-1.5">
            <Label>Target value</Label>
            <Input name="target_value" type="number" min={1} defaultValue={3} required />
          </div>
          <div className="space-y-1.5">
            <Label>XP reward</Label>
            <Input name="xp_reward" type="number" min={0} defaultValue={25} />
          </div>
          <div className="space-y-1.5">
            <Label>Gem reward</Label>
            <Input name="gem_reward" type="number" min={0} defaultValue={5} />
          </div>
          <div className="sm:col-span-2 flex items-center gap-3">
            <Button type="submit" disabled={pending}>
              {pending ? "Adding…" : "Add quest"}
            </Button>
            {error && <span className="text-sm text-red-500">{error}</span>}
          </div>
        </form>
      </CardContent>
    </Card>
  );
}

export function QuestRow({ quest }: { quest: Quest }) {
  const [pending, start] = useTransition();
  const [active, setActive] = useState(quest.is_active);
  const [editing, setEditing] = useState(false);
  const [error, setError] = useState<string | null>(null);

  function toggle() {
    start(async () => {
      const next = !active;
      const r = await toggleQuestActive(quest.id, next);
      if (r.ok) setActive(next);
    });
  }

  function onSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const form = e.currentTarget;
    start(async () => {
      const r = await updateQuest(quest.id, new FormData(form));
      if (r.ok) { setEditing(false); setError(null); }
      else setError(r.error);
    });
  }

  return (
    <Card>
      <CardContent className="py-3">
        <div className="flex items-center justify-between gap-4">
          <div className="min-w-0">
            <p className="font-medium truncate">{quest.title}</p>
            <p className="text-sm text-neutral-500 truncate">
              {quest.quest_type} · target {quest.target_value} · +{quest.xp_reward} XP · +{quest.gem_reward} 💎
            </p>
          </div>
          <div className="flex items-center gap-1">
            <Button
              variant="ghost"
              size="sm"
              onClick={() => setEditing((v) => !v)}
              aria-label="Edit quest"
            >
              <Pencil className="size-4" />
            </Button>
            <Button
              variant="ghost"
              size="sm"
              onClick={toggle}
              disabled={pending}
              aria-label={active ? "Deactivate quest" : "Activate quest"}
            >
              {active ? <Eye className="size-4" /> : <EyeOff className="size-4 text-neutral-400" />}
            </Button>
          </div>
        </div>

        {editing && (
          <form onSubmit={onSubmit} className="mt-4 grid gap-4 sm:grid-cols-2">
            <div className="space-y-1.5">
              <Label>Title</Label>
              <Input name="title" defaultValue={quest.title} required />
            </div>
            <div className="space-y-1.5">
              <Label>Description</Label>
              <Input name="description" defaultValue={quest.description} required />
            </div>
            <div className="space-y-1.5">
              <Label>Quest type</Label>
              <select name="quest_type" className={selectClass} defaultValue={quest.quest_type}>
                {QUEST_TYPES.map((t) => <option key={t} value={t}>{t}</option>)}
              </select>
            </div>
            <div className="space-y-1.5">
              <Label>Target value</Label>
              <Input name="target_value" type="number" min={1} defaultValue={quest.target_value} required />
            </div>
            <div className="space-y-1.5">
              <Label>XP reward</Label>
              <Input name="xp_reward" type="number" min={0} defaultValue={quest.xp_reward} />
            </div>
            <div className="space-y-1.5">
              <Label>Gem reward</Label>
              <Input name="gem_reward" type="number" min={0} defaultValue={quest.gem_reward} />
            </div>
            <div className="sm:col-span-2 flex items-center gap-3">
              <Button type="submit" disabled={pending}>{pending ? "Saving…" : "Save"}</Button>
              {error && <span className="text-sm text-red-500">{error}</span>}
            </div>
          </form>
        )}
      </CardContent>
    </Card>
  );
}
