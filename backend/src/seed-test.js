const pool = require('./config/database');

async function seed() {
  try {
    const resRw = await pool.query("INSERT INTO rws (nomor_rw) VALUES ('01') ON CONFLICT (nomor_rw) DO UPDATE SET nomor_rw=EXCLUDED.nomor_rw RETURNING id");
    const rwId = resRw.rows[0].id;
    const resRt = await pool.query("INSERT INTO rts (rw_id, nomor_rt) VALUES ($1, '01') ON CONFLICT (rw_id, nomor_rt) DO UPDATE SET nomor_rt=EXCLUDED.nomor_rt RETURNING id", [rwId]);
    const rtId = resRt.rows[0].id;
    console.log('RT_ID:', rtId);
    
    const bcrypt = require('bcryptjs');
    const hash = await bcrypt.hash('rahasia123', 10);
    
    // Create RT User
    await pool.query(`INSERT INTO users (nama, no_wa, password_hash, role, rt_id, rw_id, is_verified) 
       VALUES ('Bapak RT', '089999999999', $1, 'RT', $2, null, true) ON CONFLICT (no_wa) DO UPDATE SET no_wa=EXCLUDED.no_wa`, [hash, rtId]);
    console.log('RT User seeded.');

    // Create Warga User
    const wargaUser = await pool.query(`INSERT INTO users (nama, no_wa, password_hash, role, rt_id, rw_id, is_verified) 
        VALUES ('Warga A', '081234567890', $1, 'WARGA', $2, null, true) ON CONFLICT (no_wa) DO UPDATE SET no_wa=EXCLUDED.no_wa RETURNING id`, [hash, rtId]);
    const wargaId = wargaUser.rows[0].id;
    console.log('Warga User seeded.');

    // Create Family for Warga A
    await pool.query(`INSERT INTO families (user_id, rt_id, no_kk, tipe_warga, status_tinggal, status_pernikahan, status_verifikasi)
        VALUES ($1, $2, '3201234567890001', 'LAMA', 'TETAP', 'KAWIN', 'APPROVED') ON CONFLICT (no_kk) DO UPDATE SET no_kk=EXCLUDED.no_kk`, 
        [wargaId, rtId]);
    console.log('Family seeded.');

    // Create RW User
    await pool.query(`INSERT INTO users (nama, no_wa, password_hash, role, rt_id, rw_id, is_verified) 
        VALUES ('Bapak RW', '087777777777', $1, 'RW', $2, $3, true) ON CONFLICT (no_wa) DO UPDATE SET no_wa=EXCLUDED.no_wa`, 
        [hash, rtId, rwId]);
    console.log('RW User seeded.');

    pool.end();
  } catch (e) {
    console.error(e);
    pool.end();
  }
}
seed();
