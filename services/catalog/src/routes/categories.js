const express = require('express');
const Category = require('../models/Category');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

const router = express.Router();

// GET /categories  (public)
router.get('/', async (req, res) => {
  try {
    const categories = await Category.findAll({ order: [['name', 'ASC']] });
    res.json(categories);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch categories', message: err.message });
  }
});

// GET /categories/:slug  (public)
router.get('/:slug', async (req, res) => {
  try {
    const category = await Category.findOne({ where: { slug: req.params.slug } });
    if (!category) return res.status(404).json({ error: 'Category not found' });
    res.json(category);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch category', message: err.message });
  }
});

// POST /categories  (admin only)
router.post('/', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const category = await Category.create(req.body);
    res.status(201).json(category);
  } catch (err) {
    res.status(500).json({ error: 'Failed to create category', message: err.message });
  }
});

// PUT /categories/:id  (admin only)
router.put('/:id', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const category = await Category.findByPk(req.params.id);
    if (!category) return res.status(404).json({ error: 'Category not found' });
    await category.update(req.body);
    res.json(category);
  } catch (err) {
    res.status(500).json({ error: 'Failed to update category', message: err.message });
  }
});

module.exports = router;
