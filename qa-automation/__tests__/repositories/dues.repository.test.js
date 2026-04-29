const duesRepository = require('../../../backend/src/repositories/dues.repository');
const familyRepository = require('../../../backend/src/repositories/family.repository');
const userRepository = require('../../../backend/src/repositories/user.repository');
const pool = require('../../../backend/src/config/database');

describe('Dues Repository', () => {
  let familyId, rtId, rwId, userId;

  beforeEach(async () => {
    // Setup RT and RW data
    const rwRes = await pool.query(`INSERT INTO rws (nomor_rw, nama_wilayah, alamat) VALUES ('01', 'Test RW', 'Test Alamat') RETURNING id`);
    rwId = rwRes.rows[0].id;

    const rtRes = await pool.query(`INSERT INTO rts (rw_id, nomor_rt) VALUES ($1, '01') RETURNING id`, [rwId]);
    rtId = rtRes.rows[0].id;

    // Setup User
    const user = await userRepository.create({
      nama: 'Payer',
      no_wa: '08123456789',
      role: 'WARGA',
      rt_id: rtId,
    });
    userId = user.id;

    // Setup Family
    const family = await familyRepository.create({
      user_id: userId,
      rt_id: rtId,
      no_kk: '3333444455556666',
      tipe_warga: 'LAMA',
      status_tinggal: 'TETAP',
      status_pernikahan: 'KAWIN'
    });
    familyId = family.id;
  });

  describe('createSetting', () => {
    it('Success: membuat pengaturan iuran baru', async () => {
      const setting = await duesRepository.createSetting({
        tingkat: 'WARGA',
        rt_id: rtId,
        nominal: 50000,
        tenggat_tanggal: 10
      });

      expect(setting).toBeDefined();
      expect(setting.nominal).toBe('50000.00'); // pg decimal returns string
      expect(setting.tingkat).toBe('WARGA');
    });
  });

  describe('createBill', () => {
    it('Success: membuat tagihan baru', async () => {
      const bill = await duesRepository.createBill({
        family_id: familyId,
        bulan: 5,
        tahun: 2026,
        nominal: 50000
      });

      expect(bill).toBeDefined();
      expect(bill.status).toBe('PENDING');
      expect(bill.bulan).toBe(5);
    });
  });

  describe('createPayment', () => {
    it('Success: membuat pembayaran baru', async () => {
      const payment = await duesRepository.createPayment({
        pembayar_family_id: familyId,
        bulan: 5,
        tahun: 2026,
        nominal: 50000,
        metode_bayar: 'TRANSFER',
        bukti_bayar_url: 'http://example.com/bukti.jpg'
      });

      expect(payment).toBeDefined();
      expect(payment.status).toBe('PENDING');
      expect(payment.metode_bayar).toBe('TRANSFER');
    });
  });
});
