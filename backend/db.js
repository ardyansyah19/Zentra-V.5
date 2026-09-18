// db.js — Inisialisasi database SQLite (satu-satunya sumber data,
// dipakai bersama oleh Admin Dashboard (React) & Aplikasi Customer (Flutter))
const Database = require('better-sqlite3');
const bcrypt = require('bcryptjs');
const { v4: uuid } = require('uuid');
const path = require('path');

const db = new Database(path.join(__dirname, 'zentra.db'));
db.pragma('journal_mode = WAL');

db.exec(`
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'customer', -- 'admin' | 'customer'
  avatar TEXT,
  phone TEXT,
  address TEXT,
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  icon TEXT
);

CREATE TABLE IF NOT EXISTS products (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  price REAL NOT NULL,
  discount_price REAL,
  stock INTEGER NOT NULL DEFAULT 0,
  sold INTEGER NOT NULL DEFAULT 0,
  category_id TEXT,
  image TEXT,
  rating REAL DEFAULT 0,
  review_count INTEGER DEFAULT 0,
  is_featured INTEGER DEFAULT 0,
  is_popular INTEGER DEFAULT 0,
  status TEXT DEFAULT 'active', -- 'active' | 'archived'
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (category_id) REFERENCES categories(id)
);

CREATE TABLE IF NOT EXISTS reviews (
  id TEXT PRIMARY KEY,
  product_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  rating INTEGER NOT NULL,
  comment TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (product_id) REFERENCES products(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS favorites (
  user_id TEXT NOT NULL,
  product_id TEXT NOT NULL,
  created_at TEXT DEFAULT (datetime('now')),
  PRIMARY KEY (user_id, product_id)
);

CREATE TABLE IF NOT EXISTS cart_items (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  product_id TEXT NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 1,
  variant TEXT,
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS addresses (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  label TEXT,
  recipient TEXT,
  phone TEXT,
  full_address TEXT,
  is_default INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS orders (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  items TEXT NOT NULL, -- JSON snapshot [{product_id,name,price,qty,image}]
  subtotal REAL NOT NULL,
  shipping_fee REAL DEFAULT 0,
  total REAL NOT NULL,
  status TEXT DEFAULT 'pending', -- pending -> processing -> shipped -> delivered -> cancelled
  address TEXT,
  payment_method TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS notifications (
  id TEXT PRIMARY KEY,
  user_id TEXT,
  title TEXT,
  body TEXT,
  is_read INTEGER DEFAULT 0,
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS vouchers (
  id TEXT PRIMARY KEY,
  code TEXT UNIQUE NOT NULL,
  type TEXT NOT NULL, -- 'percent' | 'fixed'
  value REAL NOT NULL,
  min_spend REAL DEFAULT 0,
  active INTEGER DEFAULT 1,
  expires_at TEXT
);
`);

// ---- Seeding awal (hanya jika kosong) ----
const userCount = db.prepare('SELECT COUNT(*) c FROM users').get().c;
if (userCount === 0) {
  const insertUser = db.prepare(
    `INSERT INTO users (id,name,email,password,role,avatar,phone) VALUES (?,?,?,?,?,?,?)`
  );
  insertUser.run(
    uuid(), 'Admin Zentra', 'admin@zentra.id',
    bcrypt.hashSync('admin123', 8), 'admin',
    'https://i.pravatar.cc/150?img=12', '081234567890'
  );
  insertUser.run(
    uuid(), 'Jane Doe', 'customer@zentra.id',
    bcrypt.hashSync('customer123', 8), 'customer',
    'https://i.pravatar.cc/150?img=47', '081298765432'
  );

  const categories = [
    { name: 'Accessories', icon: 'diamond' },
    { name: 'Hoodies', icon: 'shirt' },
    { name: 'Footwear', icon: 'shoe' },
    { name: 'Bags', icon: 'bag' },
    { name: 'Eyewear', icon: 'glasses' },
  ];
  const insertCat = db.prepare(`INSERT INTO categories (id,name,icon) VALUES (?,?,?)`);
  const catIds = {};
  categories.forEach(c => {
    const id = uuid();
    catIds[c.name] = id;
    insertCat.run(id, c.name, c.icon);
  });

  const products = [
    { name: 'Knit Beanie', description: 'Beanie rajut lembut untuk cuaca dingin, cocok dipakai harian.', price: 89000, stock: 42, category: 'Accessories', image: 'https://images.unsplash.com/photo-1576871337622-98d48d1cf531?w=500', rating: 4.6, featured: 1 },
    { name: 'Woven Belt', description: 'Ikat pinggang anyaman kulit sintetis, gesper logam antikarat.', price: 159000, stock: 30, category: 'Accessories', image: 'https://images.unsplash.com/photo-1624222247344-550fb60583dc?w=500', rating: 4.3, featured: 1 },
    { name: 'Hoodie with Pocket', description: 'Hoodie premium dengan kantong depan dan bahan fleece tebal, hangat dan nyaman dipakai sehari-hari.', price: 329000, discount: 249000, stock: 18, category: 'Hoodies', image: 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=500', rating: 4.0, reviews: 2, popular: 1 },
    { name: 'V-Neck Knit Shirt', description: 'Kaus rajut V-neck, adem dan nyaman untuk aktivitas sehari-hari.', price: 149000, stock: 25, category: 'Hoodies', image: 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=500', rating: 4.4, popular: 1 },
    { name: 'LA Snapback Cap', description: 'Topi snapback bordir klasik, adjustable strap.', price: 119000, stock: 60, category: 'Accessories', image: 'https://images.unsplash.com/photo-1588850561407-ed78c282e89b?w=500', rating: 4.5 },
    { name: 'Retro Sunglasses', description: 'Kacamata hitam gaya retro, lensa anti-UV.', price: 199000, stock: 22, category: 'Eyewear', image: 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=500', rating: 4.2 },
    { name: 'Canvas Tote Bag', description: 'Tas kanvas serbaguna, kuat dan ramah lingkungan.', price: 179000, stock: 40, category: 'Bags', image: 'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=500', rating: 4.7, featured: 1 },
    { name: 'Classic Sneakers', description: 'Sepatu sneakers putih klasik, cocok untuk segala outfit.', price: 459000, stock: 15, category: 'Footwear', image: 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=500', rating: 4.8, popular: 1 },
  ];
  const insertProd = db.prepare(
    `INSERT INTO products (id,name,description,price,discount_price,stock,category_id,image,rating,review_count,is_featured,is_popular)
     VALUES (@id,@name,@description,@price,@discount_price,@stock,@category_id,@image,@rating,@review_count,@is_featured,@is_popular)`
  );
  products.forEach(p => {
    insertProd.run({
      id: uuid(),
      name: p.name,
      description: p.description,
      price: p.price,
      discount_price: p.discount || null,
      stock: p.stock,
      category_id: catIds[p.category],
      image: p.image,
      rating: p.rating || 0,
      review_count: p.reviews || 0,
      is_featured: p.featured || 0,
      is_popular: p.popular || 0,
    });
  });

  console.log('✅ Database berhasil di-seed dengan data awal.');
  console.log('   Login Admin    : admin@zentra.id / admin123');
  console.log('   Login Customer : customer@zentra.id / customer123');
}

module.exports = db;
