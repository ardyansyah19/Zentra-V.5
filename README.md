# Zentra V.4
By Ahmad Riko Dyansyah

Paket ini berisi 3 bagian yang saling terhubung ke satu backend, sehingga
**harga & stok produk selalu sinkron** antara halaman admin dan aplikasi customer:

```
zentra-ecommerce/
├── backend/           Node.js + Express + SQLite + Socket.io (API bersama)
├── admin-dashboard/   React + Vite + Tailwind — dashboard admin (web)
└── flutter_app/       Flutter — aplikasi customer (mobile, iOS & Android)
```

## Bagaimana Sinkronisasi Bekerja

Admin Dashboard dan Aplikasi Flutter sama-sama terhubung ke satu backend
lewat REST API **dan** koneksi Socket.io. Saat admin mengubah harga,
stok, atau status pesanan lewat dashboard:

1. Perubahan disimpan ke database SQLite.
2. Backend langsung `emit` event (`product:updated`, `order:updated`, dll) ke semua client yang terhubung.
3. Aplikasi Flutter customer menerima event ini secara realtime dan memperbarui
   tampilan (harga/stok) tanpa perlu refresh manual — ditandai badge "Stok/harga diperbarui" sekilas di layar Beranda.
4. Begitu juga sebaliknya: saat customer checkout, stok otomatis berkurang dan admin
   langsung melihat notifikasi pesanan baru + grafik ter-update di dashboard.

## Fitur Utama

- Autentikasi 2 role: Admin & Customer (JWT)
- CRUD produk dengan harga, harga diskon, stok, kategori, gambar, featured/populer
- Sinkronisasi harga & stok realtime (Socket.io) — inti dari sistem ini
- Keranjang, checkout, riwayat & status pesanan
- Favorit/wishlist, pencarian & filter kategori, rating & ulasan
- Dashboard admin dengan grafik penjualan, status pesanan, & peringatan stok menipis
- Mode gelap/terang di aplikasi mobile
- Desain khas (oranye/navy) yang konsisten di web & mobile
