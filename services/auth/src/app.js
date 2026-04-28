require('dotenv').config();
const express = require('express');
const cors = require('cors');
const sequelize = require('./db');
const authRoutes = require('./routes/auth');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/auth', authRoutes);

app.get('/health', async (req, res) => {
  try {
    await sequelize.authenticate();
    res.json({ status: 'ok', service: 'auth', timestamp: new Date().toISOString() });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

module.exports = app;
