import { Header } from "@/components/layout/header";
import { ComingSoon } from "@/components/shared/coming-soon";

export default function QuestsPage() {
  return (
    <>
      <Header title="Daily Quests" />
      <div className="p-6">
        <ComingSoon feature="Daily quest pool editor" />
      </div>
    </>
  );
}
