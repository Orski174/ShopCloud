const express = require('express');
const { body, validationResult } = require('express-validator');
const Order = require('../models/Order');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

const router = express.Router();

router.use(authenticateToken, requireAdmin);

// GET /admin/orders
router.get('/orders', async (req, res) => {
  try {
    const { status, page = 1, limit = 50 } = req.query;
    const where = status ? { status } : {};
    const offset = (parseInt(page) - 1) * parseInt(limit);
    const { count, rows } = await Order.findAndCountAll({
      where,
      limit: parseInt(limit),
      offset,
      order: [['created_at', 'DESC']],
    });
    res.json({ orders: rows, total: count, page: parseInt(page) });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch orders', message: err.message });
  }
});

// GET /admin/orders/:id
router.get('/orders/:id', async (req, res) => {
  try {
    const order = await Order.findByPk(req.params.id);
    if (!order) return res.status(404).json({ error: 'Order not found' });
    res.json(order);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch order', message: err.message });
  }
});

// PUT /admin/orders/:id  — update status
router.put(
  '/orders/:id',
  [body('status').isIn(['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'])],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });
    try {
      const order = await Order.findByPk(req.params.id);
      if (!order) return res.status(404).json({ error: 'Order not found' });
      await order.update({ status: req.body.status });
      res.json(order);
    } catch (err) {
      res.status(500).json({ error: 'Failed to update order', message: err.message });
    }
  }
);

module.exports = router;
