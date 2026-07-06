import { Header } from "@/components/layout/header";
import { Card, CardContent } from "@/components/ui/card";
import { createAdminClient, createClient as createServerSupabase } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function SettingsPage() {
  const admin = createAdminClient();

  // Who am I (the signed-in admin)?
  const authed = await createServerSupabase();
  const {
    data: { user },
  } = await authed.auth.getUser();

  const { data: adminRow } = user
    ? await admin.from("admin_users").select("email, role, created_at").eq("user_id", user.id).maybeSingle()
    : { data: null };

  const { count: adminCount } = await admin
    .from("admin_users")
    .select("*", { count: "exact", head: true });

  const projectUrl = process.env.NEXT_PUBLIC_SUPABASE_URL ?? "—";
  const aiConfigured = Boolean(process.env.GEMINI_API_KEY || process.env.OPENAI_API_KEY || process.env.ANTHROPIC_API_KEY);

  const rows: { label: string; value: string }[] = [
    { label: "Signed in as", value: adminRow?.email ?? user?.email ?? "—" },
    { label: "Role", value: adminRow?.role ?? "—" },
    { label: "Supabase project", value: projectUrl },
    { label: "Total admins", value: String(adminCount ?? 0) },
  ];

  return (
    <>
      <Header title="Settings" />
      <div className="p-6 space-y-6">
        <Card>
          <CardContent className="divide-y divide-neutral-100 dark:divide-neutral-900 p-0">
            {rows.map((r) => (
              <div key={r.label} className="flex items-center justify-between gap-4 p-4">
                <span className="text-sm text-neutral-500">{r.label}</span>
                <span className="text-sm font-medium break-all text-right">{r.value}</span>
              </div>
            ))}
          </CardContent>
        </Card>

        <Card>
          <CardContent className="pt-6 space-y-2 text-sm">
            <h2 className="font-semibold">Add another admin</h2>
            <p className="text-neutral-500">
              Run this in the Supabase SQL editor (service role) after the person has signed up:
            </p>
            <pre className="rounded-md bg-neutral-100 dark:bg-neutral-900 p-3 overflow-x-auto">
              <code>select public.promote_to_admin(&apos;colleague@example.com&apos;);</code>
            </pre>
            <p className="text-neutral-500">
              AI providers configured on the backend:{" "}
              <span className={aiConfigured ? "text-green-600" : "text-amber-600"}>
                {aiConfigured ? "yes" : "no key set"}
              </span>
              .
            </p>
          </CardContent>
        </Card>
      </div>
    </>
  );
}
