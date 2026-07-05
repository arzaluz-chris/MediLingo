import type { AdminRole } from "@/lib/constants";

export interface AdminUser {
  user_id: string;
  email: string;
  role: AdminRole;
  created_at: string;
}

export interface Profile {
  id: string;
  email: string;
  display_name: string;
  role: string;
  english_level: "beginner" | "intermediate" | "advanced";
  is_premium: boolean;
  created_at: string;
}
