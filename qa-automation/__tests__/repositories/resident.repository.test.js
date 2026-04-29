const residentRepository = require('../../../backend/src/repositories/resident.repository');
const familyRepository = require('../../../backend/src/repositories/family.repository');
const userRepository = require('../../../backend/src/repositories/user.repository');
const pool = require('../../../backend/src/config/database');

describe('Resident Repository', () => {
  let familyId, rtId, rwId, userId;

  beforeEach(async () => {
    // Setup RT and RW data
    const rwRes = await pool.query(`INSERT INTO rws (nomor_rw, nama_wilayah, alamat) VALUES ('01', 'Test RW', 'Test Alamat') RETURNING id`);
    rwId = rwRes.rows[0].id;

    const rtRes = await pool.query(`INSERT INTO rts (rw_id, nomor_rt) VALUES ($1, '01') RETURNING id`, [rwId]);
    rtId = rtRes.rows[0].id;

    // Setup User
    const user = await userRepository.create({
      nama: 'Resident Owner',
      no_wa: '08123456781',
      role: 'WARGA',
      rt_id: rtId,
    });
    userId = user.id;

    // Setup Family
    const family = await familyRepository.create({
      user_id: userId,
      rt_id: rtId,
      no_kk: '1111222233334444',
      tipe_warga: 'LAMA',
      status_tinggal: 'TETAP',
      status_pernikahan: 'KAWIN'
    });
    familyId = family.id;
  });

  describe('create', () => {
    it('Success: membuat penduduk baru', async () => {
      const residentData = {
        family_id: familyId,
        nik: '3201234567890001',
        nama_lengkap: 'Budi Santoso',
        jenis_kelamin: 'LAKI_LAKI',
        tanggal_lahir: '1990-01-01',
        hubungan_keluarga: 'KEPALA KELUARGA'
      };

      const resident = await residentRepository.create(residentData);

      expect(resident).toBeDefined();
      expect(resident.nama_lengkap).toBe('Budi Santoso');
      expect(resident.nik).toBe('3201234567890001');
    });
  });

  describe('findByFamilyId', () => {
    it('Success: menemukan semua penduduk dalam satu keluarga', async () => {
      await residentRepository.create({
        family_id: familyId,
        nik: '3201234567890001',
        nama_lengkap: 'Budi Santoso',
        jenis_kelamin: 'LAKI_LAKI',
        tanggal_lahir: '1990-01-01',
        hubungan_keluarga: 'KEPALA KELUARGA'
      });
      await residentRepository.create({
        family_id: familyId,
        nik: '3201234567890002',
        nama_lengkap: 'Siti Aminah',
        jenis_kelamin: 'PEREMPUAN',
        tanggal_lahir: '1992-05-10',
        hubungan_keluarga: 'ISTRI'
      });

      const residents = await residentRepository.findByFamilyId(familyId);
      expect(residents).toHaveLength(2);
      expect(residents[0].nik).toBe('3201234567890002');
      expect(residents[1].nik).toBe('3201234567890001');
    });
  });

  describe('delete', () => {
    it('Success: menghapus penduduk', async () => {
      const resident = await residentRepository.create({
        family_id: familyId,
        nik: '3201234567890003',
        nama_lengkap: 'Hapus Saya',
        jenis_kelamin: 'LAKI_LAKI',
        tanggal_lahir: '2000-01-01',
        hubungan_keluarga: 'ANAK'
      });

      const deleted = await residentRepository.delete(resident.id);
      expect(deleted.nik).toBe('3201234567890003');

      const found = await residentRepository.findById(resident.id);
      expect(found).toBeUndefined();
    });
  });
});
