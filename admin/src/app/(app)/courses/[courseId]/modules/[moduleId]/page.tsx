import Link from "next/link";
import { ChevronRight } from "lucide-react";
import { Header } from "@/components/layout/header";
import { Card } from "@/components/ui/card";
import { CreateLessonForm } from "@/components/content/CreateForms";
import { RowControls } from "@/components/content/RowControls";
import { InlineEditor } from "@/components/content/InlineEditor";
import { updateLesson } from "@/lib/actions/content";
import { LESSON_TYPES } from "@/lib/constants";
import { createAdminClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function ModulePage({
  params,
}: {
  params: Promise<{ courseId: string; moduleId: string }>;
}) {
  const { courseId, moduleId } = await params;
  const supabase = createAdminClient();
  const { data: module } = await supabase.from("modules").select("*").eq("id", moduleId).single();
  const { data: lessons } = await supabase.from("lessons").select("*").eq("module_id", moduleId).order("sort_order");
  const path = `/courses/${courseId}/modules/${moduleId}`;

  return (
    <>
      <Header title={module?.title ?? "Module"} />
      <div className="p-6 space-y-6">
        <CreateLessonForm moduleId={moduleId} courseId={courseId} />
        <div className="space-y-2">
          {(lessons ?? []).map((l) => (
            <Card key={l.id} className="flex flex-wrap items-center justify-between gap-y-2 p-4">
              <Link href={`${path}/lessons/${l.id}`} className="flex items-center gap-3 flex-1 min-w-0">
                <span className="font-medium truncate">{l.title}</span>
                <span className="text-xs text-neutral-500">{l.lesson_type} · {l.xp_reward} XP</span>
              </Link>
              <div className="flex items-center gap-2">
                <InlineEditor
                  ariaLabel="Edit lesson"
                  submit={updateLesson.bind(null, l.id, path)}
                  fields={[
                    { name: "title", label: "Title", defaultValue: l.title },
                    { name: "slug", label: "Slug", defaultValue: l.slug },
                    { name: "lesson_type", label: "Type", type: "select", options: LESSON_TYPES, defaultValue: l.lesson_type },
                    { name: "xp_reward", label: "XP reward", type: "number", defaultValue: l.xp_reward },
                    { name: "sort_order", label: "Sort order", type: "number", defaultValue: l.sort_order },
                  ]}
                />
                <RowControls table="lessons" id={l.id} isPublished={l.is_published} revalidate={path} />
                <ChevronRight className="h-4 w-4 text-neutral-400" />
              </div>
            </Card>
          ))}
          {(lessons ?? []).length === 0 && <p className="text-sm text-neutral-500">No lessons yet.</p>}
        </div>
      </div>
    </>
  );
}
