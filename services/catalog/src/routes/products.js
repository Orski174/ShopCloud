const express = require('express');
const { Op } = require('sequelize');
const { body, query, param, validationResult } = require('express-validator');
const Product = require('../models/Product');
const Category = require('../models/Category');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

const router = express.Router();

// GET /products  (public, with optional search and category filter)
router.get('/', async (req, res) => {
  try {
    const { q, category, page = 1, limit = 20 } = req.query;
    const where = {};
    const offset = (parseInt(page) - 1) * parseInt(limit);

    if (q) {
      where[Op.or] = [
        { name: { [Op.iLike]: `%${q}%` } },
        { description: { [Op.iLike]: `%${q}%` } },
      ];
    }

    if (category) {
      const cat = await Category.findOne({ where: { slug: category } });
      if (cat) where.category_id = cat.id;
    }

    const { count, rows } = await Product.findAndCountAll({
      where,
      include: [{ model: Category, as: 'category', attributes: ['id', 'name', 'slug'] }],
      limit: parseInt(limit),
      offset,
      order: [['created_at', 'DESC']],
    });

    res.json({
      products: rows,
      total: count,
      page: parseInt(page),
      pages: Math.ceil(count / parseInt(limit)),
    });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch products', message: err.message });
  }
});

// GET /products/search  (explicit search endpoint)
router.get('/search', async (req, res) => {
  try {
    const { q, page = 1, limit = 20 } = req.query;
    if (!q) return res.status(400).json({ error: 'Search query required' });

    const offset = (parseInt(page) - 1) * parseInt(limit);
    const { count, rows } = await Product.findAndCountAll({
      where: {
        [Op.or]: [
          { name: { [Op.iLike]: `%${q}%` } },
          { description: { [Op.iLike]: `%${q}%` } },
        ],
      },
      include: [{ model: Category, as: 'category', attributes: ['id', 'name', 'slug'] }],
      limit: parseInt(limit),
      offset,
      order: [['created_at', 'DESC']],
    });

    res.json({ products: rows, total: count, query: q });
  } catch (err) {
    res.status(500).json({ error: 'Search failed', message: err.message });
  }
});

// GET /products/:id  (public)
router.get('/:id', async (req, res) => {
  try {
    const product = await Product.findByPk(req.params.id, {
      include: [{ model: Category, as: 'category' }],
    });
    if (!product) return res.status(404).json({ error: 'Product not found' });
    res.json(product);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch product', message: err.message });
  }
});

// POST /products  (admin only)
router.post(
  '/',
  authenticateToken,
  requireAdmin,
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

// PUT /products/:id  (admin only)
router.put('/:id', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const product = await Product.findByPk(req.params.id);
    if (!product) return res.status(404).json({ error: 'Product not found' });
    await product.update(req.body);
    res.json(product);
  } catch (err) {
    res.status(500).json({ error: 'Failed to update product', message: err.message });
  }
});

// DELETE /products/:id  (admin only)
router.delete('/:id', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const product = await Product.findByPk(req.params.id);
    if (!product) return res.status(404).json({ error: 'Product not found' });
    await product.destroy();
    res.json({ message: 'Product deleted' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete product', message: err.message });
  }
});

// PATCH /products/:id/stock  — internal endpoint for checkout service to decrement stock
router.patch('/:id/stock', async (req, res) => {
  const internalHeader = req.headers['x-internal-service'];
  if (internalHeader !== 'checkout') {
    return res.status(403).json({ error: 'Internal endpoint only' });
  }
  const { decrement } = req.body;
  if (!Number.isInteger(decrement) || decrement < 1) {
    return res.status(400).json({ error: 'Invalid decrement value' });
  }
  try {
    const product = await Product.findByPk(req.params.id);
    if (!product) return res.status(404).json({ error: 'Product not found' });
    if (product.stock_quantity < decrement) {
      return res.status(409).json({ error: 'Insufficient stock' });
    }
    await product.update({ stock_quantity: product.stock_quantity - decrement });
    res.json({ id: product.id, stock_quantity: product.stock_quantity });
  } catch (err) {
    res.status(500).json({ error: 'Stock update failed', message: err.message });
  }
});

module.exports = router;
