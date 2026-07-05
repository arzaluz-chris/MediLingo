import { Sidebar } from "@/components/layout/sidebar";

// Shell for all authenticated CMS routes. Middleware enforces auth; this lays
// out the persistent sidebar + the page content area.
export default function AppLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex flex-1 min-h-full">
      <Sidebar />
      <div className="flex-1 flex flex-col min-w-0">{children}</div>
    </div>
  );
}
