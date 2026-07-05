// App-wide constants. No magic strings scattered across components.

export const APP_NAME = "MediLingo Admin";

// Admin roles (mirror of admin_users.role in the DB).
export const ADMIN_ROLES = ["editor", "admin", "super_admin"] as const;
export type AdminRole = (typeof ADMIN_ROLES)[number];

// MVP exercise types (mirror of exercises.exercise_type CHECK + shared/schemas).
export const MVP_EXERCISE_TYPES = [
  "multiple_choice",
  "image_selection",
  "listening",
  "fill_in_blank",
  "translation",
  "sentence_ordering",
  "flashcard",
  "matching",
  "typing",
  "pronunciation",
] as const;

// Primary navigation for the CMS shell.
export const NAV_ITEMS = [
  { href: "/dashboard", label: "Dashboard", icon: "LayoutDashboard" },
  { href: "/courses", label: "Courses", icon: "BookOpen" },
  { href: "/vocabulary", label: "Vocabulary", icon: "Languages" },
  { href: "/audio", label: "Audio", icon: "AudioLines" },
  { href: "/achievements", label: "Achievements", icon: "Trophy" },
  { href: "/quests", label: "Daily Quests", icon: "Target" },
  { href: "/users", label: "Users", icon: "Users" },
  { href: "/analytics", label: "Analytics", icon: "ChartLine" },
  { href: "/settings", label: "Settings", icon: "Settings" },
] as const;
