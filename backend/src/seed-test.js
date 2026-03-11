const pool = require('./config/database');

async function seed() {
  try {
    const resRw = await pool.query("INSERT INTO rws (nomor_rw) VALUES ('01') ON CONFLICT (nomor_rw) DO UPDATE SET nomor_rw=EXCLUDED.nomor_rw RETURNING id");
    const rwId = resRw.rows[0].id;
    const resRt = await pool.query("INSERT INTO rts (rw_id, nomor_rt) VALUES ($1, '01') ON CONFLICT (rw_id, nomor_rt) DO UPDATE SET nomor_rt=EXCLUDED.nomor_rt RETURNING id", [rwId]);
    console.log('RT_ID:', resRt.rows[0].id);
    
    // Create RT User
    const bcrypt = require('bcryptjs');
    const hash = await bcrypt.hash('rahasia123', 10);
    const rtUser = await pool.query(`INSERT INTO users (nama, no_wa, password_hash, role, rt_id, rw_id, is_verified) 
       VALUES ('Bapak RT', '089999999999', $1, 'RT', $2, null, true) RETURNING id`, [hash, resRt.rows[0].id]);
       
    console.log('RT User seeded successfully.');
    pool.end();
  } catch (e) {
    console.error(e);
    pool.end();
  }
}
seed();
