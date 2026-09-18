import { createContext, useCallback, useContext, useState } from 'react';
import { CheckCircle2, PackageSearch, ShoppingBag, X, AlertCircle } from 'lucide-react';

const ToastContext = createContext(null);

const ICONS = {
  success: CheckCircle2,
  sync: PackageSearch,
  order: ShoppingBag,
  error: AlertCircle,
};

export function ToastProvider({ children }) {
  const [toasts, setToasts] = useState([]);

  const push = useCallback((toast) => {
    const id = Math.random().toString(36).slice(2);
    setToasts((t) => [...t, { id, type: 'success', ...toast }]);
    setTimeout(() => setToasts((t) => t.filter((x) => x.id !== id)), 4500);
  }, []);

  const dismiss = (id) => setToasts((t) => t.filter((x) => x.id !== id));

  return (
    <ToastContext.Provider value={{ push }}>
      {children}
      <div className="fixed top-5 right-5 z-[100] flex flex-col gap-2.5 w-[340px]">
        {toasts.map((t) => {
          const Icon = ICONS[t.type] || CheckCircle2;
          const isError = t.type === 'error';
          return (
            <div key={t.id} className="animate-slideIn card p-3.5 flex items-start gap-3">
              <div className={`w-9 h-9 rounded-full flex items-center justify-center shrink-0 ${isError ? 'bg-brand-500/15 text-brand-600' : 'bg-mint-500/15 text-mint-600'}`}>
                <Icon size={18} />
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-semibold text-navy-900 truncate">{t.title}</p>
                {t.description && <p className="text-xs text-plum-500 mt-0.5 line-clamp-2">{t.description}</p>}
              </div>
              <button onClick={() => dismiss(t.id)} className="text-plum-400 hover:text-navy-900 shrink-0">
                <X size={16} />
              </button>
            </div>
          );
        })}
      </div>
    </ToastContext.Provider>
  );
}

export const useToast = () => useContext(ToastContext);
