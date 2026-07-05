import { Header } from "@/components/layout/header";
import { ComingSoon } from "@/components/shared/coming-soon";

export default function SettingsPage() {
  return (
    <>
      <Header title="Settings" />
      <div className="p-6">
        <ComingSoon feature="Admin settings" />
      </div>
    </>
  );
}
