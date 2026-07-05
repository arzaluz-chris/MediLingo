"use client";

import { useQuery } from "@tanstack/react-query";
import { createClient } from "@/lib/supabase/client";
import type { Course } from "@/types/content";

// Fetch all courses (admin sees drafts + published) ordered by sort_order.
export function useCourses() {
  return useQuery({
    queryKey: ["courses"],
    queryFn: async (): Promise<Course[]> => {
      const supabase = createClient();
      const { data, error } = await supabase
        .from("courses")
        .select("*")
        .order("sort_order", { ascending: true });
      if (error) throw error;
      return (data ?? []) as Course[];
    },
  });
}
