import { useEffect, useState } from 'react';
import { socket } from '../lib/socket';

export default function RealtimeBadge() {
  const [connected, setConnected] = useState(socket.connected);

  useEffect(() => {
    const onConnect = () => setConnected(true);
    const onDisconnect = () => setConnected(false);
    socket.on('connect', onConnect);
    socket.on('disconnect', onDisconnect);
    return () => {
      socket.off('connect', onConnect);
      socket.off('disconnect', onDisconnect);
    };
  }, []);

  return (
    <div
      className={`flex items-center gap-2 pl-2.5 pr-3 py-1.5 rounded-full text-xs font-semibold border ${
        connected
          ? 'bg-mint-500/10 border-mint-500/20 text-mint-600'
          : 'bg-plum-400/10 border-plum-400/20 text-plum-500'
      }`}
      title={connected ? 'Tersambung — perubahan produk & stok langsung sinkron ke app customer' : 'Menghubungkan ulang...'}
    >
      <span className="relative flex h-2 w-2">
        {connected && <span className="animate-pulseDot absolute inline-flex h-full w-full rounded-full bg-mint-500 opacity-75" />}
        <span className={`relative inline-flex rounded-full h-2 w-2 ${connected ? 'bg-mint-500' : 'bg-plum-400'}`} />
      </span>
      {connected ? 'Sinkron realtime aktif' : 'Menyambungkan…'}
    </div>
  );
}
