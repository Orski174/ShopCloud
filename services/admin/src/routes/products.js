const express = require('express');
const { body, validationResult } = require('express-validator');
const Product = require('../models/Product');
const Category = require('../models/Category');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

const router = express.Router();

// All admin routes require a valid admin JWT
router.use(authenticateToken, requireAdmin);

// GET /admin/products
router.get('/products', async (req, res) => {
  try {
    const { page = 1, limit = 50 } = req.query;
    const offset = (parseInt(page) - 1) * parseInt(limit);
    const { count, rows } = await Product.findAndCountAll({
      include: [{ model: Category, as: 'category' }],
      limit: parseInt(limit),
      offset,
      order: [['created_at', 'DESC']],
    });
    res.json({ products: rows, total: count, page: parseInt(page) });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch products', message: err.message });
  }
});

// POST /admin/products
router.post(
  '/products',
  [
    body('name').trim().notEmpty(),
    body('price').isFloat({ min: 0 }),
    body('stock_quantity').isInt({ min: 0 }),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });
    try {
      const product = await Product.create(req.body);
      res.status(201).json(product);
    } catch (err) {
      res.status(500).json({ error: 'Failed to create product', message: err.message });
    }
  }
);

// PUT /admin/products/:id
router.put('/products/:id', async (req, res) => {
  try {
    const product = await Product.findByPk(req.params.id);
    if (!product) return res.status(404).json({ error: 'Product not found' });
    await product.update(req.body);
    res.json(product);
  } catch (err) {
    res.status(500).json({ error: 'Failed to update product', message: err.message });
  }
});

// PUT /admin/products/:id/stock  — direct stock adjustment
router.put(
  '/products/:id/stock',
  [body('stock_quantity').isInt({ min: 0 })],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });
    try {
      const product = await Product.findByPk(req.params.id);
      if (!product) return res.status(404).json({ error: 'Product not found' });
      await product.update({ stock_quantity: req.body.stock_quantity });
      res.json({ id: product.id, stock_quantity: product.stock_quantity });
    } catch (err) {
      res.status(500).json({ error: 'Failed to update stock', message: err.message });
    }
  }
);

// DELETE /admin/products/:id
router.delete('/products/:id', async (req, res) => {
  try {
    const product = await Product.findByPk(req.params.id);
    if (!product) return res.status(404).json({ error: 'Product not found' });
    await product.destroy();
    res.json({ message: 'Product deleted' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete product', message: err.message });
  }
});

module.exports = router;
