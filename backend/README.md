# Zentra Store — Backend API

Backend tunggal (Node.js + Express + SQLite + Socket.io) yang menjadi
**sumber data bersama** untuk Admin Dashboard (React) dan Aplikasi Customer
(Flutter). Setiap perubahan produk/harga/stok di admin langsung
di-broadcast realtime lewat Socket.io ke semua client yang terhubung.

## Menjalankan

```bash
cd backend
npm install
cp .env.example .env
npm start
```

Server berjalan di `http://localhost:4000`. Database SQLite (`zentra.db`)
akan otomatis dibuat dan diisi data contoh saat pertama kali dijalankan.

## Akun Demo

| Role     | Email              | Password    |
|----------|--------------------|--------------|
| Admin    | admin@zentra.id    | admin123     |
| Customer | customer@zentra.id | customer123  |

## Endpoint Utama

- `POST /api/auth/login`, `POST /api/auth/register`, `GET /api/auth/me`
- `GET/POST/PUT/DELETE /api/products`, `PATCH /api/products/:id/stock`
- `GET/POST /api/orders`, `PATCH /api/orders/:id/status`
- `GET/POST/PUT/DELETE /api/cart`
- `GET/POST/DELETE /api/favorites`
- `GET /api/users` (admin), `PUT /api/users/me`, `/api/users/me/addresses`
- `GET /api/dashboard/stats` (admin — untuk grafik & ringkasan)

## Realtime Events (Socket.io)

- `product:created`, `product:updated`, `product:deleted`
- `order:created`, `order:updated`

Kedua client (Admin Dashboard & Flutter app) mendengarkan event yang sama
sehingga data harga/stok selalu konsisten di mana pun perubahan dilakukan.
