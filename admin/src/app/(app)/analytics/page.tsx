import { Header } from "@/components/layout/header";
import { Card, CardContent } from "@/components/ui/card";
import { createAdminClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function AnalyticsPage() {
  const supabase = createAdminClient();
  const head = { count: "exact" as const, head: true };

  const [users, premium, publishedLessons, publishedExercises, vocab, activeSubs] = await Promise.all([
    supabase.from("profiles").select("*", head).then((r) => r.count ?? 0),
    supabase.from("profiles").select("*", head).eq("is_premium", true).then((r) => r.count ?? 0),
    supabase.from("lessons").select("*", head).eq("is_published", true).then((r) => r.count ?? 0),
    supabase.from("exercises").select("*", head).eq("is_published", true).then((r) => r.count ?? 0),
    supabase.from("vocabulary").select("*", head).then((r) => r.count ?? 0),
    supabase.from("subscriptions").select("*", head).eq("status", "active").then((r) => r.count ?? 0),
  ]);

  const metrics: { label: string; value: number }[] = [
    { label: "Total users", value: users },
    { label: "Premium users", value: premium },
    { label: "Active subscriptions", value: activeSubs },
    { label: "Published lessons", value: publishedLessons },
    { label: "Published exercises", value: publishedExercises },
    { label: "Vocabulary terms", value: vocab },
  ];

  return (
    <>
      <Header title="Analytics" />
      <div className="p-6">
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {metrics.map((m) => (
            <Card key={m.label}>
              <CardContent className="py-6">
                <p className="text-sm text-neutral-500">{m.label}</p>
                <p className="mt-1 text-3xl font-semibold">{m.value.toLocaleString()}</p>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    </>
  );
}
