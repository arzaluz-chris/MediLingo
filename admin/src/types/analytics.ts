// Analytics domain types (placeholder shapes for the analytics dashboards).

export interface DailyActiveUsers {
  date: string;
  count: number;
}

export interface ContentEngagement {
  lessonId: string;
  lessonTitle: string;
  completions: number;
  averageScore: number;
}
