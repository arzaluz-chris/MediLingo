import { Header } from "@/components/layout/header";
import { ComingSoon } from "@/components/shared/coming-soon";

export default function AudioPage() {
  return (
    <>
      <Header title="Audio" />
      <div className="p-6">
        <ComingSoon feature="Audio clip library" />
      </div>
    </>
  );
}
