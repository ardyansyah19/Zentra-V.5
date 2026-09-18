import { useEffect, useMemo, useState } from 'react';
import { Plus, Search, Pencil, Trash2, Star, Flame } from 'lucide-react';
import api from '../lib/api';
import { socket } from '../lib/socket';
import Topbar from '../components/Topbar';
import ProductModal from '../components/ProductModal';
import { useToast } from '../context/ToastContext';
import { TableRowsSkeleton } from '../components/Skeleton';

const currency = (n) => `Rp${Number(n || 0).toLocaleString('id-ID')}`;

export default function Products() {
  const [products, setProducts] = useState([]);
  const [categories, setCategories] = useState([]);
  const [search, setSearch] = useState('');
  const [modalOpen, setModalOpen] = useState(false);
  const [editing, setEditing] = useState(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const { push } = useToast();

  async function load() {
    try {
      const [{ data: p }, { data: c }] = await Promise.all([
        api.get('/products', { params: { status: 'active' } }),
        api.get('/products/categories/all'),
      ]);
      setProducts(p);
      setCategories(c);
    } catch (err) {
      push({ type: 'error', title: 'Gagal memuat produk', description: err.response?.data?.error || 'Periksa koneksi ke server backend.' });
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    load();
    const refresh = () => load();
    socket.on('product:created', refresh);
    socket.on('product:updated', refresh);
    socket.on('product:deleted', refresh);
    return () => {
      socket.off('product:created', refresh);
      socket.off('product:updated', refresh);
      socket.off('product:deleted', refresh);
    };
  }, []);

  const filtered = useMemo(
    () => products.filter((p) => p.name.toLowerCase().includes(search.toLowerCase())),
    [products, search]
  );

  async function handleSave(form) {
    setSaving(true);
    try {
      if (editing?.id) {
        await api.put(`/products/${editing.id}`, form);
        push({ title: 'Produk diperbarui', description: `${form.name} disinkronkan ke aplikasi customer secara realtime.` });
      } else {
        await api.post('/products', form);
        push({ title: 'Produk ditambahkan', description: `${form.name} kini tampil di aplikasi customer.` });
      }
      setModalOpen(false);
      setEditing(null);
      load();
    } catch (err) {
      push({ type: 'error', title: 'Gagal menyimpan produk', description: err.response?.data?.error || 'Terjadi kesalahan, coba lagi.' });
    } finally {
      setSaving(false);
    }
  }

  async function handleDelete(p) {
    if (!confirm(`Hapus produk "${p.name}"?`)) return;
    try {
      await api.delete(`/products/${p.id}`);
      push({ title: 'Produk dihapus', description: p.name });
      load();
    } catch (err) {
      push({ type: 'error', title: 'Gagal menghapus produk', description: err.response?.data?.error || 'Terjadi kesalahan, coba lagi.' });
    }
  }

  async function quickStockUpdate(p, delta) {
    const newStock = Math.max(0, p.stock + delta);
    try {
      await api.patch(`/products/${p.id}/stock`, { stock: newStock });
    } catch (err) {
      push({ type: 'error', title: 'Gagal memperbarui stok', description: err.response?.data?.error || 'Terjadi kesalahan, coba lagi.' });
    }
  }

  return (
    <div>
      <Topbar
        title="Manajemen Produk"
        subtitle="Perubahan harga & stok langsung tersinkron ke aplikasi customer"
        action={
          <button onClick={() => { setEditing(null); setModalOpen(true); }} className="btn-primary flex items-center gap-2">
            <Plus size={17} /> Tambah Produk
          </button>
        }
      />

      <div className="relative mb-5 max-w-sm">
        <Search size={16} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-plum-400" />
        <input
          value={search} onChange={(e) => setSearch(e.target.value)}
          placeholder="Cari produk…" className="input-field pl-10"
        />
      </div>

      <div className="card overflow-hidden">
        <table className="w-full text-sm">
          <thead>
            <tr className="text-left text-xs font-semibold text-plum-500 uppercase tracking-wide border-b border-navy-900/5">
              <th className="px-5 py-3.5">Produk</th>
              <th className="px-5 py-3.5">Kategori</th>
              <th className="px-5 py-3.5">Harga</th>
              <th className="px-5 py-3.5">Stok</th>
              <th className="px-5 py-3.5">Rating</th>
              <th className="px-5 py-3.5 text-right">Aksi</th>
            </tr>
          </thead>
          <tbody>
            {loading && <TableRowsSkeleton rows={5} cols={6} />}
            {!loading && filtered.map((p) => (
              <tr key={p.id} className="border-b border-navy-900/5 last:border-0 hover:bg-navy-900/[0.015] transition-colors">
                <td className="px-5 py-3">
                  <div className="flex items-center gap-3">
                    <img src={p.image} className="w-11 h-11 rounded-lg object-cover" alt="" />
                    <div>
                      <p className="font-semibold text-navy-900">{p.name}</p>
                      <div className="flex gap-1 mt-0.5">
                        {p.is_featured === 1 && <span className="badge bg-brand-500/10 text-brand-600 text-[10px] py-0.5"><Star size={10} />Featured</span>}
                        {p.is_popular === 1 && <span className="badge bg-mint-500/10 text-mint-600 text-[10px] py-0.5"><Flame size={10} />Populer</span>}
                      </div>
                    </div>
                  </div>
                </td>
                <td className="px-5 py-3 text-plum-500">{p.category || '—'}</td>
                <td className="px-5 py-3 font-mono">
                  {p.discount_price ? (
                    <div>
                      <span className="font-semibold text-brand-600">{currency(p.discount_price)}</span>
                      <span className="block text-xs text-plum-400 line-through">{currency(p.price)}</span>
                    </div>
                  ) : (
                    <span className="font-semibold">{currency(p.price)}</span>
                  )}
                </td>
                <td className="px-5 py-3">
                  <div className="flex items-center gap-2">
                    <button onClick={() => quickStockUpdate(p, -1)} className="w-6 h-6 rounded-md bg-navy-900/5 hover:bg-navy-900/10 font-bold text-xs">−</button>
                    <span className={`font-mono font-semibold w-8 text-center ${p.stock <= 5 ? 'text-brand-600' : 'text-navy-900'}`}>{p.stock}</span>
                    <button onClick={() => quickStockUpdate(p, 1)} className="w-6 h-6 rounded-md bg-navy-900/5 hover:bg-navy-900/10 font-bold text-xs">+</button>
                  </div>
                </td>
                <td className="px-5 py-3 text-plum-500">★ {p.rating?.toFixed(1) || '0.0'} <span className="text-xs">({p.review_count})</span></td>
                <td className="px-5 py-3">
                  <div className="flex items-center justify-end gap-2">
                    <button onClick={() => { setEditing(p); setModalOpen(true); }} className="w-8 h-8 rounded-lg bg-navy-900/5 hover:bg-navy-900/10 flex items-center justify-center text-navy-700">
                      <Pencil size={14} />
                    </button>
                    <button onClick={() => handleDelete(p)} className="w-8 h-8 rounded-lg bg-brand-500/10 hover:bg-brand-500/20 flex items-center justify-center text-brand-600">
                      <Trash2 size={14} />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {!loading && filtered.length === 0 && <p className="text-center text-plum-500 py-10 text-sm">Tidak ada produk ditemukan.</p>}
      </div>

      <ProductModal
        open={modalOpen}
        onClose={() => { setModalOpen(false); setEditing(null); }}
        onSave={handleSave}
        categories={categories}
        initial={editing}
        saving={saving}
      />
    </div>
  );
}
