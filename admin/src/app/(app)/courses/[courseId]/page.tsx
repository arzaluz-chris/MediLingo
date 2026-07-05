import Link from "next/link";
import { ChevronRight } from "lucide-react";
import { Header } from "@/components/layout/header";
import { Card } from "@/components/ui/card";
import { CreateModuleForm } from "@/components/content/CreateForms";
import { RowControls } from "@/components/content/RowControls";
import { createAdminClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function CoursePage({ params }: { params: Promise<{ courseId: string }> }) {
  const { courseId } = await params;
  const supabase = createAdminClient();
  const { data: course } = await supabase.from("courses").select("*").eq("id", courseId).single();
  const { data: modules } = await supabase.from("modules").select("*").eq("course_id", courseId).order("sort_order");
  const path = `/courses/${courseId}`;

  return (
    <>
      <Header title={course?.title ?? "Course"} />
      <div className="p-6 space-y-6">
        <CreateModuleForm courseId={courseId} />
        <div className="space-y-2">
          {(modules ?? []).map((m) => (
            <Card key={m.id} className="flex items-center justify-between p-4">
              <Link href={`${path}/modules/${m.id}`} className="flex items-center gap-3 flex-1 min-w-0">
                <span className="font-medium truncate">{m.title}</span>
                <span className="text-xs text-neutral-500">{m.slug}</span>
              </Link>
              <div className="flex items-center gap-2">
                <RowControls table="modules" id={m.id} isPublished={m.is_published} revalidate={path} />
                <ChevronRight className="h-4 w-4 text-neutral-400" />
              </div>
            </Card>
          ))}
          {(modules ?? []).length === 0 && <p className="text-sm text-neutral-500">No modules yet.</p>}
        </div>
      </div>
    </>
  );
}
