const userRepository = require('../../../backend/src/repositories/user.repository');
const pool = require('../../../backend/src/config/database');
const bcrypt = require('bcryptjs');

describe('User Repository', () => {
  let rtId, rwId;

  beforeEach(async () => {
    // Setup RT and RW data for foreign keys
    const rwRes = await pool.query(`INSERT INTO rws (nomor_rw, nama_wilayah, alamat) VALUES ('01', 'Test RW', 'Test Alamat') RETURNING id`);
    rwId = rwRes.rows[0].id;

    const rtRes = await pool.query(`INSERT INTO rts (rw_id, nomor_rt) VALUES ($1, '01') RETURNING id`, [rwId]);
    rtId = rtRes.rows[0].id;
  });

  describe('create', () => {
    it('Success: membuat user baru', async () => {
      const userData = {
        nama: 'Test User',
        no_wa: '08123456789',
        email: 'test@example.com',
        role: 'WARGA',
        rt_id: rtId,
        password_hash: await bcrypt.hash('password123', 10),
        is_verified: true
      };

      const user = await userRepository.create(userData);

      expect(user).toBeDefined();
      expect(user.nama).toBe('Test User');
      expect(user.no_wa).toBe('08123456789');
      expect(user.role).toBe('WARGA');
      expect(user.rt_id).toBe(rtId);
      expect(user.id).toBeDefined();
    });
  });

  describe('findByNoWa', () => {
    it('Success: menemukan user berdasarkan nomor WA', async () => {
      const userData = {
        nama: 'Test User 2',
        no_wa: '08987654321',
        role: 'RT',
        rt_id: rtId,
      };
      await userRepository.create(userData);

      const user = await userRepository.findByNoWa('08987654321');
      expect(user).toBeDefined();
      expect(user.nama).toBe('Test User 2');
    });

    it('Negative: mengembalikan undefined jika WA tidak ditemukan', async () => {
      const user = await userRepository.findByNoWa('00000000000');
      expect(user).toBeUndefined();
    });
  });
});
