const pool = require('./src/config/database');
async function run() {
  const res = await pool.query("SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'dues_payments'");
  const fs = require('fs');
  fs.writeFileSync('dues_schema.json', JSON.stringify(res.rows, null, 2));
  process.exit(0);
}
run();
