import { Header } from "@/components/layout/header";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { createClient } from "@/lib/supabase/server";

// Best-effort content counts. Falls back to "—" before the DB is reachable.
async function getCounts() {
  try {
    const supabase = await createClient();
    const tables = ["courses", "lessons", "exercises", "vocabulary"] as const;
    const results = await Promise.all(
      tables.map((t) => supabase.from(t).select("*", { count: "exact", head: true })),
    );
    return tables.reduce<Record<string, number | null>>((acc, t, i) => {
      acc[t] = results[i].count ?? null;
      return acc;
    }, {});
  } catch {
    return { courses: null, lessons: null, exercises: null, vocabulary: null };
  }
}

export default async function DashboardPage() {
  const counts = await getCounts();
  const cards = [
    { label: "Courses", value: counts.courses },
    { label: "Lessons", value: counts.lessons },
    { label: "Exercises", value: counts.exercises },
    { label: "Vocabulary", value: counts.vocabulary },
  ];

  return (
    <>
      <Header title="Dashboard" />
      <div className="p-6 grid grid-cols-2 lg:grid-cols-4 gap-4">
        {cards.map((c) => (
          <Card key={c.label}>
            <CardHeader>
              <CardTitle className="text-sm font-medium text-neutral-500">{c.label}</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-3xl font-bold">{c.value ?? "—"}</p>
            </CardContent>
          </Card>
        ))}
      </div>
    </>
  );
}
