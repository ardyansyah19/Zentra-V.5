const express = require('express');
const { v4: uuid } = require('uuid');
const db = require('../db');
const { authRequired, adminOnly } = require('../middleware/auth');

const router = express.Router();

// GET /api/orders — admin: semua order | customer: order miliknya saja
router.get('/', authRequired, (req, res) => {
  const rows = req.user.role === 'admin'
    ? db.prepare(`SELECT o.*, u.name as customer_name FROM orders o JOIN users u ON o.user_id=u.id ORDER BY o.created_at DESC`).all()
    : db.prepare('SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC').all(req.user.id);
  res.json(rows.map(o => ({ ...o, items: JSON.parse(o.items) })));
});

router.get('/:id', authRequired, (req, res) => {
  const o = db.prepare('SELECT * FROM orders WHERE id = ?').get(req.params.id);
  if (!o) return res.status(404).json({ error: 'Order tidak ditemukan' });
  if (req.user.role !== 'admin' && o.user_id !== req.user.id) {
    return res.status(403).json({ error: 'Tidak diizinkan' });
  }
  res.json({ ...o, items: JSON.parse(o.items) });
});

// POST /api/orders — checkout dari aplikasi customer. Stok otomatis berkurang & sinkron ke admin.
router.post('/', authRequired, (req, res) => {
  const { items, address, payment_method, shipping_fee = 0 } = req.body;
  if (!items || !items.length) return res.status(400).json({ error: 'Keranjang kosong' });

  const io = req.app.get('io');
  const snapshot = [];
  let subtotal = 0;

  const tx = db.transaction(() => {
    for (const it of items) {
      const product = db.prepare('SELECT * FROM products WHERE id = ?').get(it.product_id);
      if (!product) throw new Error(`Produk ${it.product_id} tidak ditemukan`);
      if (product.stock < it.quantity) throw new Error(`Stok ${product.name} tidak mencukupi`);

      const price = product.discount_price || product.price;
      subtotal += price * it.quantity;
      snapshot.push({ product_id: product.id, name: product.name, price, quantity: it.quantity, image: product.image });

      const newStock = product.stock - it.quantity;
      db.prepare(`UPDATE products SET stock = ?, sold = sold + ?, updated_at = datetime('now') WHERE id = ?`)
        .run(newStock, it.quantity, product.id);

      io.emit('product:updated', { ...product, stock: newStock, sold: (product.sold || 0) + it.quantity });
    }

    const id = uuid();
    const total = subtotal + Number(shipping_fee);
    db.prepare(`INSERT INTO orders (id,user_id,items,subtotal,shipping_fee,total,address,payment_method)
      VALUES (?,?,?,?,?,?,?,?)`)
      .run(id, req.user.id, JSON.stringify(snapshot), subtotal, shipping_fee, total, address || '', payment_method || 'cod');

    db.prepare('DELETE FROM cart_items WHERE user_id = ?').run(req.user.id);

    return db.prepare('SELECT * FROM orders WHERE id = ?').get(id);
  });

  try {
    const order = tx();
    io.emit('order:created', { ...order, items: JSON.parse(order.items) });
    res.status(201).json({ ...order, items: JSON.parse(order.items) });
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

// PATCH /api/orders/:id/status — admin mengubah status pesanan (realtime ke customer)
router.patch('/:id/status', authRequired, adminOnly, (req, res) => {
  const { status } = req.body;
  const valid = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];
  if (!valid.includes(status)) return res.status(400).json({ error: 'Status tidak valid' });

  db.prepare(`UPDATE orders SET status = ?, updated_at = datetime('now') WHERE id = ?`).run(status, req.params.id);
  const order = db.prepare('SELECT * FROM orders WHERE id = ?').get(req.params.id);

  const notifId = uuid();
  db.prepare('INSERT INTO notifications (id,user_id,title,body) VALUES (?,?,?,?)')
    .run(notifId, order.user_id, 'Status pesanan diperbarui', `Pesanan #${order.id.slice(0, 8)} kini: ${status}`);

  req.app.get('io').emit('order:updated', { ...order, items: JSON.parse(order.items) });
  res.json({ ...order, items: JSON.parse(order.items) });
});

module.exports = router;
