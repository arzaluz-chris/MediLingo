import { Header } from "@/components/layout/header";
import { ComingSoon } from "@/components/shared/coming-soon";

export default function UsersPage() {
  return (
    <>
      <Header title="Users" />
      <div className="p-6">
        <ComingSoon feature="User management" />
      </div>
    </>
  );
}
