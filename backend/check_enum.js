const pool = require('./src/config/database');
async function checkEnum() {
  try {
    const res = await pool.query(`
      SELECT enumlabel
      FROM pg_type t 
      JOIN pg_enum e ON t.oid = e.enumtypid  
      WHERE t.typname = 'target_pengumuman'
    `);
    console.log('Target Enum labels:', res.rows.map(r => r.enumlabel).join(', '));
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}
checkEnum();
