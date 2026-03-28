require('dotenv').config();
const pool = require('../src/config/database');
const bcrypt = require('bcryptjs');

async function seed() {
  try {
    console.log('--- Starting Seed Process ---');

    // 1. Setup RW & RT
    const resRw = await pool.query(`
      INSERT INTO rws (nomor_rw, nama_wilayah, alamat) 
      VALUES ('01', 'Tulip Residence', 'Jl. Tulip No. 123') 
      ON CONFLICT (nomor_rw) DO UPDATE SET 
        nama_wilayah=EXCLUDED.nama_wilayah, 
        alamat=EXCLUDED.alamat
      RETURNING id
    `);
    const rwId = resRw.rows[0].id;
    console.log('✔ RW seeded:', rwId);

    const resRt = await pool.query(`
      INSERT INTO rts (rw_id, nomor_rt) VALUES ($1, '01') 
      ON CONFLICT (rw_id, nomor_rt) DO UPDATE SET nomor_rt=EXCLUDED.nomor_rt 
      RETURNING id
    `, [rwId]);
    const rtId = resRt.rows[0].id;
    console.log('✔ RT seeded:', rtId);

    // 2. Hash Password
    const hash = await bcrypt.hash('rahasia123', 10);

    // 3. Create Users
    // RT User
    await pool.query(`
      INSERT INTO users (nama, no_wa, email, google_id, password_hash, role, rt_id, rw_id, is_verified) 
      VALUES ('Bapak RT Andi', '089999999999', 'azmttqi@gmail.com', 'google_id_rt_mock', $1, 'RT', $2, null, true) 
      ON CONFLICT (no_wa) DO UPDATE SET email=EXCLUDED.email, google_id=EXCLUDED.google_id
    `, [hash, rtId]);
    console.log('✔ RT User seeded: 089999999999 / azmttqi@gmail.com');

    // Warga User
    const resWarga = await pool.query(`
      INSERT INTO users (nama, no_wa, password_hash, role, rt_id, rw_id, is_verified) 
      VALUES ('Budi Warga', '081234567890', $1, 'WARGA', $2, null, true) 
      ON CONFLICT (no_wa) DO UPDATE SET nama=EXCLUDED.nama, role=EXCLUDED.role
      RETURNING id
    `, [hash, rtId]);
    const wargaId = resWarga.rows[0].id;
    console.log('✔ Warga User seeded: 081234567890');

    // RW User
    await pool.query(`
      INSERT INTO users (nama, no_wa, email, google_id, password_hash, role, rt_id, rw_id, is_verified) 
      VALUES ('Bapak RW Iwan', '087777777777', 'azmiittaqi03@gmail.com', 'google_id_rw_mock', $1, 'RW', $2, $3, true) 
      ON CONFLICT (no_wa) DO UPDATE SET email=EXCLUDED.email, google_id=EXCLUDED.google_id
    `, [hash, rtId, rwId]);
    console.log('✔ RW User seeded: 087777777777 / azmiittaqi03@gmail.com');

    // 4. Create Family record for Warga
    const resFamily = await pool.query(`
      INSERT INTO families (user_id, rt_id, no_kk, tipe_warga, status_tinggal, status_verifikasi)
      VALUES ($1, $2, '3201234567890001', 'LAMA', 'TETAP', 'APPROVED') 
      ON CONFLICT (no_kk) DO UPDATE SET user_id=EXCLUDED.user_id
      RETURNING id
    `, [wargaId, rtId]);
    const familyId = resFamily.rows[0].id;
    console.log('✔ Family record seeded for Warga');

    // 5. Create Dues (Bills & Payments)
    // Bill for Jan 2026 (Paid)
    const resBillJan = await pool.query(`
      INSERT INTO dues_bills (family_id, bulan, tahun, nominal, status)
      VALUES ($1, 1, 2026, 50000, 'APPROVED')
      ON CONFLICT (family_id, bulan, tahun) DO NOTHING
      RETURNING id
    `, [familyId]);
    
    if (resBillJan.rows.length > 0) {
      await pool.query(`
        INSERT INTO dues_payments (pembayar_family_id, bulan, tahun, nominal, metode_bayar, status, dibayar_pada)
        VALUES ($1, 1, 2026, 50000, 'CASH', 'APPROVED', '2026-01-05')
      `, [familyId]);
    }

    // Bill for Feb 2026 (Pending)
    await pool.query(`
      INSERT INTO dues_bills (family_id, bulan, tahun, nominal, status)
      VALUES ($1, 2, 2026, 50000, 'PENDING')
      ON CONFLICT (family_id, bulan, tahun) DO NOTHING
    `, [familyId]);
    console.log('✔ Dues history seeded');

    // 6. Create Announcements
    await pool.query(`
      INSERT INTO announcements (judul, konten, target, target_rt_id, is_kegiatan)
      VALUES 
      ('Gotong Royong Kebersihan', 'Kegiatan pembersihan lingkungan akan dilakukan pada hari Minggu pagi.', 'WARGA_RT', $1, true),
      ('Informasi Iuran Keamanan', 'Diberitahukan terkait kenaikan iuran keamanan sebesar Rp 5.000 mulai bulan depan.', 'WARGA_RT', $1, false)
    `, [rtId]);
    console.log('✔ Announcements seeded');

    console.log('--- Seed Process Completed ---');
    console.log('Accounts:');
    console.log('- Admin/RT: 089999999999 (rahasia123)');
    console.log('- Warga: 081234567890 (rahasia123)');
    console.log('- RW: 087777777777 (rahasia123)');
    
    pool.end();
  } catch (e) {
    console.error('❌ Seed failed:', e);
    pool.end();
  }
}

seed();
