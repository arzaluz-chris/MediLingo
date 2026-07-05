"use client";

import { useRouter } from "next/navigation";
import { LogOut } from "lucide-react";
import { createClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";

export function Header({ title }: { title: string }) {
  const router = useRouter();

  async function signOut() {
    const supabase = createClient();
    await supabase.auth.signOut();
    router.replace("/login");
  }

  return (
    <header className="h-16 shrink-0 border-b border-neutral-200 dark:border-neutral-800 flex items-center justify-between px-6">
      <h1 className="text-lg font-semibold">{title}</h1>
      <Button variant="ghost" size="sm" onClick={signOut} aria-label="Sign out">
        <LogOut className="h-4 w-4" />
        Sign out
      </Button>
    </header>
  );
}
