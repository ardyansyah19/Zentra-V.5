import { useEffect, useState } from 'react';
import api from '../lib/api';
import Topbar from '../components/Topbar';
import { useToast } from '../context/ToastContext';
import { Skeleton } from '../components/Skeleton';

export default function Customers() {
  const [customers, setCustomers] = useState([]);
  const [loading, setLoading] = useState(true);
  const { push } = useToast();

  useEffect(() => {
    api.get('/users')
      .then(({ data }) => setCustomers(data))
      .catch((err) => push({ type: 'error', title: 'Gagal memuat pelanggan', description: err.response?.data?.error || 'Periksa koneksi ke server backend.' }))
      .finally(() => setLoading(false));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <div>
      <Topbar title="Pelanggan" subtitle={loading ? 'Memuat…' : `${customers.length} pelanggan terdaftar`} />
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
        {loading && Array.from({ length: 6 }).map((_, i) => (
          <div key={i} className="card p-4 flex items-center gap-3">
            <Skeleton className="w-12 h-12 rounded-full shrink-0" />
            <div className="flex-1 space-y-2">
              <Skeleton className="h-3.5 w-28" />
              <Skeleton className="h-3 w-36" />
            </div>
          </div>
        ))}
        {!loading && customers.map((c) => (
          <div key={c.id} className="card p-4 flex items-center gap-3">
            <img src={c.avatar} className="w-12 h-12 rounded-full object-cover" alt="" />
            <div className="min-w-0">
              <p className="font-semibold text-navy-900 truncate">{c.name}</p>
              <p className="text-xs text-plum-500 truncate">{c.email}</p>
              <p className="text-xs text-plum-400 mt-0.5">{c.phone || 'Tanpa nomor telepon'}</p>
            </div>
          </div>
        ))}
        {!loading && customers.length === 0 && <p className="text-plum-500 text-sm col-span-full text-center py-10">Belum ada pelanggan terdaftar.</p>}
      </div>
    </div>
  );
}
