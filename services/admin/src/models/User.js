const { DataTypes } = require('sequelize');
const sequelize = require('../db');

const User = sequelize.define(
  'User',
  {
    id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
    email: { type: DataTypes.STRING(255), allowNull: false, unique: true },
    name: { type: DataTypes.STRING(255), allowNull: false },
  },
  { tableName: 'users', underscored: true }
);

module.exports = User;
