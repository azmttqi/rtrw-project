const financeRepository = require('../../../backend/src/repositories/finance.repository');
const pool = require('../../../backend/src/config/database');

describe('Finance Repository', () => {
  let rwId, rtId, userId, familyId;

  beforeEach(async () => {
    const rwRes = await pool.query(`INSERT INTO rws (nomor_rw, nama_wilayah, alamat) VALUES ('01', 'RW 01', 'Alamat RW') RETURNING id`);
    rwId = rwRes.rows[0].id;

    const rtRes = await pool.query(`INSERT INTO rts (rw_id, nomor_rt) VALUES ($1, '01') RETURNING id`, [rwId]);
    rtId = rtRes.rows[0].id;

    const userRes = await pool.query(`
      INSERT INTO users (nama, no_wa, password_hash, role, rw_id, rt_id, is_verified) 
      VALUES ('Test Warga', '081234567891', 'hash', 'WARGA', $1, $2, true) 
      RETURNING id
    `, [rwId, rtId]);
    userId = userRes.rows[0].id;

    const familyRes = await pool.query(`
      INSERT INTO families (user_id, rt_id, no_kk, tipe_warga, status_tinggal, status_verifikasi) 
      VALUES ($1, $2, '1234567890123456', 'LAMA', 'TETAP', 'APPROVED') 
      RETURNING id
    `, [userId, rtId]);
    familyId = familyRes.rows[0].id;
    
    const now = new Date();
    const bulan = now.getMonth() + 1;
    const tahun = now.getFullYear();

    // Insert payment
    await pool.query(`
      INSERT INTO dues_payments (pembayar_family_id, nominal, status, bulan, tahun, metode_bayar)
      VALUES ($1, 50000, 'APPROVED', $2, $3, 'CASH')
    `, [familyId, bulan, tahun]);
  });

  describe('getFinanceSummaryForRW', () => {
    it('should return RW finance summary', async () => {
      const stats = await financeRepository.getFinanceSummaryForRW(rwId);
      expect(stats).toBeDefined();
      expect(stats.total_kas).toBe(0); // RT hasn't paid RW
    });
  });

  describe('getFinanceSummaryForRT', () => {
    it('should return RT finance summary', async () => {
      const stats = await financeRepository.getFinanceSummaryForRT(rtId);
      expect(stats).toBeDefined();
      expect(stats.total_kas).toBe(50000); // Warga paid 50k
    });
  });

  describe('getFinanceSummaryForWarga', () => {
    it('should return Warga finance summary', async () => {
      const stats = await financeRepository.getFinanceSummaryForWarga(userId);
      expect(stats).toBeDefined();
      expect(stats.total_kas).toBe(50000);
    });
  });
});
