import { useEffect, useState } from 'react';
import { AreaChart, Area, ResponsiveContainer, XAxis, YAxis, Tooltip, CartesianGrid, PieChart, Pie, Cell } from 'recharts';
import { DollarSign, ShoppingBag, Users, Package, AlertTriangle, TrendingUp } from 'lucide-react';
import api from '../lib/api';
import { socket } from '../lib/socket';
import { useToast } from '../context/ToastContext';
import Topbar from '../components/Topbar';
import StatCard from '../components/StatCard';
import { DashboardSkeleton } from '../components/Skeleton';

const STATUS_COLORS = { pending: '#FFB627', processing: '#2EC4B6', shipped: '#FF6A3D', delivered: '#22A395', cancelled: '#8B85A0' };
const STATUS_LABEL = { pending: 'Menunggu', processing: 'Diproses', shipped: 'Dikirim', delivered: 'Selesai', cancelled: 'Dibatalkan' };

const currency = (n) => `Rp${Number(n || 0).toLocaleString('id-ID')}`;

export default function Dashboard() {
  const [stats, setStats] = useState(null);
  const { push } = useToast();

  async function load() {
    try {
      const { data } = await api.get('/dashboard/stats');
      setStats(data);
    } catch (err) {
      push({ type: 'error', title: 'Gagal memuat data dashboard', description: err.response?.data?.error || 'Periksa koneksi ke server backend.' });
    }
  }

  useEffect(() => {
    load();
    const onProductUpdate = (p) => {
      push({ type: 'sync', title: 'Produk tersinkron', description: `${p.name} — stok: ${p.stock}, harga: ${currency(p.price)}` });
      load();
    };
    const onOrder = (o) => {
      push({ type: 'order', title: 'Pesanan baru masuk', description: `Total ${currency(o.total)} dari pelanggan` });
      load();
    };
    socket.on('product:updated', onProductUpdate);
    socket.on('product:created', onProductUpdate);
    socket.on('order:created', onOrder);
    socket.on('order:updated', load);
    return () => {
      socket.off('product:updated', onProductUpdate);
      socket.off('product:created', onProductUpdate);
      socket.off('order:created', onOrder);
      socket.off('order:updated', load);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  if (!stats) return <DashboardSkeleton />;

  const pieData = stats.ordersByStatus.map((s) => ({ name: STATUS_LABEL[s.status] || s.status, value: s.c, key: s.status }));

  return (
    <div>
      <Topbar title="Ringkasan Toko" subtitle="Pantau performa Zentra Store secara realtime" />

      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4 mb-6">
        <StatCard label="Total Pendapatan" value={currency(stats.totalRevenue)} icon={DollarSign} tint="brand" trend="Sinkron dari semua pesanan" />
        <StatCard label="Total Pesanan" value={stats.totalOrders} icon={ShoppingBag} tint="mint" />
        <StatCard label="Total Pelanggan" value={stats.totalCustomers} icon={Users} tint="navy" />
        <StatCard label="Produk Aktif" value={stats.totalProducts} icon={Package} tint="amber" />
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-3 gap-5">
        <div className="xl:col-span-2 card p-6">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h3 className="font-display font-bold text-navy-900">Penjualan 7 Hari Terakhir</h3>
              <p className="text-xs text-plum-500 mt-0.5">Total transaksi harian (Rp)</p>
            </div>
            <TrendingUp size={18} className="text-mint-500" />
          </div>
          <ResponsiveContainer width="100%" height={230}>
            <AreaChart data={stats.salesByDay}>
              <defs>
                <linearGradient id="rev" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="#FF6A3D" stopOpacity={0.35} />
                  <stop offset="100%" stopColor="#FF6A3D" stopOpacity={0} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="#14151F0D" vertical={false} />
              <XAxis dataKey="day" tick={{ fontSize: 11, fill: '#8B85A0' }} axisLine={false} tickLine={false}
                tickFormatter={(d) => new Date(d).toLocaleDateString('id-ID', { day: '2-digit', month: 'short' })} />
              <YAxis tick={{ fontSize: 11, fill: '#8B85A0' }} axisLine={false} tickLine={false} tickFormatter={(v) => `${v / 1000}k`} />
              <Tooltip formatter={(v) => currency(v)} labelFormatter={(d) => new Date(d).toLocaleDateString('id-ID')}
                contentStyle={{ borderRadius: 12, border: '1px solid #14151F14', fontSize: 12 }} />
              <Area type="monotone" dataKey="total" stroke="#FF6A3D" strokeWidth={2.5} fill="url(#rev)" />
            </AreaChart>
          </ResponsiveContainer>
        </div>

        <div className="card p-6">
          <h3 className="font-display font-bold text-navy-900 mb-4">Status Pesanan</h3>
          {pieData.length === 0 ? (
            <p className="text-sm text-plum-500">Belum ada pesanan.</p>
          ) : (
            <ResponsiveContainer width="100%" height={200}>
              <PieChart>
                <Pie data={pieData} dataKey="value" nameKey="name" innerRadius={50} outerRadius={78} paddingAngle={3}>
                  {pieData.map((entry) => <Cell key={entry.key} fill={STATUS_COLORS[entry.key] || '#8B85A0'} />)}
                </Pie>
                <Tooltip contentStyle={{ borderRadius: 12, fontSize: 12 }} />
              </PieChart>
            </ResponsiveContainer>
          )}
          <div className="grid grid-cols-2 gap-2 mt-3">
            {pieData.map((d) => (
              <div key={d.key} className="flex items-center gap-1.5 text-xs text-plum-500">
                <span className="w-2 h-2 rounded-full" style={{ background: STATUS_COLORS[d.key] }} />
                {d.name} ({d.value})
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-3 gap-5 mt-5">
        <div className="xl:col-span-2 card p-6">
          <h3 className="font-display font-bold text-navy-900 mb-4">Pesanan Terbaru</h3>
          <div className="space-y-1">
            {stats.recentOrders.length === 0 && <p className="text-sm text-plum-500">Belum ada pesanan.</p>}
            {stats.recentOrders.map((o) => (
              <div key={o.id} className="flex items-center justify-between py-2.5 border-b border-navy-900/5 last:border-0">
                <div>
                  <p className="text-sm font-semibold text-navy-900">{o.customer_name}</p>
                  <p className="text-xs text-plum-500 font-mono">#{o.id.slice(0, 8)}</p>
                </div>
                <div className="text-right">
                  <p className="text-sm font-bold font-mono">{currency(o.total)}</p>
                  <span className="badge mt-1" style={{ background: `${STATUS_COLORS[o.status]}1A`, color: STATUS_COLORS[o.status] }}>
                    {STATUS_LABEL[o.status]}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="card p-6">
          <div className="flex items-center gap-2 mb-4">
            <AlertTriangle size={17} className="text-brand-500" />
            <h3 className="font-display font-bold text-navy-900">Stok Menipis</h3>
          </div>
          {stats.lowStock.length === 0 ? (
            <p className="text-sm text-plum-500">Semua stok aman 👍</p>
          ) : (
            <div className="space-y-3">
              {stats.lowStock.map((p) => (
                <div key={p.id} className="flex items-center gap-3">
                  <img src={p.image} className="w-10 h-10 rounded-lg object-cover" alt="" />
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-navy-900 truncate">{p.name}</p>
                  </div>
                  <span className="badge bg-brand-500/10 text-brand-600">{p.stock} tersisa</span>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
