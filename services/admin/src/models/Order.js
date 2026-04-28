const { DataTypes } = require('sequelize');
const sequelize = require('../db');

const Order = sequelize.define(
  'Order',
  {
    id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
    user_id: { type: DataTypes.UUID, allowNull: false },
    status: {
      type: DataTypes.ENUM('pending', 'confirmed', 'shipped', 'delivered', 'cancelled'),
      defaultValue: 'pending',
    },
    total_amount: { type: DataTypes.DECIMAL(10, 2), allowNull: false },
    payment_status: {
      type: DataTypes.ENUM('pending', 'paid', 'failed', 'refunded'),
      defaultValue: 'pending',
    },
    shipping_address: { type: DataTypes.JSONB, allowNull: true },
  },
  { tableName: 'orders', underscored: true }
);

module.exports = Order;
