"use client";

import { useState, useTransition, type FormEvent } from "react";
import { Pencil } from "lucide-react";
import { updateAchievement } from "@/lib/actions/gamification";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent } from "@/components/ui/card";

type Achievement = {
  id: string;
  slug: string;
  title: string;
  description: string;
  category: string;
  xp_reward: number;
  gem_reward: number;
  requirement: unknown;
};

export function AchievementRow({ achievement }: { achievement: Achievement }) {
  const [editing, setEditing] = useState(false);
  const [pending, start] = useTransition();
  const [error, setError] = useState<string | null>(null);

  function onSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const form = e.currentTarget;
    start(async () => {
      const r = await updateAchievement(achievement.id, new FormData(form));
      if (r.ok) {
        setEditing(false);
        setError(null);
      } else {
        setError(r.error);
      }
    });
  }

  return (
    <Card>
      <CardContent className="py-3">
        <div className="flex items-center justify-between gap-4">
          <div className="min-w-0">
            <p className="font-medium truncate">{achievement.title}</p>
            <p className="text-sm text-neutral-500 truncate">
              {achievement.category} · +{achievement.xp_reward} XP · +{achievement.gem_reward} 💎 ·{" "}
              <span className="font-mono text-xs">{JSON.stringify(achievement.requirement)}</span>
            </p>
          </div>
          <Button
            variant="ghost"
            size="sm"
            onClick={() => setEditing((v) => !v)}
            aria-label="Edit achievement rewards"
          >
            <Pencil className="size-4" />
          </Button>
        </div>

        {editing && (
          <form onSubmit={onSubmit} className="mt-4 grid gap-4 sm:grid-cols-2">
            <div className="space-y-1.5">
              <Label>Title</Label>
              <Input name="title" defaultValue={achievement.title} required />
            </div>
            <div className="space-y-1.5">
              <Label>Description</Label>
              <Input name="description" defaultValue={achievement.description} required />
            </div>
            <div className="space-y-1.5">
              <Label>XP reward</Label>
              <Input name="xp_reward" type="number" min={0} defaultValue={achievement.xp_reward} />
            </div>
            <div className="space-y-1.5">
              <Label>Gem reward</Label>
              <Input name="gem_reward" type="number" min={0} defaultValue={achievement.gem_reward} />
            </div>
            <div className="sm:col-span-2 flex items-center gap-3">
              <Button type="submit" disabled={pending}>
                {pending ? "Saving…" : "Save"}
              </Button>
              {error && <span className="text-sm text-red-500">{error}</span>}
            </div>
          </form>
        )}
      </CardContent>
    </Card>
  );
}
