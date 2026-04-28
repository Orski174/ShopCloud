require('dotenv').config();
const app = require('./app');

const PORT = process.env.PORT || 3006;

app.listen(PORT, () => console.log(`Invoice service HTTP running on port ${PORT}`));

// Also start the SQS worker in the same process
require('./worker');
