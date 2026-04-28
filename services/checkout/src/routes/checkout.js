const express = require('express');
const axios = require('axios');
const { body, validationResult } = require('express-validator');
const sequelize = require('../db');
const Order = require('../models/Order');
const OrderItem = require('../models/OrderItem');
const { authenticateToken, requireAdmin } = require('../middleware/auth');
const { publishInvoiceJob } = require('../sqs');

const router = express.Router();

const CATALOG_URL = process.env.CATALOG_SERVICE_URL || 'http://catalog:3002';
const CART_URL = process.env.CART_SERVICE_URL || 'http://cart:3003';

// POST /checkout  — place an order
router.post(
  '/',
  authenticateToken,
  [
    body('shipping_address').isObject(),
    body('shipping_address.line1').notEmpty(),
    body('shipping_address.city').notEmpty(),
    body('shipping_address.country').notEmpty(),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const userId = req.user.userId;
    const { shipping_address } = req.body;

    let cart;
    try {
      const cartResp = await axios.get(`${CART_URL}/cart/${userId}`, {
        headers: { Authorization: req.headers['authorization'] },
      });
      cart = cartResp.data;
    } catch (err) {
      return res.status(502).json({ error: 'Failed to fetch cart', message: err.message });
    }

    if (!cart.items || cart.items.length === 0) {
      return res.status(400).json({ error: 'Cart is empty' });
    }

    // Validate stock for each item via catalog service
    const stockErrors = [];
    for (const item of cart.items) {
      try {
        const prodResp = await axios.get(`${CATALOG_URL}/products/${item.productId}`);
        const product = prodResp.data;
        if (product.stock_quantity < item.quantity) {
          stockErrors.push({
            productId: item.productId,
            name: item.name,
            requested: item.quantity,
            available: product.stock_quantity,
          });
        }
      } catch (err) {
        return res.status(502).json({ error: `Failed to validate stock for ${item.name}` });
      }
    }

    if (stockErrors.length > 0) {
      return res.status(409).json({ error: 'Insufficient stock', items: stockErrors });
    }

    // Compute total
    const total_amount = cart.items.reduce(
      (sum, i) => sum + parseFloat(i.price) * i.quantity,
      0
    );

    const t = await sequelize.transaction();
    let order;
    try {
      // Create order
      order = await Order.create(
        { user_id: userId, total_amount, payment_status: 'pending', shipping_address },
        { transaction: t }
      );

      // Create order items
      const orderItems = cart.items.map((item) => ({
        order_id: order.id,
        product_id: item.productId,
        quantity: item.quantity,
        unit_price: item.price,
      }));
      await OrderItem.bulkCreate(orderItems, { transaction: t });

      // Decrement stock for each item via catalog PATCH (admin token not available here
      // so catalog service exposes an internal stock decrement endpoint)
      for (const item of cart.items) {
        await axios.patch(
          `${CATALOG_URL}/products/${item.productId}/stock`,
          { decrement: item.quantity },
          { headers: { 'X-Internal-Service': 'checkout' } }
        );
      }

      // Simulate payment confirmation
      await order.update({ status: 'confirmed', payment_status: 'paid' }, { transaction: t });

      await t.commit();
    } catch (err) {
      await t.rollback();
      return res.status(500).json({ error: 'Order creation failed', message: err.message });
    }

    // Clear cart asynchronously (fire-and-forget)
    axios
      .delete(`${CART_URL}/cart/${userId}`, {
        headers: { Authorization: req.headers['authorization'] },
      })
      .catch((err) => console.error('Failed to clear cart after checkout:', err.message));

    // Publish invoice generation job to SQS
    publishInvoiceJob({
      orderId: order.id,
      userId,
      email: req.user.email,
      items: cart.items,
      total: total_amount,
      shippingAddress: shipping_address,
    }).catch((err) => console.error('Failed to publish invoice job:', err.message));

    // Reload order with items
    const fullOrder = await Order.findByPk(order.id, { include: [{ model: OrderItem, as: 'items' }] });
    res.status(201).json(fullOrder);
  }
);

// GET /orders  — list orders for current user
router.get('/', authenticateToken, async (req, res) => {
  try {
    const where = req.user.isAdmin ? {} : { user_id: req.user.userId };
    const orders = await Order.findAll({
      where,
      include: [{ model: OrderItem, as: 'items' }],
      order: [['created_at', 'DESC']],
    });
    res.json(orders);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch orders', message: err.message });
  }
});

// GET /orders/:id  — get single order
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const order = await Order.findByPk(req.params.id, {
      include: [{ model: OrderItem, as: 'items' }],
    });
    if (!order) return res.status(404).json({ error: 'Order not found' });

    // Only owner or admin can view
    if (order.user_id !== req.user.userId && !req.user.isAdmin) {
      return res.status(403).json({ error: 'Access denied' });
    }

    res.json(order);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch order', message: err.message });
  }
});

module.exports = router;
