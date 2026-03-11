require('dotenv').config();
const app = require('./app');
const pool = require('./config/database');
const { errorHandler, notFoundHandler } = require('./middleware/error.middleware');

const PORT = process.env.PORT || 3000;

app.use(notFoundHandler);
app.use(errorHandler);

// Test database connection
pool.query('SELECT NOW()', (err, res) => {
  if (err) {
    console.error('Failed to connect to PostgreSQL database:', err);
  } else {
    console.log('Successfully connected to PostgreSQL database.');
  }
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
