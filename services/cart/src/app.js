require('dotenv').config();
const express = require('express');
const cors = require('cors');
const cartRoutes = require('./routes/cart');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/cart', cartRoutes);

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'cart', timestamp: new Date().toISOString() });
});

module.exports = app;
