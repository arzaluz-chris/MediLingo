"use client";

import { useQuery } from "@tanstack/react-query";
import type { DailyActiveUsers } from "@/types/analytics";

// Stub: analytics wiring lands in Phase 3. Returns an empty series for now.
export function useDailyActiveUsers() {
  return useQuery({
    queryKey: ["analytics", "dau"],
    queryFn: async (): Promise<DailyActiveUsers[]> => [],
  });
}
