const pool = require('./src/config/database');
async function describeTables() {
  try {
    const tables = ['complaints', 'announcements', 'dues_payments', 'dues_bills'];
    for (const table of tables) {
      const res = await pool.query(`
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_name = $1
        ORDER BY ordinal_position
      `, [table]);
      console.log(`=== TABLE: ${table} ===`);
      res.rows.forEach(r => {
        console.log(`COLUMN: ${r.column_name} | TYPE: ${r.data_type}`);
      });
      console.log(`=== END TABLE: ${table} ===\n`);
    }
    console.log('--- ALL TABLES DESCRIBED ---');
    await pool.end();
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}
describeTables();
