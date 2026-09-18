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

## Urutan Menjalankan

1. **Backend** (wajib jalan duluan) — lihat `backend/README.md`
   ```bash
   cd backend && npm install && cp .env.example .env && npm start
   ```
2. **Admin Dashboard** — lihat `admin-dashboard/README.md`
   ```bash
   cd admin-dashboard && npm install && cp .env.example .env && npm run dev
   ```
3. **Aplikasi Flutter** — lihat `flutter_app/README.md` (perlu Flutter SDK terpasang)
   ```bash
   cd flutter_app && flutter pub get && flutter run
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

## Teknologi

- **Backend:** Node.js, Express, better-sqlite3, Socket.io, JWT, bcrypt
- **Admin Dashboard:** React 19, Vite, Tailwind CSS, Recharts, socket.io-client, React Router
- **Aplikasi Mobile:** Flutter/Dart, Provider, socket_io_client, cached_network_image, google_fonts

## Changelog — V4

**Bug diperbaiki:**
- **Kritis — inkonsistensi mata uang:** aplikasi Flutter menampilkan seluruh harga dengan simbol Dolar (`$`) sementara Admin Dashboard menampilkan Rupiah (`Rp`) dari angka mentah yang sama, sehingga harga di aplikasi mobile terlihat tidak masuk akal (mis. hoodie "$45" yang seharusnya sekitar Rp300 ribuan). Sekarang seluruh aplikasi — kartu produk, detail produk, keranjang, checkout, riwayat pesanan — memakai formatter Rupiah terpusat yang konsisten dengan Admin Dashboard, dan data seed produk sudah disesuaikan ke harga Rupiah yang realistis.
- Ongkos kirim di aplikasi mobile disesuaikan ke nilai Rupiah yang wajar (sebelumnya bernilai `10`, sisa dari asumsi Dolar).
- File `.env.example` yang hilang di `backend/` dan `admin-dashboard/` (padahal instruksi menjalankan menyuruh meng-copy file ini) kini sudah tersedia.
- Script `npm run seed` di backend sebelumnya rusak (memanggil file `seed.js` yang tidak ada) — sekarang benar-benar berfungsi untuk mereset database ke data awal.
- Beberapa label UI berbahasa Inggris yang tercampur di antara teks Bahasa Indonesia (mis. "My Account", "Log Out", "Home", "Featured Items") kini konsisten berbahasa Indonesia.
- Bug tampilan: avatar pengguna kosong (`NetworkImage('')`) di halaman Beranda kini punya fallback inisial nama, sama seperti di halaman Akun.
- Admin Dashboard sebelumnya diam-diam gagal tanpa pemberitahuan saat request API error (mis. backend mati) — sekarang menampilkan notifikasi toast error yang jelas di semua halaman.

**Peningkatan tampilan & pengalaman:**
- Admin Dashboard: skeleton loading halus menggantikan teks "Memuat data..." di semua halaman (Dashboard, Produk, Pesanan, Pelanggan), preview thumbnail gambar & indikator saat menyimpan di form produk, badge versi di sidebar.
- Aplikasi Flutter: skeleton loading bergaya shimmer untuk grid produk (memanfaatkan paket `shimmer` yang sebelumnya sudah terpasang namun belum pernah dipakai).

**Beres-beres teknis:**
- Menghapus dependency `multer` dari backend — tidak pernah dipakai di kode manapun dan punya kerentanan keamanan yang diketahui pada versi 1.x.
- Menghapus dependency `flutter_svg` dari aplikasi mobile — tidak pernah diimpor/dipakai di kode manapun.

## Changelog — V3 (sebelumnya)

**Bug diperbaiki:**
- Fix kritis: "Tambah ke Keranjang" gagal total (error SQL karena tanda kutip ganda salah dipakai sebagai literal string di query cart). Sekarang keranjang berfungsi normal, termasuk increment quantity untuk produk/varian yang sama.
- Fix: endpoint `GET /api/dashboard/stats` (ringkasan admin) error karena bug SQL serupa pada query stok menipis — sekarang grafik & ringkasan admin tampil normal.

**Fitur yang sebelumnya kosong, sekarang berfungsi penuh (Aplikasi Flutter):**
- **Addresses** — kelola alamat pengiriman (tambah, lihat, hapus, tandai alamat utama), terhubung ke backend.
- **Account Details** — edit nama & nomor telepon, tersimpan ke server.
- **Notifikasi** — daftar notifikasi status pesanan realtime, tombol lonceng di Beranda & Akun kini aktif dan menampilkan halaman notifikasi.
- **Ulasan Produk** — pengguna kini bisa memberi rating & komentar langsung dari halaman detail produk, dan ulasan orang lain tampil di sana.
- **Status pesanan realtime** — halaman "Riwayat Pesanan" kini otomatis memperbarui status saat admin mengubahnya di dashboard (sebelumnya hanya lewat refresh manual).

Seluruh alur backend (auth, produk, keranjang, favorit, alamat, checkout, status pesanan, notifikasi, statistik dashboard) sudah diuji ulang end-to-end dan berjalan sesuai harapan.
