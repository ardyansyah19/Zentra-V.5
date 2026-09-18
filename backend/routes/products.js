const express = require('express');
const { v4: uuid } = require('uuid');
const db = require('../db');
const { authRequired, adminOnly } = require('../middleware/auth');

const router = express.Router();

function withCategory(p) {
  if (!p) return p;
  const cat = db.prepare('SELECT name FROM categories WHERE id = ?').get(p.category_id);
  return { ...p, category: cat ? cat.name : null };
}

// GET /api/products  — dipakai Admin & Customer (query: category, search, featured, popular)
router.get('/', (req, res) => {
  const { category, search, featured, popular, status } = req.query;
  let sql = 'SELECT * FROM products WHERE 1=1';
  const params = [];

  if (status) {
    sql += ' AND status = ?';
    params.push(status);
  } else {
    sql += " AND status != 'archived'";
  }
  if (category) {
    sql += ' AND category_id = (SELECT id FROM categories WHERE name = ?)';
    params.push(category);
  }
  if (search) {
    sql += ' AND name LIKE ?';
    params.push(`%${search}%`);
  }
  if (featured) sql += ' AND is_featured = 1';
  if (popular) sql += ' AND is_popular = 1';
  sql += ' ORDER BY created_at DESC';

  const rows = db.prepare(sql).all(...params).map(withCategory);
  res.json(rows);
});

router.get('/categories/all', (req, res) => {
  res.json(db.prepare('SELECT * FROM categories').all());
});

router.get('/:id', (req, res) => {
  const p = db.prepare('SELECT * FROM products WHERE id = ?').get(req.params.id);
  if (!p) return res.status(404).json({ error: 'Produk tidak ditemukan' });
  const reviews = db.prepare('SELECT r.*, u.name as user_name FROM reviews r JOIN users u ON r.user_id=u.id WHERE product_id = ? ORDER BY r.created_at DESC').all(req.params.id);
  res.json({ ...withCategory(p), reviews });
});

// POST /api/products — admin only. Broadcast realtime ke semua client (sinkron harga/stok)
router.post('/', authRequired, adminOnly, (req, res) => {
  const { name, description, price, discount_price, stock, category_id, image, is_featured, is_popular } = req.body;
  if (!name || price == null || stock == null) {
    return res.status(400).json({ error: 'Nama, harga, dan stok wajib diisi' });
  }
  const id = uuid();
  db.prepare(`INSERT INTO products (id,name,description,price,discount_price,stock,category_id,image,is_featured,is_popular)
    VALUES (?,?,?,?,?,?,?,?,?,?)`)
    .run(id, name, description || '', price, discount_price || null, stock, category_id || null, image || '', is_featured ? 1 : 0, is_popular ? 1 : 0);

  const product = withCategory(db.prepare('SELECT * FROM products WHERE id = ?').get(id));
  req.app.get('io').emit('product:created', product);
  res.status(201).json(product);
});

// PUT /api/products/:id — admin only. Ini kunci sinkronisasi harga & stok.
router.put('/:id', authRequired, adminOnly, (req, res) => {
  const existing = db.prepare('SELECT * FROM products WHERE id = ?').get(req.params.id);
  if (!existing) return res.status(404).json({ error: 'Produk tidak ditemukan' });

  const fields = ['name', 'description', 'price', 'discount_price', 'stock', 'category_id', 'image', 'is_featured', 'is_popular', 'status'];
  const updates = {};
  fields.forEach(f => { if (req.body[f] !== undefined) updates[f] = req.body[f]; });

  const setClause = Object.keys(updates).map(k => `${k} = @${k}`).join(', ');
  if (setClause) {
    db.prepare(`UPDATE products SET ${setClause}, updated_at = datetime('now') WHERE id = @id`)
      .run({ ...updates, id: req.params.id });
  }

  const product = withCategory(db.prepare('SELECT * FROM products WHERE id = ?').get(req.params.id));
  // Broadcast realtime — inilah yang membuat harga & stok selalu sinkron
  // antara Dashboard Admin (React) dan Aplikasi Customer (Flutter)
  req.app.get('io').emit('product:updated', product);
  res.json(product);
});

// PATCH /api/products/:id/stock — shortcut cepat untuk update stok saja
router.patch('/:id/stock', authRequired, adminOnly, (req, res) => {
  const { stock } = req.body;
  if (stock == null) return res.status(400).json({ error: 'Field stock wajib diisi' });
  db.prepare(`UPDATE products SET stock = ?, updated_at = datetime('now') WHERE id = ?`).run(stock, req.params.id);
  const product = withCategory(db.prepare('SELECT * FROM products WHERE id = ?').get(req.params.id));
  req.app.get('io').emit('product:updated', product);
  res.json(product);
});

router.delete('/:id', authRequired, adminOnly, (req, res) => {
  db.prepare('DELETE FROM products WHERE id = ?').run(req.params.id);
  req.app.get('io').emit('product:deleted', { id: req.params.id });
  res.json({ success: true });
});

// ---- Reviews ----
router.post('/:id/reviews', authRequired, (req, res) => {
  const { rating, comment } = req.body;
  const id = uuid();
  db.prepare('INSERT INTO reviews (id,product_id,user_id,rating,comment) VALUES (?,?,?,?,?)')
    .run(id, req.params.id, req.user.id, rating, comment || '');

  const agg = db.prepare('SELECT AVG(rating) avg, COUNT(*) c FROM reviews WHERE product_id = ?').get(req.params.id);
  db.prepare('UPDATE products SET rating = ?, review_count = ? WHERE id = ?').run(agg.avg, agg.c, req.params.id);

  const product = withCategory(db.prepare('SELECT * FROM products WHERE id = ?').get(req.params.id));
  req.app.get('io').emit('product:updated', product);
  res.status(201).json({ success: true });
});

module.exports = router;
