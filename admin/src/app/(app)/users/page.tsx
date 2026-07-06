import { Header } from "@/components/layout/header";
import { Card, CardContent } from "@/components/ui/card";
import { createAdminClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function UsersPage() {
  const supabase = createAdminClient();

  // Lightweight read-only roster for the CMS: most recent users + their stats.
  const { data: leaders } = await supabase
    .from("profiles")
    .select("id, display_name, is_premium, user_stats(total_xp, level, current_streak, lessons_completed)")
    .order("created_at", { ascending: false })
    .limit(100);

  type Row = {
    id: string;
    display_name: string;
    is_premium: boolean;
    user_stats: { total_xp: number; level: number; current_streak: number; lessons_completed: number } | null;
  };
  const rows = (leaders ?? []) as unknown as Row[];

  return (
    <>
      <Header title="Users" />
      <div className="p-6 space-y-4">
        <p className="text-sm text-neutral-500">{rows.length} most recent users.</p>
        <Card>
          <CardContent className="p-0 overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="text-left text-neutral-500 border-b border-neutral-200 dark:border-neutral-800">
                <tr>
                  <th className="p-3">Name</th>
                  <th className="p-3">Plan</th>
                  <th className="p-3">Level</th>
                  <th className="p-3">XP</th>
                  <th className="p-3">Streak</th>
                  <th className="p-3">Lessons</th>
                </tr>
              </thead>
              <tbody>
                {rows.map((u) => (
                  <tr key={u.id} className="border-b border-neutral-100 dark:border-neutral-900">
                    <td className="p-3">{u.display_name || "—"}</td>
                    <td className="p-3">{u.is_premium ? "Premium" : "Free"}</td>
                    <td className="p-3">{u.user_stats?.level ?? "—"}</td>
                    <td className="p-3">{u.user_stats?.total_xp ?? 0}</td>
                    <td className="p-3">{u.user_stats?.current_streak ?? 0}</td>
                    <td className="p-3">{u.user_stats?.lessons_completed ?? 0}</td>
                  </tr>
                ))}
                {rows.length === 0 && (
                  <tr>
                    <td className="p-3 text-neutral-500" colSpan={6}>
                      No users yet.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </CardContent>
        </Card>
      </div>
    </>
  );
}
