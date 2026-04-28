require('dotenv').config();
const app = require('./app');
const sequelize = require('./db');

const PORT = process.env.PORT || 3001;

async function start() {
  try {
    await sequelize.authenticate();
    console.log('Database connection established.');
    app.listen(PORT, () => console.log(`Auth service running on port ${PORT}`));
  } catch (err) {
    console.error('Unable to connect to database:', err);
    process.exit(1);
  }
}

start();
