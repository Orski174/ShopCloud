const { DataTypes } = require('sequelize');
const sequelize = require('../db');

const AdminUser = sequelize.define(
  'AdminUser',
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    email: {
      type: DataTypes.STRING(255),
      allowNull: false,
      unique: true,
      validate: { isEmail: true },
    },
    password_hash: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    name: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    role: {
      type: DataTypes.ENUM('admin', 'warehouse_staff'),
      allowNull: false,
      defaultValue: 'warehouse_staff',
    },
  },
  {
    tableName: 'admin_users',
    underscored: true,
  }
);

module.exports = AdminUser;
