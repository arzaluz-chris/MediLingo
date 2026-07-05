import { Header } from "@/components/layout/header";
import { ComingSoon } from "@/components/shared/coming-soon";

export default function AnalyticsPage() {
  return (
    <>
      <Header title="Analytics" />
      <div className="p-6">
        <ComingSoon feature="Content + revenue analytics" />
      </div>
    </>
  );
}
