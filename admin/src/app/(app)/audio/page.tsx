import { Header } from "@/components/layout/header";
import { AudioUploadForm, AudioRow } from "@/components/content/AudioManager";
import { createAdminClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function AudioPage() {
  const supabase = createAdminClient();
  const { data: clips } = await supabase
    .from("audio_clips")
    .select("id, title, file_url, speaker, accent, is_published")
    .order("created_at", { ascending: false });

  return (
    <>
      <Header title="Audio" />
      <div className="p-6 space-y-6">
        <AudioUploadForm />
        <div className="space-y-2">
          {(clips ?? []).map((c) => <AudioRow key={c.id} clip={c} />)}
          {(clips ?? []).length === 0 && <p className="text-sm text-neutral-500">No audio clips yet.</p>}
        </div>
      </div>
    </>
  );
}
