import { Header } from "@/components/layout/header";
import { ComingSoon } from "@/components/shared/coming-soon";

export default function VocabularyPage() {
  return (
    <>
      <Header title="Vocabulary" />
      <div className="p-6">
        <ComingSoon feature="Vocabulary manager" />
      </div>
    </>
  );
}
