import { Construction } from "lucide-react";

// Placeholder body for CMS routes not yet implemented (Phase 1+).
export function ComingSoon({ feature }: { feature: string }) {
  return (
    <div className="flex flex-col items-center justify-center gap-3 rounded-xl border border-dashed border-neutral-300 dark:border-neutral-700 p-16 text-center">
      <Construction className="h-8 w-8 text-neutral-400" />
      <p className="text-neutral-600 dark:text-neutral-400">
        <span className="font-medium">{feature}</span> is coming in a later phase.
      </p>
    </div>
  );
}
