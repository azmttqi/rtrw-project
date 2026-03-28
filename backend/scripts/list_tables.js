const pool = require('./src/config/database');
async function listTables() {
  try {
    const res = await pool.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public'
    `);
    console.log('Tables:\n' + res.rows.map(r => '- ' + r.table_name).join('\n'));
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}
listTables();
