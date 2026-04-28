require('dotenv').config();
const express = require('express');
const cors = require('cors');
const sequelize = require('./db');
const checkoutRoutes = require('./routes/checkout');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/checkout', checkoutRoutes);
app.use('/orders', checkoutRoutes);

app.get('/health', async (req, res) => {
  try {
    await sequelize.authenticate();
    res.json({ status: 'ok', service: 'checkout', timestamp: new Date().toISOString() });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

module.exports = app;
