const express = require('express');
const User = require('../models/User');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

const router = express.Router();

router.use(authenticateToken, requireAdmin);

// GET /admin/users
router.get('/users', async (req, res) => {
  try {
    const { page = 1, limit = 50 } = req.query;
    const offset = (parseInt(page) - 1) * parseInt(limit);
    const { count, rows } = await User.findAndCountAll({
      attributes: ['id', 'email', 'name', 'created_at'],
      limit: parseInt(limit),
      offset,
      order: [['created_at', 'DESC']],
    });
    res.json({ users: rows, total: count, page: parseInt(page) });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch users', message: err.message });
  }
});

// GET /admin/users/:id
router.get('/users/:id', async (req, res) => {
  try {
    const user = await User.findByPk(req.params.id, {
      attributes: ['id', 'email', 'name', 'created_at'],
    });
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch user', message: err.message });
  }
});

module.exports = router;
