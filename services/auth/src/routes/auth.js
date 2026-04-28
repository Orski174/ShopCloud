const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const User = require('../models/User');
const AdminUser = require('../models/AdminUser');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

function signToken(payload) {
  return jwt.sign(payload, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });
}

// POST /auth/register
router.post(
  '/register',
  [
    body('email').isEmail().normalizeEmail(),
    body('password').isLength({ min: 8 }),
    body('name').trim().notEmpty(),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { email, password, name } = req.body;
    try {
      const existing = await User.findOne({ where: { email } });
      if (existing) return res.status(409).json({ error: 'Email already registered' });

      const password_hash = await bcrypt.hash(password, 12);
      const user = await User.create({ email, password_hash, name });

      const token = signToken({ userId: user.id, email: user.email, isAdmin: false });
      res.status(201).json({
        token,
        user: { id: user.id, email: user.email, name: user.name },
      });
    } catch (err) {
      res.status(500).json({ error: 'Registration failed', message: err.message });
    }
  }
);

// POST /auth/login
router.post(
  '/login',
  [body('email').isEmail().normalizeEmail(), body('password').notEmpty()],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { email, password } = req.body;
    try {
      const user = await User.findOne({ where: { email } });
      if (!user) return res.status(401).json({ error: 'Invalid credentials' });

      const valid = await bcrypt.compare(password, user.password_hash);
      if (!valid) return res.status(401).json({ error: 'Invalid credentials' });

      const token = signToken({ userId: user.id, email: user.email, isAdmin: false });
      res.json({ token, user: { id: user.id, email: user.email, name: user.name } });
    } catch (err) {
      res.status(500).json({ error: 'Login failed', message: err.message });
    }
  }
);

// POST /auth/admin/login
router.post(
  '/admin/login',
  [body('email').isEmail().normalizeEmail(), body('password').notEmpty()],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { email, password } = req.body;
    try {
      const admin = await AdminUser.findOne({ where: { email } });
      if (!admin) return res.status(401).json({ error: 'Invalid credentials' });

      const valid = await bcrypt.compare(password, admin.password_hash);
      if (!valid) return res.status(401).json({ error: 'Invalid credentials' });

      const token = signToken({
        userId: admin.id,
        email: admin.email,
        isAdmin: true,
        role: admin.role,
      });
      res.json({
        token,
        user: { id: admin.id, email: admin.email, name: admin.name, role: admin.role },
      });
    } catch (err) {
      res.status(500).json({ error: 'Login failed', message: err.message });
    }
  }
);

// GET /auth/me  (requires valid JWT)
router.get('/me', authenticateToken, async (req, res) => {
  try {
    if (req.user.isAdmin) {
      const admin = await AdminUser.findByPk(req.user.userId, {
        attributes: ['id', 'email', 'name', 'role'],
      });
      return res.json({ user: admin, isAdmin: true });
    }
    const user = await User.findByPk(req.user.userId, {
      attributes: ['id', 'email', 'name'],
    });
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json({ user, isAdmin: false });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch user', message: err.message });
  }
});

// POST /auth/logout  (client-side token invalidation — stateless)
router.post('/logout', (req, res) => {
  res.json({ message: 'Logged out successfully' });
});

module.exports = router;
