import { io } from 'socket.io-client';
import { API_BASE } from './api';

// Satu koneksi socket dipakai di seluruh dashboard untuk menerima
// update realtime (produk, stok, order) dari server yang sama
// dipakai oleh aplikasi customer Flutter.
export const socket = io(API_BASE, { autoConnect: true, transports: ['websocket', 'polling'] });
