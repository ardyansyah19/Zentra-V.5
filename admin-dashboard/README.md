# Zentra Store — Admin Dashboard (React)

Dashboard admin untuk mengelola produk, stok, harga, pesanan, dan pelanggan
Zentra Store. Terhubung ke backend yang sama dengan aplikasi customer
Flutter, dengan indikator "Sinkron realtime aktif" yang menunjukkan
koneksi Socket.io hidup.

## Menjalankan

```bash
cd admin-dashboard
npm install
cp .env.example .env
npm run dev
```

Buka `http://localhost:5173`, lalu login dengan:

```
Email    : admin@zentra.id
Password : admin123
```

> Pastikan backend (`../backend`) sudah berjalan di `http://localhost:4000`
> sebelum menjalankan dashboard ini.

## Build Produksi

```bash
npm run build
```

## Fitur

- Login admin
- Ringkasan: pendapatan, pesanan, pelanggan, grafik penjualan 7 hari, status pesanan, stok menipis
- Manajemen Produk: tambah/edit/hapus, quick +/- stok, harga diskon, tag featured/populer
- Manajemen Pesanan: ubah status pesanan (menunggu -> diproses -> dikirim -> selesai)
- Daftar Pelanggan
- Notifikasi toast realtime setiap ada perubahan produk/stok atau pesanan baru
