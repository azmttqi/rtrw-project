const pool = require('./src/config/database');

async function seedDashboard() {
  try {
    console.log('--- Seeding Dashboard Data (Layer 2-4) ---');

    // Get RW 01
    const rwRes = await pool.query("SELECT id FROM rws WHERE nomor_rw = '01'");
    if (rwRes.rows.length === 0) {
      console.log('❌ RW 01 not found. Please run seed.js first.');
      process.exit(1);
    }
    const rwId = rwRes.rows[0].id;

    // Get or Create RTs
    const rt01Res = await pool.query("SELECT id FROM rts WHERE rw_id = $1 AND nomor_rt = '01'", [rwId]);
    const rt02Res = await pool.query("SELECT id FROM rts WHERE rw_id = $1 AND nomor_rt = '02'", [rwId]);
    
    let rt01Id = rt01Res.rows[0]?.id;
    let rt02Id = rt02Res.rows[0]?.id;

    if (!rt02Id) {
      const newRt02 = await pool.query("INSERT INTO rts (rw_id, nomor_rt) VALUES ($1, '02') RETURNING id", [rwId]);
      rt02Id = newRt02.rows[0].id;
      console.log('✔ Created RT 02');
    }

    // 1. Seed Announcements (Layer 2)
    await pool.query("DELETE FROM announcements WHERE judul IN ('Jadwal Fogging Mingguan', 'Pesta Rakyat HUT RI')");
    await pool.query(`
      INSERT INTO announcements (judul, konten, target, target_rt_id, is_kegiatan)
      VALUES 
      ('Jadwal Fogging Mingguan', 'Pelaksanaan fogging akan dilaksanakan hari Sabtu jam 08.00 - 11.00 WIB.', 'SEMUA_RW', null, true),
      ('Pesta Rakyat HUT RI', 'Mari rayakan kemerdekaan dengan lomba dan pesta rakyat di lapangan utama.', 'SEMUA_RW', null, true)
    `);
    console.log('✔ Seeded Announcements');

    // 2. Seed Complaints (Layer 4)
    // Need a user to be the reporter
    const userRes = await pool.query("SELECT id FROM users WHERE role = 'WARGA' LIMIT 1");
    if (userRes.rows.length > 0) {
      const userId = userRes.rows[0].id;
      await pool.query("DELETE FROM complaints WHERE judul IN ('Tempat Sampah Rusak', 'Lampu Jalan Mati')");
      await pool.query(`
        INSERT INTO complaints (pelapor_user_id, rt_id, judul, deskripsi, status)
        VALUES 
        ($1, $2, 'Tempat Sampah Rusak', 'Mohon izin untuk pengadaan tempat sampah organik di gang Mawar.', 'PENDING'),
        ($1, $2, 'Lampu Jalan Mati', 'Lampu jalan di depan portal RT 01 mati sudah 3 hari.', 'PENDING')
      `, [userId, rt01Id]);
      console.log('✔ Seeded Complaints');
    }

    // 3. Seed Dues for financial status (Layer 3)
    const currentMonth = new Date().getMonth() + 1;
    const currentYear = new Date().getFullYear();

    // Ensure some families in RT 01 and RT 02
    const families01 = await pool.query("SELECT id FROM families WHERE rt_id = $1", [rt01Id]);
    const families02 = await pool.query("SELECT id FROM families WHERE rt_id = $1", [rt02Id]);

    if (families01.rows.length > 0) {
      await pool.query(`
        INSERT INTO dues_payments (pembayar_family_id, bulan, tahun, nominal, metode_bayar, status)
        VALUES ($1, $2, $3, 50000, 'CASH', 'APPROVED')
        ON CONFLICT DO NOTHING
      `, [families01.rows[0].id, currentMonth, currentYear]);
      console.log('✔ Seeded Payment for RT 01');
    }

    console.log('--- Dashboard Seeding Completed ---');
    await pool.end();
    process.exit(0);
  } catch (err) {
    console.error('❌ Seeding failed:', err);
    process.exit(1);
  }
}

seedDashboard();
