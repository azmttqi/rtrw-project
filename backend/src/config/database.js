const { Pool } = require('pg');

const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'karawang3',
  host: process.env.DB_HOST || '127.0.0.1',
  port: process.env.DB_PORT || 5433,
  database: process.env.NODE_ENV === 'test' ? 'rtrw_test' : (process.env.DB_NAME || 'rtrw'),
});

module.exports = pool;

