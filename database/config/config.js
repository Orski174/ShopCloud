require('dotenv').config({ path: '../.env' });

module.exports = {
  development: {
    username: process.env.DB_USER || 'shopcloud',
    password: process.env.DB_PASS || 'shopcloud_secret',
    database: process.env.DB_NAME || 'shopcloud_dev',
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    dialect: 'postgres',
    logging: false,
  },
  production: {
    username: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_NAME,
    host: process.env.DB_HOST,
    port: process.env.DB_PORT || 5432,
    dialect: 'postgres',
    logging: false,
    dialectOptions: {
      ssl: {
        require: true,
        rejectUnauthorized: false,
      },
    },
  },
};
