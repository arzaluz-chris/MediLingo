import Link from "next/link";
import { ChevronRight } from "lucide-react";
import { Header } from "@/components/layout/header";
import { Card } from "@/components/ui/card";
import { CreateCourseForm } from "@/components/content/CreateForms";
import { RowControls } from "@/components/content/RowControls";
import { InlineEditor } from "@/components/content/InlineEditor";
import { updateCourse } from "@/lib/actions/content";
import { createAdminClient } from "@/lib/supabase/server";

// Admin reads use the service-role client so drafts (is_published = false) are visible.
export const dynamic = "force-dynamic";

export default async function CoursesPage() {
  const supabase = createAdminClient();
  const { data: courses } = await supabase.from("courses").select("*").order("sort_order");

  return (
    <>
      <Header title="Courses" />
      <div className="p-6 space-y-6">
        <CreateCourseForm />
        <div className="space-y-2">
          {(courses ?? []).map((c) => (
            <Card key={c.id} className="flex flex-wrap items-center justify-between gap-y-2 p-4">
              <Link href={`/courses/${c.id}`} className="flex items-center gap-3 flex-1 min-w-0">
                <span
                  className="h-3 w-3 rounded-full shrink-0"
                  style={{ backgroundColor: c.color_hex }}
                  aria-hidden
                />
                <span className="font-medium truncate">{c.title}</span>
                <span className="text-xs text-neutral-500">{c.slug}</span>
                {!c.is_published && <span className="text-xs rounded bg-neutral-200 dark:bg-neutral-800 px-1.5 py-0.5">draft</span>}
              </Link>
              <div className="flex items-center gap-2">
                <InlineEditor
                  ariaLabel="Edit course"
                  submit={updateCourse.bind(null, c.id, "/courses")}
                  fields={[
                    { name: "title", label: "Title", defaultValue: c.title },
                    { name: "short_desc", label: "Short description", defaultValue: c.short_desc ?? "" },
                    { name: "difficulty", label: "Difficulty", type: "select", options: ["beginner", "intermediate", "advanced", "mixed"], defaultValue: c.difficulty },
                    { name: "sort_order", label: "Sort order", type: "number", defaultValue: c.sort_order },
                  ]}
                />
                <RowControls table="courses" id={c.id} isPublished={c.is_published} revalidate="/courses" />
                <ChevronRight className="h-4 w-4 text-neutral-400" />
              </div>
            </Card>
          ))}
          {(courses ?? []).length === 0 && <p className="text-sm text-neutral-500">No courses yet — create one above.</p>}
        </div>
      </div>
    </>
  );
}
