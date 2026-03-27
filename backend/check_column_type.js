const pool = require('./src/config/database');
async function checkTableColumnType() {
  try {
    const res = await pool.query(`
      SELECT column_name, udt_name 
      FROM information_schema.columns 
      WHERE table_name = 'complaints' AND column_name = 'status'
    `);
    console.log('Column status type:', res.rows[0].udt_name);
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}
checkTableColumnType();
