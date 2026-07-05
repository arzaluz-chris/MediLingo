import { Header } from "@/components/layout/header";
import { ComingSoon } from "@/components/shared/coming-soon";

export default function CoursesPage() {
  return (
    <>
      <Header title="Courses" />
      <div className="p-6">
        <ComingSoon feature="Course → module → lesson → exercise editor" />
      </div>
    </>
  );
}
