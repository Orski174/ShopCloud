require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { body, validationResult } = require('express-validator');
const { processInvoiceJob } = require('./invoiceProcessor');

const app = express();

app.use(cors());
app.use(express.json());

// POST /invoice/generate  — HTTP endpoint for local dev / testing
app.post(
  '/invoice/generate',
  [
    body('orderId').notEmpty(),
    body('email').isEmail(),
    body('items').isArray({ min: 1 }),
    body('total').isFloat({ min: 0 }),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    try {
      const result = await processInvoiceJob(req.body);
      res.json({ message: 'Invoice generated', ...result });
    } catch (err) {
      res.status(500).json({ error: 'Invoice generation failed', message: err.message });
    }
  }
);

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'invoice', timestamp: new Date().toISOString() });
});

module.exports = app;
