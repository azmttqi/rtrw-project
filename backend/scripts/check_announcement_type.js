const pool = require('./src/config/database');
async function checkAnnouncementTargetType() {
  try {
    const res = await pool.query(`
      SELECT column_name, udt_name 
      FROM information_schema.columns 
      WHERE table_name = 'announcements' AND column_name = 'target'
    `);
    console.log('Column target type:', res.rows[0]?.udt_name);
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}
checkAnnouncementTargetType();
