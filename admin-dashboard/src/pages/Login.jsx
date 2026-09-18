import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Sparkles, Loader2 } from 'lucide-react';
import { useAuth } from '../context/AuthContext';

export default function Login() {
  const { login } = useAuth();
  const navigate = useNavigate();
  const [email, setEmail] = useState('admin@zentra.id');
  const [password, setPassword] = useState('admin123');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      await login(email, password);
      navigate('/');
    } catch (err) {
      setError(err.response?.data?.error || err.message || 'Gagal masuk');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="min-h-screen bg-navy-900 flex items-center justify-center p-6 relative overflow-hidden">
      <div className="absolute -top-40 -right-40 w-96 h-96 rounded-full bg-brand-500/20 blur-3xl" />
      <div className="absolute -bottom-40 -left-40 w-96 h-96 rounded-full bg-mint-500/10 blur-3xl" />

      <div className="w-full max-w-sm relative">
        <div className="flex flex-col items-center mb-8">
          <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-brand-500 to-brand-700 flex items-center justify-center shadow-glow mb-4">
            <Sparkles size={26} className="text-white" />
          </div>
          <h1 className="font-display text-2xl font-extrabold text-white tracking-tight">Zentra Admin</h1>
          <p className="text-sm text-white/40 mt-1">Kelola produk, stok & pesanan tokomu</p>
        </div>

        <form onSubmit={handleSubmit} className="bg-white/[0.04] backdrop-blur border border-white/10 rounded-xl2 p-6 space-y-4">
          {error && (
            <div className="bg-brand-500/15 border border-brand-500/30 text-brand-300 text-sm rounded-xl px-3.5 py-2.5">
              {error}
            </div>
          )}
          <div>
            <label className="text-xs font-semibold text-white/50 mb-1.5 block">Email</label>
            <input
              type="email" required value={email} onChange={(e) => setEmail(e.target.value)}
              className="w-full bg-white/[0.06] border border-white/10 rounded-xl px-4 py-2.5 text-sm text-white placeholder-white/30 outline-none focus:ring-2 focus:ring-brand-500/40 focus:border-brand-500 transition-all"
              placeholder="admin@zentra.id"
            />
          </div>
          <div>
            <label className="text-xs font-semibold text-white/50 mb-1.5 block">Password</label>
            <input
              type="password" required value={password} onChange={(e) => setPassword(e.target.value)}
              className="w-full bg-white/[0.06] border border-white/10 rounded-xl px-4 py-2.5 text-sm text-white placeholder-white/30 outline-none focus:ring-2 focus:ring-brand-500/40 focus:border-brand-500 transition-all"
              placeholder="••••••••"
            />
          </div>
          <button type="submit" disabled={loading} className="w-full btn-primary flex items-center justify-center gap-2 disabled:opacity-60">
            {loading && <Loader2 size={16} className="animate-spin" />}
            Masuk ke Dashboard
          </button>
          <p className="text-center text-[11px] text-white/30 pt-1">
            Demo: admin@zentra.id / admin123
          </p>
        </form>
      </div>
    </div>
  );
}
