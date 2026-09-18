const express = require('express');
const db = require('../db');
const { authRequired } = require('../middleware/auth');

const router = express.Router();

router.get('/', authRequired, (req, res) => {
  const rows = db.prepare(`
    SELECT p.* FROM favorites f JOIN products p ON f.product_id = p.id
    WHERE f.user_id = ? ORDER BY f.created_at DESC`).all(req.user.id);
  res.json(rows);
});

router.post('/:productId', authRequired, (req, res) => {
  db.prepare('INSERT OR IGNORE INTO favorites (user_id, product_id) VALUES (?,?)')
    .run(req.user.id, req.params.productId);
  res.status(201).json({ success: true });
});

router.delete('/:productId', authRequired, (req, res) => {
  db.prepare('DELETE FROM favorites WHERE user_id = ? AND product_id = ?').run(req.user.id, req.params.productId);
  res.json({ success: true });
});

module.exports = router;
