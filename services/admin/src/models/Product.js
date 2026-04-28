const { DataTypes } = require('sequelize');
const sequelize = require('../db');
const Category = require('./Category');

const Product = sequelize.define(
  'Product',
  {
    id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
    category_id: { type: DataTypes.UUID, allowNull: true },
    name: { type: DataTypes.STRING(255), allowNull: false },
    description: { type: DataTypes.TEXT, allowNull: true },
    price: { type: DataTypes.DECIMAL(10, 2), allowNull: false },
    stock_quantity: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 0 },
    image_url: { type: DataTypes.STRING(500), allowNull: true },
  },
  { tableName: 'products', underscored: true }
);

Product.belongsTo(Category, { foreignKey: 'category_id', as: 'category' });
Category.hasMany(Product, { foreignKey: 'category_id', as: 'products' });

module.exports = Product;
