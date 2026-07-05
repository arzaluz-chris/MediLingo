import { Header } from "@/components/layout/header";
import { VocabularyForm, VocabRow } from "@/components/content/VocabularyManager";
import { createAdminClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function VocabularyPage() {
  const supabase = createAdminClient();
  const { data: words } = await supabase
    .from("vocabulary")
    .select("id, word, translation_es, category, is_published")
    .order("word");

  return (
    <>
      <Header title="Vocabulary" />
      <div className="p-6 space-y-6">
        <VocabularyForm />
        <div className="space-y-2">
          {(words ?? []).map((w) => <VocabRow key={w.id} word={w} />)}
          {(words ?? []).length === 0 && <p className="text-sm text-neutral-500">No vocabulary yet.</p>}
        </div>
      </div>
    </>
  );
}
