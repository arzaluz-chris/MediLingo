import { Header } from "@/components/layout/header";
import { QuestForm, QuestRow } from "@/components/content/QuestManager";
import { createAdminClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function QuestsPage() {
  const supabase = createAdminClient();
  const { data: quests } = await supabase
    .from("daily_quests")
    .select("id, title, description, quest_type, target_value, xp_reward, gem_reward, is_active")
    .order("quest_type");

  return (
    <>
      <Header title="Daily Quests" />
      <div className="p-6 space-y-6">
        <QuestForm />
        <div className="space-y-2">
          {(quests ?? []).map((q) => (
            <QuestRow key={q.id} quest={q} />
          ))}
          {(quests ?? []).length === 0 && (
            <p className="text-sm text-neutral-500">No quests yet.</p>
          )}
        </div>
      </div>
    </>
  );
}
