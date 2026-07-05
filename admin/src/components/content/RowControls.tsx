"use client";

import { useState, useTransition } from "react";
import { Eye, EyeOff, Trash2 } from "lucide-react";
import { togglePublish, deleteRow } from "@/lib/actions/content";
import { Button } from "@/components/ui/button";

type Table = "courses" | "modules" | "lessons" | "exercises";

// Publish toggle + delete for a content row. `revalidate` is the path to refresh.
export function RowControls({
  table, id, isPublished, revalidate, canPublish = true,
}: {
  table: Table; id: string; isPublished: boolean; revalidate: string; canPublish?: boolean;
}) {
  const [pending, start] = useTransition();
  const [error, setError] = useState<string | null>(null);

  return (
    <div className="flex items-center gap-2">
      {error && <span className="text-xs text-red-500">{error}</span>}
      {canPublish && (
        <Button
          variant="ghost"
          size="sm"
          disabled={pending}
          onClick={() =>
            start(async () => {
              const r = await togglePublish(table, id, !isPublished, revalidate);
              setError(r.ok ? null : r.error);
            })
          }
          aria-label={isPublished ? "Unpublish" : "Publish"}
        >
          {isPublished ? <Eye className="h-4 w-4 text-green-500" /> : <EyeOff className="h-4 w-4 text-neutral-400" />}
        </Button>
      )}
      <Button
        variant="ghost"
        size="sm"
        disabled={pending}
        onClick={() =>
          start(async () => {
            if (!confirm("Delete this item and its children?")) return;
            const r = await deleteRow(table, id, revalidate);
            setError(r.ok ? null : r.error);
          })
        }
        aria-label="Delete"
      >
        <Trash2 className="h-4 w-4 text-red-500" />
      </Button>
    </div>
  );
}
