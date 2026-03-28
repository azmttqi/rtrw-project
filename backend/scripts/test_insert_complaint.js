const pool = require('./src/config/database');
async function testInsert() {
  try {
    const userRes = await pool.query("SELECT id FROM users WHERE role = 'WARGA' LIMIT 1");
    const rtRes = await pool.query("SELECT id FROM rts LIMIT 1");
    if (userRes.rows.length === 0 || rtRes.rows.length === 0) {
      console.log('User or RT not found');
      process.exit(1);
    }
    const userId = userRes.rows[0].id;
    const rtId = rtRes.rows[0].id;
    
    // Try without status to see default
    const res = await pool.query(`
      INSERT INTO complaints (pelapor_user_id, rt_id, judul, deskripsi)
      VALUES ($1, $2, 'Test Complaint', 'Test body')
      RETURNING *
    `, [userId, rtId]);
    console.log('Inserted with default status:', res.rows[0].status);
    
    // Try with 'PENDING' explicitly
    const res2 = await pool.query(`
      INSERT INTO complaints (pelapor_user_id, rt_id, judul, deskripsi, status)
      VALUES ($1, $2, 'Test Complaint 2', 'Test body 2', 'PENDING')
      RETURNING *
    `, [userId, rtId]);
    console.log('Inserted with PENDING status:', res2.rows[0].status);
    
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}
testInsert();
