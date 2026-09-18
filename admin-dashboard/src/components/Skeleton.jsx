export function Skeleton({ className = '' }) {
  return <div className={`animate-pulse bg-navy-900/[0.06] rounded-lg ${className}`} />;
}

export function StatCardSkeleton() {
  return (
    <div className="card p-5 flex items-start justify-between">
      <div className="space-y-2.5 flex-1">
        <Skeleton className="h-3 w-24" />
        <Skeleton className="h-6 w-20" />
        <Skeleton className="h-3 w-32" />
      </div>
      <Skeleton className="w-11 h-11 rounded-xl shrink-0" />
    </div>
  );
}

export function DashboardSkeleton() {
  return (
    <div>
      <div className="flex items-center justify-between mb-7 gap-4 flex-wrap">
        <div className="space-y-2">
          <Skeleton className="h-7 w-52" />
          <Skeleton className="h-4 w-72" />
        </div>
        <Skeleton className="h-8 w-40 rounded-full" />
      </div>
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4 mb-6">
        {[0, 1, 2, 3].map((i) => <StatCardSkeleton key={i} />)}
      </div>
      <div className="grid grid-cols-1 xl:grid-cols-3 gap-5">
        <div className="xl:col-span-2 card p-6 space-y-4">
          <Skeleton className="h-5 w-56" />
          <Skeleton className="h-[230px] w-full rounded-xl" />
        </div>
        <div className="card p-6 space-y-4">
          <Skeleton className="h-5 w-32" />
          <Skeleton className="h-[200px] w-full rounded-full mx-auto max-w-[200px]" />
        </div>
      </div>
    </div>
  );
}

export function TableRowsSkeleton({ rows = 5, cols = 6 }) {
  return (
    <>
      {Array.from({ length: rows }).map((_, r) => (
        <tr key={r} className="border-b border-navy-900/5 last:border-0">
          {Array.from({ length: cols }).map((_, c) => (
            <td key={c} className="px-5 py-3.5">
              <Skeleton className="h-4 w-full max-w-[120px]" />
            </td>
          ))}
        </tr>
      ))}
    </>
  );
}

export function CardListSkeleton({ count = 3 }) {
  return (
    <div className="space-y-3">
      {Array.from({ length: count }).map((_, i) => (
        <div key={i} className="card p-5 space-y-3">
          <div className="flex items-center justify-between">
            <Skeleton className="h-4 w-40" />
            <Skeleton className="h-6 w-20 rounded-full" />
          </div>
          <Skeleton className="h-14 w-full rounded-lg" />
        </div>
      ))}
    </div>
  );
}
