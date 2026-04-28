require('dotenv').config();
const express = require('express');
const cors = require('cors');
const sequelize = require('./db');
const productRoutes = require('./routes/products');
const orderRoutes = require('./routes/orders');
const userRoutes = require('./routes/users');

const app = express();

// Admin service is internal-only; in production it should only be reachable via VPN/Internal ALB
app.use(cors({ origin: process.env.ALLOWED_ORIGIN || '*' }));
app.use(express.json());

app.use('/admin', productRoutes);
app.use('/admin', orderRoutes);
app.use('/admin', userRoutes);

app.get('/health', async (req, res) => {
  try {
    await sequelize.authenticate();
    res.json({ status: 'ok', service: 'admin', timestamp: new Date().toISOString() });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

module.exports = app;
