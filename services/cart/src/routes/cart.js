const express = require('express');
const { body, param, validationResult } = require('express-validator');
const { GetCommand, PutCommand, UpdateCommand, DeleteCommand } = require('@aws-sdk/lib-dynamodb');
const { docClient } = require('../dynamo');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();
const TABLE = process.env.DYNAMODB_TABLE || 'shopcloud-carts';
const TTL_SECONDS = parseInt(process.env.CART_TTL_SECONDS || '604800'); // 7 days

function ttlTimestamp() {
  return Math.floor(Date.now() / 1000) + TTL_SECONDS;
}

// GET /cart/:userId  — get full cart
router.get('/:userId', authenticateToken, async (req, res) => {
  if (req.user.userId !== req.params.userId && !req.user.isAdmin) {
    return res.status(403).json({ error: 'Access denied' });
  }
  try {
    const result = await docClient.send(
      new GetCommand({ TableName: TABLE, Key: { userId: req.params.userId } })
    );
    if (!result.Item) return res.json({ userId: req.params.userId, items: [] });
    res.json(result.Item);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch cart', message: err.message });
  }
});

// POST /cart/:userId/items  — add or update item quantity
router.post(
  '/:userId/items',
  authenticateToken,
  [
    body('productId').notEmpty(),
    body('name').notEmpty(),
    body('price').isFloat({ min: 0 }),
    body('quantity').isInt({ min: 1 }),
  ],
  async (req, res) => {
    if (req.user.userId !== req.params.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { productId, name, price, quantity } = req.body;
    const { userId } = req.params;

    try {
      // Fetch existing cart
      const result = await docClient.send(
        new GetCommand({ TableName: TABLE, Key: { userId } })
      );

      let items = result.Item ? result.Item.items || [] : [];
      const existingIdx = items.findIndex((i) => i.productId === productId);

      if (existingIdx >= 0) {
        items[existingIdx].quantity += quantity;
      } else {
        items.push({ productId, name, price, quantity });
      }

      await docClient.send(
        new PutCommand({
          TableName: TABLE,
          Item: { userId, items, updatedAt: new Date().toISOString(), ttl: ttlTimestamp() },
        })
      );

      res.json({ userId, items });
    } catch (err) {
      res.status(500).json({ error: 'Failed to add item', message: err.message });
    }
  }
);

// PUT /cart/:userId/items/:productId  — set exact quantity
router.put(
  '/:userId/items/:productId',
  authenticateToken,
  [body('quantity').isInt({ min: 0 })],
  async (req, res) => {
    if (req.user.userId !== req.params.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { userId, productId } = req.params;
    const { quantity } = req.body;

    try {
      const result = await docClient.send(
        new GetCommand({ TableName: TABLE, Key: { userId } })
      );

      if (!result.Item) return res.status(404).json({ error: 'Cart not found' });

      let items = result.Item.items || [];

      if (quantity === 0) {
        items = items.filter((i) => i.productId !== productId);
      } else {
        const idx = items.findIndex((i) => i.productId === productId);
        if (idx < 0) return res.status(404).json({ error: 'Item not in cart' });
        items[idx].quantity = quantity;
      }

      await docClient.send(
        new PutCommand({
          TableName: TABLE,
          Item: { userId, items, updatedAt: new Date().toISOString(), ttl: ttlTimestamp() },
        })
      );

      res.json({ userId, items });
    } catch (err) {
      res.status(500).json({ error: 'Failed to update item', message: err.message });
    }
  }
);

// DELETE /cart/:userId/items/:productId  — remove single item
router.delete('/:userId/items/:productId', authenticateToken, async (req, res) => {
  if (req.user.userId !== req.params.userId) {
    return res.status(403).json({ error: 'Access denied' });
  }
  const { userId, productId } = req.params;

  try {
    const result = await docClient.send(
      new GetCommand({ TableName: TABLE, Key: { userId } })
    );
    if (!result.Item) return res.status(404).json({ error: 'Cart not found' });

    const items = (result.Item.items || []).filter((i) => i.productId !== productId);

    await docClient.send(
      new PutCommand({
        TableName: TABLE,
        Item: { userId, items, updatedAt: new Date().toISOString(), ttl: ttlTimestamp() },
      })
    );

    res.json({ userId, items });
  } catch (err) {
    res.status(500).json({ error: 'Failed to remove item', message: err.message });
  }
});

// DELETE /cart/:userId  — clear entire cart
router.delete('/:userId', authenticateToken, async (req, res) => {
  if (req.user.userId !== req.params.userId && !req.user.isAdmin) {
    return res.status(403).json({ error: 'Access denied' });
  }
  try {
    await docClient.send(
      new DeleteCommand({ TableName: TABLE, Key: { userId: req.params.userId } })
    );
    res.json({ message: 'Cart cleared' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to clear cart', message: err.message });
  }
});

module.exports = router;
