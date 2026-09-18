const jwt = require('jsonwebtoken');
const SECRET = process.env.JWT_SECRET || 'zentra-super-secret-key-change-me';

function authRequired(req, res, next) {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Token tidak ditemukan' });
  }
  try {
    const token = header.split(' ')[1];
    const payload = jwt.verify(token, SECRET);
    req.user = payload;
    next();
  } catch (e) {
    return res.status(401).json({ error: 'Token tidak valid atau kedaluwarsa' });
  }
}

function adminOnly(req, res, next) {
  if (req.user?.role !== 'admin') {
    return res.status(403).json({ error: 'Akses khusus admin' });
  }
  next();
}

module.exports = { authRequired, adminOnly, SECRET };
