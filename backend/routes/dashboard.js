const express = require('express');
const db = require('../db');
const { authRequired, adminOnly } = require('../middleware/auth');

const router = express.Router();

router.get('/stats', authRequired, adminOnly, (req, res) => {
  const totalRevenue = db.prepare(`SELECT IFNULL(SUM(total),0) v FROM orders WHERE status != 'cancelled'`).get().v;
  const totalOrders = db.prepare('SELECT COUNT(*) c FROM orders').get().c;
  const totalCustomers = db.prepare(`SELECT COUNT(*) c FROM users WHERE role = 'customer'`).get().c;
  const totalProducts = db.prepare(`SELECT COUNT(*) c FROM products WHERE status != 'archived'`).get().c;
  const lowStock = db.prepare("SELECT id,name,stock,image FROM products WHERE stock <= 5 AND status != 'archived' ORDER BY stock ASC").all();
  const recentOrders = db.prepare(`
    SELECT o.id,o.total,o.status,o.created_at,u.name as customer_name
    FROM orders o JOIN users u ON o.user_id = u.id
    ORDER BY o.created_at DESC LIMIT 8`).all();
  const topProducts = db.prepare('SELECT id,name,image,sold,price FROM products ORDER BY sold DESC LIMIT 5').all();
  const salesByDay = db.prepare(`
    SELECT date(created_at) as day, SUM(total) as total
    FROM orders WHERE status != 'cancelled' AND created_at >= datetime('now','-7 days')
    GROUP BY day ORDER BY day ASC`).all();
  const ordersByStatus = db.prepare(`SELECT status, COUNT(*) c FROM orders GROUP BY status`).all();

  res.json({ totalRevenue, totalOrders, totalCustomers, totalProducts, lowStock, recentOrders, topProducts, salesByDay, ordersByStatus });
});

module.exports = router;
