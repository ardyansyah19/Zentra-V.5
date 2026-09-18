import { useEffect, useState } from 'react';
import api from '../lib/api';
import { socket } from '../lib/socket';
import Topbar from '../components/Topbar';
import { useToast } from '../context/ToastContext';
import { CardListSkeleton } from '../components/Skeleton';

const STATUS_FLOW = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];
const STATUS_LABEL = { pending: 'Menunggu', processing: 'Diproses', shipped: 'Dikirim', delivered: 'Selesai', cancelled: 'Dibatalkan' };
const STATUS_COLOR = {
  pending: 'bg-amber-500/10 text-amber-600',
  processing: 'bg-mint-500/10 text-mint-600',
  shipped: 'bg-brand-500/10 text-brand-600',
  delivered: 'bg-mint-600/10 text-mint-600',
  cancelled: 'bg-plum-400/10 text-plum-500',
};
const currency = (n) => `Rp${Number(n || 0).toLocaleString('id-ID')}`;

export default function Orders() {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const { push } = useToast();

  async function load() {
    try {
      const { data } = await api.get('/orders');
      setOrders(data);
    } catch (err) {
      push({ type: 'error', title: 'Gagal memuat pesanan', description: err.response?.data?.error || 'Periksa koneksi ke server backend.' });
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    load();
    socket.on('order:created', load);
    socket.on('order:updated', load);
    return () => {
      socket.off('order:created', load);
      socket.off('order:updated', load);
    };
  }, []);

  async function changeStatus(order, status) {
    try {
      await api.patch(`/orders/${order.id}/status`, { status });
      push({ title: 'Status pesanan diperbarui', description: `#${order.id.slice(0, 8)} → ${STATUS_LABEL[status]}` });
    } catch (err) {
      push({ type: 'error', title: 'Gagal memperbarui status', description: err.response?.data?.error || 'Terjadi kesalahan, coba lagi.' });
    }
  }

  return (
    <div>
      <Topbar title="Pesanan" subtitle="Kelola & perbarui status pesanan pelanggan" />

      {loading ? (
        <CardListSkeleton count={4} />
      ) : (
      <div className="space-y-3">
        {orders.length === 0 && <div className="card p-10 text-center text-plum-500">Belum ada pesanan masuk.</div>}
        {orders.map((o) => (
          <div key={o.id} className="card p-5">
            <div className="flex items-center justify-between flex-wrap gap-3 mb-3">
              <div>
                <p className="font-semibold text-navy-900">{o.customer_name || 'Pelanggan'}</p>
                <p className="text-xs text-plum-500 font-mono">#{o.id.slice(0, 8)} • {new Date(o.created_at).toLocaleString('id-ID')}</p>
              </div>
              <span className={`badge ${STATUS_COLOR[o.status]}`}>{STATUS_LABEL[o.status]}</span>
            </div>

            <div className="flex gap-3 overflow-x-auto pb-2 mb-3">
              {o.items.map((it, idx) => (
                <div key={idx} className="flex items-center gap-2 bg-navy-900/[0.03] rounded-lg px-2.5 py-1.5 shrink-0">
                  <img src={it.image} className="w-8 h-8 rounded object-cover" alt="" />
                  <div className="text-xs">
                    <p className="font-medium text-navy-900 whitespace-nowrap">{it.name}</p>
                    <p className="text-plum-500">{it.quantity}x {currency(it.price)}</p>
                  </div>
                </div>
              ))}
            </div>

            <div className="flex items-center justify-between flex-wrap gap-3">
              <p className="font-mono font-bold text-navy-900">Total: {currency(o.total)}</p>
              <div className="flex gap-2 flex-wrap">
                {STATUS_FLOW.map((s) => (
                  <button
                    key={s}
                    onClick={() => changeStatus(o, s)}
                    disabled={o.status === s}
                    className={`text-xs font-semibold px-3 py-1.5 rounded-lg transition-all ${
                      o.status === s ? 'bg-navy-900 text-white cursor-default' : 'bg-navy-900/5 hover:bg-navy-900/10 text-navy-700'
                    }`}
                  >
                    {STATUS_LABEL[s]}
                  </button>
                ))}
              </div>
            </div>
          </div>
        ))}
      </div>
      )}
    </div>
  );
}
