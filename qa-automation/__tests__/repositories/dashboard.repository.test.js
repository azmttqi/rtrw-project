const dashboardRepository = require('../../../backend/src/repositories/dashboard.repository');
const pool = require('../../../backend/src/config/database');

describe('Dashboard Repository', () => {
  let rwId, rtId, userId, familyId;

  beforeEach(async () => {
    const rwRes = await pool.query(`INSERT INTO rws (nomor_rw, nama_wilayah, alamat) VALUES ('01', 'RW 01', 'Alamat RW') RETURNING id`);
    rwId = rwRes.rows[0].id;

    const rtRes = await pool.query(`INSERT INTO rts (rw_id, nomor_rt) VALUES ($1, '01') RETURNING id`, [rwId]);
    rtId = rtRes.rows[0].id;

    const userRes = await pool.query(`
      INSERT INTO users (nama, no_wa, password_hash, role, rw_id, rt_id, is_verified) 
      VALUES ('Test User', '081234567890', 'hash', 'WARGA', $1, $2, true) 
      RETURNING id
    `, [rwId, rtId]);
    userId = userRes.rows[0].id;

    const familyRes = await pool.query(`
      INSERT INTO families (user_id, rt_id, no_kk, tipe_warga, status_tinggal, status_verifikasi) 
      VALUES ($1, $2, '1234567890123456', 'LAMA', 'TETAP', 'APPROVED') 
      RETURNING id
    `, [userId, rtId]);
    familyId = familyRes.rows[0].id;

    await pool.query(`
      INSERT INTO residents (family_id, nik, nama_lengkap, tanggal_lahir, jenis_kelamin, hubungan_keluarga) 
      VALUES ($1, '1234567890123456', 'Test Resident', '1990-01-01', 'LAKI_LAKI', 'KEPALA KELUARGA')
    `, [familyId]);
  });

  describe('getRWStats', () => {
    it('should return RW statistics', async () => {
      const stats = await dashboardRepository.getRWStats(rwId);
      expect(stats).toBeDefined();
      expect(stats.totalRT).toBe(0); 
      expect(stats.totalWarga).toBe(1); 
      expect(stats.ageDistribution).toBeDefined();
    });
  });

  describe('getRTStats', () => {
    it('should return RT statistics', async () => {
      const stats = await dashboardRepository.getRTStats(rtId);
      expect(stats).toBeDefined();
      expect(stats.totalWarga).toBe(1);
    });
  });

  describe('getWargaStats', () => {
    it('should return Warga statistics', async () => {
      const stats = await dashboardRepository.getWargaStats(userId, rtId);
      expect(stats).toBeDefined();
      expect(stats.totalWarga).toBe(1);
    });
  });
});
