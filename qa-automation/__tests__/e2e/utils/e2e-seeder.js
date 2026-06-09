const pool = require('../../../../backend/src/config/database');
const bcrypt = require('../../../../backend/node_modules/bcryptjs');

async function seedBaseData() {
  const rwId = 9991;
  const rtId = 9991;
  const familyId = 9991;
  const rtUserId = 9991;
  const residentUserId = 9992;

  // 1. Seed RW
  await pool.query(
    'INSERT INTO rws (id, nomor_rw, alamat) VALUES ($1, $2, $3)',
    [rwId, '99', 'Alamat RW 01']
  );

  // 2. Seed RT
  await pool.query(
    'INSERT INTO rts (id, rw_id, nomor_rt) VALUES ($1, $2, $3)',
    [rtId, rwId, '99']
  );

  // 3. Seed Users (RT and Warga) FIRST
  const hashedRTPassword = await bcrypt.hash('password123', 10);
  await pool.query(
    `INSERT INTO users (id, nama, no_wa, password_hash, role, is_verified, rt_id, rw_id) 
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
    [rtUserId, 'Bapak RT E2E', '081200000001', hashedRTPassword, 'RT', true, rtId, rwId]
  );

  const hashedResPassword = await bcrypt.hash('password123', 10);
  await pool.query(
    `INSERT INTO users (id, nama, no_wa, password_hash, role, is_verified, rt_id, rw_id) 
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
    [residentUserId, 'Warga E2E', '081200000002', hashedResPassword, 'WARGA', true, rtId, rwId]
  );

  // 4. Seed Family (KK) linking to Warga user_id
  await pool.query(
    `INSERT INTO families (id, user_id, rt_id, no_kk, tipe_warga, status_tinggal, status_pernikahan, status_verifikasi) 
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
    [familyId, residentUserId, rtId, '1234567890123456', 'LAMA', 'TETAP', 'KAWIN', 'APPROVED']
  );

  // Users table doesn't have family_id, it uses families.user_id instead.

  return { rwId, rtId, familyId, rtUserId, residentUserId };
}

module.exports = { seedBaseData };
