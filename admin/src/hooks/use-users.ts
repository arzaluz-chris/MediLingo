"use client";

import { useQuery } from "@tanstack/react-query";
import { createClient } from "@/lib/supabase/client";
import type { Profile } from "@/types/user";

// Stub: list app users. Real filtering/pagination added in Phase 1.
export function useUsers() {
  return useQuery({
    queryKey: ["users"],
    queryFn: async (): Promise<Profile[]> => {
      const supabase = createClient();
      const { data, error } = await supabase
        .from("profiles")
        .select("id, email, display_name, role, english_level, is_premium, created_at")
        .order("created_at", { ascending: false })
        .limit(50);
      if (error) throw error;
      return (data ?? []) as Profile[];
    },
  });
}
