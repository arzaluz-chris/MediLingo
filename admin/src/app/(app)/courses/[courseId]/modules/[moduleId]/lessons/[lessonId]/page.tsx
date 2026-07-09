import { Header } from "@/components/layout/header";
import { Card } from "@/components/ui/card";
import { CreateExerciseForm } from "@/components/content/CreateForms";
import { RowControls } from "@/components/content/RowControls";
import { ExerciseMetaEditor } from "@/components/content/ExerciseMetaEditor";
import { createAdminClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function LessonPage({
  params,
}: {
  params: Promise<{ courseId: string; moduleId: string; lessonId: string }>;
}) {
  const { courseId, moduleId, lessonId } = await params;
  const supabase = createAdminClient();
  const { data: lesson } = await supabase.from("lessons").select("*").eq("id", lessonId).single();
  const { data: exercises } = await supabase
    .from("exercises")
    .select("id, exercise_type, prompt, xp_reward, is_published, metadata")
    .eq("lesson_id", lessonId)
    .order("sort_order");
  const path = `/courses/${courseId}/modules/${moduleId}/lessons/${lessonId}`;

  return (
    <>
      <Header title={lesson?.title ?? "Lesson"} />
      <div className="p-6 space-y-6">
        <CreateExerciseForm lessonId={lessonId} basePath={path} />
        <div className="space-y-2">
          {(exercises ?? []).map((ex) => (
            <Card key={ex.id} className="flex flex-wrap items-center justify-between gap-3 p-4">
              <div className="min-w-0 flex-1">
                <p className="font-medium truncate">{ex.prompt}</p>
                <p className="text-xs text-neutral-500">{ex.exercise_type} · {ex.xp_reward} XP</p>
              </div>
              <div className="flex items-center gap-1">
                <ExerciseMetaEditor id={ex.id} exerciseType={ex.exercise_type} metadata={ex.metadata} revalidate={path} />
                <RowControls table="exercises" id={ex.id} isPublished={ex.is_published} revalidate={path} />
              </div>
            </Card>
          ))}
          {(exercises ?? []).length === 0 && <p className="text-sm text-neutral-500">No exercises yet.</p>}
        </div>
      </div>
    </>
  );
}
