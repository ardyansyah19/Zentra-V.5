// seed.js — Reset database Zentra ke kondisi awal (hapus semua data lalu
// isi ulang dengan data contoh). Jalankan dengan: npm run seed
//
// PERINGATAN: Ini akan MENGHAPUS seluruh data yang ada (produk, user,
// pesanan, dll) dan menggantinya dengan data awal yang baru.
const fs = require('fs');
const path = require('path');

const dbPath = path.join(__dirname, 'zentra.db');
const walPath = `${dbPath}-wal`;
const shmPath = `${dbPath}-shm`;

for (const file of [dbPath, walPath, shmPath]) {
  if (fs.existsSync(file)) fs.unlinkSync(file);
}

console.log('🗑️  Database lama dihapus. Membuat database baru & mengisi data awal...\n');

// require('./db') akan otomatis membuat tabel & mengisi data seed
// karena database baru selalu dalam keadaan kosong.
require('./db');
