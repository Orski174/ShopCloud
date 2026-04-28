const { DataTypes } = require('sequelize');
const sequelize = require('../db');

const Category = sequelize.define(
  'Category',
  {
    id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
    name: { type: DataTypes.STRING(100), allowNull: false },
    slug: { type: DataTypes.STRING(100), allowNull: false, unique: true },
    description: { type: DataTypes.TEXT, allowNull: true },
  },
  { tableName: 'categories', underscored: true }
);

module.exports = Category;
