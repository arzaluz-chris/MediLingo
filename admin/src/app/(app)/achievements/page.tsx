import { Header } from "@/components/layout/header";
import { AchievementRow } from "@/components/content/AchievementManager";
import { createAdminClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function AchievementsPage() {
  const supabase = createAdminClient();
  const { data: achievements } = await supabase
    .from("achievements")
    .select("id, slug, title, description, category, xp_reward, gem_reward, requirement")
    .order("sort_order");

  return (
    <>
      <Header title="Achievements" />
      <div className="p-6 space-y-2">
        <p className="text-sm text-neutral-500">
          Reward and copy are editable; the unlock requirement is seeded via migrations and read-only.
        </p>
        {(achievements ?? []).map((a) => (
          <AchievementRow key={a.id} achievement={a} />
        ))}
        {(achievements ?? []).length === 0 && (
          <p className="text-sm text-neutral-500">No achievements yet.</p>
        )}
      </div>
    </>
  );
}
