# Zentra Store — Aplikasi Customer (Flutter) — V4

Aplikasi mobile belanja online yang tersinkron secara **realtime** dengan
Admin Dashboard (React) melalui backend yang sama (Node.js + Socket.io).
Saat admin mengubah harga atau stok produk, perubahan langsung muncul di
aplikasi ini tanpa perlu refresh manual.

## Fitur

- Login & Register (role customer)
- Beranda dengan banner promo, kategori, produk unggulan & populer
- Pencarian & filter produk per kategori
- Detail produk (pilih ukuran, rating, deskripsi, stok realtime, ulasan)
- Keranjang belanja & checkout (alamat + metode pembayaran) — harga dalam **Rupiah**
- Riwayat pesanan dengan status realtime
- Favorit / wishlist
- Alamat pengiriman, detail akun, notifikasi
- Mode gelap & terang
- Skeleton loading (shimmer) saat memuat data produk
- Sinkronisasi harga & stok realtime via Socket.io (indikator di halaman Beranda)

## Cara Menjalankan

Karena folder platform (`android/`, `ios/`) tidak disertakan (dibuat dari mesin
tanpa Flutter SDK terpasang), ikuti langkah berikut:

1. Pastikan [Flutter SDK](https://docs.flutter.dev/get-started/install) sudah terpasang (`flutter doctor`).
2. Buat project kosong lalu salin kode ini ke dalamnya:
   ```bash
   flutter create zentra_store_app
   cd zentra_store_app
   # salin isi folder lib/ dan file pubspec.yaml dari paket ini,
   # timpa (overwrite) file lib/main.dart dan pubspec.yaml bawaan
   ```
   Atau jika Anda sudah punya Flutter project kosong bernama sama, cukup
   salin folder `lib/`, `pubspec.yaml`, `analysis_options.yaml`, dan `.gitignore`
   dari paket ini ke dalamnya (timpa file yang ada).
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Sesuaikan alamat API di `lib/config/constants.dart`:
   - Android Emulator: `http://10.0.2.2:4000` (default, tidak perlu diubah)
   - iOS Simulator: `http://localhost:4000`
   - HP fisik: `http://<IP-LOKAL-KOMPUTER-ANDA>:4000` (pastikan HP & komputer satu jaringan WiFi)
5. Jalankan backend terlebih dahulu (lihat `backend/README.md`).
6. Jalankan aplikasi:
   ```bash
   flutter run
   ```

## Login Demo

```
Email    : customer@zentra.id
Password : customer123
```

## Struktur Folder

```
lib/
  config/       -> tema warna/font & konfigurasi API
  models/       -> model data (Product, User, Order, dll)
  services/     -> koneksi HTTP (api_service) & realtime (socket_service)
  providers/    -> state management (Provider): auth, cart, favorites, products, theme
  screens/      -> semua halaman UI
  widgets/      -> komponen UI yang dipakai berulang (termasuk skeleton loading)
  utils/        -> util bersama, mis. formatter mata uang Rupiah
  main.dart     -> entry point aplikasi
```
