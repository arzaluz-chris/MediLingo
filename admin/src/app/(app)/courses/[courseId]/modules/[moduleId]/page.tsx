import Link from "next/link";
import { ChevronRight } from "lucide-react";
import { Header } from "@/components/layout/header";
import { Card } from "@/components/ui/card";
import { CreateLessonForm } from "@/components/content/CreateForms";
import { RowControls } from "@/components/content/RowControls";
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
            <Card key={l.id} className="flex items-center justify-between p-4">
              <Link href={`${path}/lessons/${l.id}`} className="flex items-center gap-3 flex-1 min-w-0">
                <span className="font-medium truncate">{l.title}</span>
                <span className="text-xs text-neutral-500">{l.lesson_type} · {l.xp_reward} XP</span>
              </Link>
              <div className="flex items-center gap-2">
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
