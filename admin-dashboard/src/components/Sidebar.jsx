import { NavLink } from 'react-router-dom';
import { LayoutGrid, Package, ShoppingBag, Users, LogOut, Sparkles } from 'lucide-react';
import { useAuth } from '../context/AuthContext';

const NAV = [
  { to: '/', label: 'Ringkasan', icon: LayoutGrid, end: true },
  { to: '/products', label: 'Produk', icon: Package },
  { to: '/orders', label: 'Pesanan', icon: ShoppingBag },
  { to: '/customers', label: 'Pelanggan', icon: Users },
];

export default function Sidebar() {
  const { user, logout } = useAuth();

  return (
    <aside className="w-64 shrink-0 h-screen sticky top-0 bg-navy-900 text-white flex flex-col">
      <div className="px-6 py-6 flex items-center gap-2.5">
        <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-brand-500 to-brand-700 flex items-center justify-center shadow-glow">
          <Sparkles size={18} className="text-white" />
        </div>
        <div>
          <div className="flex items-center gap-1.5">
            <p className="font-display font-extrabold text-lg leading-none tracking-tight">Zentra</p>
            <span className="text-[9px] font-bold px-1.5 py-0.5 rounded-md bg-brand-500/20 text-brand-300 leading-none">V4</span>
          </div>
          <p className="text-[11px] text-white/40 font-medium mt-1">Admin Panel</p>
        </div>
      </div>

      <nav className="flex-1 px-3 mt-4 space-y-1">
        {NAV.map(({ to, label, icon: Icon, end }) => (
          <NavLink
            key={to}
            to={to}
            end={end}
            className={({ isActive }) =>
              `flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-sm font-semibold transition-all ${
                isActive
                  ? 'bg-brand-500 text-white shadow-glow'
                  : 'text-white/55 hover:text-white hover:bg-white/[0.06]'
              }`
            }
          >
            <Icon size={18} />
            {label}
          </NavLink>
        ))}
      </nav>

      <div className="p-3 border-t border-white/10">
        <div className="flex items-center gap-3 px-2 py-2.5 rounded-xl">
          <img src={user?.avatar} alt="" className="w-9 h-9 rounded-full object-cover ring-2 ring-brand-500/40" />
          <div className="flex-1 min-w-0">
            <p className="text-sm font-semibold truncate">{user?.name}</p>
            <p className="text-[11px] text-white/40 truncate">{user?.email}</p>
          </div>
          <button onClick={logout} title="Keluar" className="text-white/40 hover:text-brand-500 transition-colors">
            <LogOut size={17} />
          </button>
        </div>
      </div>
    </aside>
  );
}
