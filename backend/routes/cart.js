const express = require('express');
const { v4: uuid } = require('uuid');
const db = require('../db');
const { authRequired } = require('../middleware/auth');

const router = express.Router();

router.get('/', authRequired, (req, res) => {
  const rows = db.prepare(`
    SELECT c.id, c.quantity, c.variant, p.* FROM cart_items c
    JOIN products p ON c.product_id = p.id
    WHERE c.user_id = ?`).all(req.user.id);
  res.json(rows);
});

router.post('/', authRequired, (req, res) => {
  const { product_id, quantity = 1, variant } = req.body;
  const existing = db.prepare("SELECT * FROM cart_items WHERE user_id = ? AND product_id = ? AND IFNULL(variant,'') = IFNULL(?,'')")
    .get(req.user.id, product_id, variant ?? null);
  if (existing) {
    db.prepare('UPDATE cart_items SET quantity = quantity + ? WHERE id = ?').run(quantity, existing.id);
  } else {
    db.prepare('INSERT INTO cart_items (id,user_id,product_id,quantity,variant) VALUES (?,?,?,?,?)')
      .run(uuid(), req.user.id, product_id, quantity, variant || null);
  }
  res.status(201).json({ success: true });
});

router.put('/:id', authRequired, (req, res) => {
  const { quantity } = req.body;
  db.prepare('UPDATE cart_items SET quantity = ? WHERE id = ? AND user_id = ?').run(quantity, req.params.id, req.user.id);
  res.json({ success: true });
});

router.delete('/:id', authRequired, (req, res) => {
  db.prepare('DELETE FROM cart_items WHERE id = ? AND user_id = ?').run(req.params.id, req.user.id);
  res.json({ success: true });
});

module.exports = router;
