import { Header } from "@/components/layout/header";
import { ComingSoon } from "@/components/shared/coming-soon";

export default function AchievementsPage() {
  return (
    <>
      <Header title="Achievements" />
      <div className="p-6">
        <ComingSoon feature="Achievement editor" />
      </div>
    </>
  );
}
