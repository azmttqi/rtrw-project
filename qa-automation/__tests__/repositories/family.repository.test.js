const familyRepository = require('../../../backend/src/repositories/family.repository');
const userRepository = require('../../../backend/src/repositories/user.repository');
const pool = require('../../../backend/src/config/database');

describe('Family Repository', () => {
  let rtId, rwId, userId;

  beforeEach(async () => {
    // Setup RT and RW data
    const rwRes = await pool.query(`INSERT INTO rws (nomor_rw, nama_wilayah, alamat) VALUES ('01', 'Test RW', 'Test Alamat') RETURNING id`);
    rwId = rwRes.rows[0].id;

    const rtRes = await pool.query(`INSERT INTO rts (rw_id, nomor_rt) VALUES ($1, '01') RETURNING id`, [rwId]);
    rtId = rtRes.rows[0].id;

    // Setup User
    const user = await userRepository.create({
      nama: 'Family Owner',
      no_wa: '08123456780',
      role: 'WARGA',
      rt_id: rtId,
    });
    userId = user.id;
  });

  describe('create', () => {
    it('Success: membuat keluarga baru', async () => {
      const familyData = {
        user_id: userId,
        rt_id: rtId,
        no_kk: '1234567890123456',
        tipe_warga: 'LAMA',
        status_tinggal: 'TETAP',
        status_pernikahan: 'KAWIN',
        documents: [
          { jenis_dokumen: 'KK', file_url: 'http://example.com/kk.jpg' }
        ]
      };

      const family = await familyRepository.create(familyData);

      expect(family).toBeDefined();
      expect(family.no_kk).toBe('1234567890123456');
      expect(family.status_verifikasi).toBe('PENDING');
    });
  });

  describe('findById', () => {
    it('Success: menemukan keluarga berdasarkan ID', async () => {
      const family = await familyRepository.create({
        user_id: userId,
        rt_id: rtId,
        no_kk: '1122334455667788',
        tipe_warga: 'LAMA',
        status_tinggal: 'SEWA',
        status_pernikahan: 'BELUM_KAWIN'
      });

      const found = await familyRepository.findById(family.id);
      expect(found).toBeDefined();
      expect(found.no_kk).toBe('1122334455667788');
      expect(found.nama).toBe('Family Owner'); // Check join with users
    });
  });

  describe('update', () => {
    it('Success: update status verifikasi', async () => {
      const family = await familyRepository.create({
        user_id: userId,
        rt_id: rtId,
        no_kk: '9988776655443322',
        tipe_warga: 'LAMA',
        status_tinggal: 'SEWA',
        status_pernikahan: 'BELUM_KAWIN'
      });

      const updated = await familyRepository.update(family.id, { status_verifikasi: 'APPROVED' });
      expect(updated.status_verifikasi).toBe('APPROVED');
    });
  });
});
