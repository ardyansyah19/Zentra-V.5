export default function StatCard({ label, value, icon: Icon, tint = 'brand', trend }) {
  const tints = {
    brand: 'bg-brand-500/10 text-brand-600',
    mint: 'bg-mint-500/10 text-mint-600',
    navy: 'bg-navy-900/10 text-navy-800',
    amber: 'bg-amber-500/10 text-amber-600',
  };
  return (
    <div className="card p-5 flex items-start justify-between">
      <div>
        <p className="text-xs font-semibold text-plum-500 uppercase tracking-wide">{label}</p>
        <p className="font-display text-2xl font-extrabold text-navy-900 mt-2 font-mono">{value}</p>
        {trend && <p className="text-xs text-mint-600 font-semibold mt-1.5">{trend}</p>}
      </div>
      <div className={`w-11 h-11 rounded-xl flex items-center justify-center ${tints[tint]}`}>
        <Icon size={20} />
      </div>
    </div>
  );
}
