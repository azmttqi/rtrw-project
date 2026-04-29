const letterRepository = require('../../../backend/src/repositories/letter.repository');
const familyRepository = require('../../../backend/src/repositories/family.repository');
const userRepository = require('../../../backend/src/repositories/user.repository');
const pool = require('../../../backend/src/config/database');

describe('Letter Repository', () => {
  let familyId, rtId, rwId, userId;

  beforeEach(async () => {
    // Setup RT and RW data
    const rwRes = await pool.query(`INSERT INTO rws (nomor_rw, nama_wilayah, alamat) VALUES ('01', 'Test RW', 'Test Alamat') RETURNING id`);
    rwId = rwRes.rows[0].id;

    const rtRes = await pool.query(`INSERT INTO rts (rw_id, nomor_rt) VALUES ($1, '01') RETURNING id`, [rwId]);
    rtId = rtRes.rows[0].id;

    // Setup User
    const user = await userRepository.create({
      nama: 'Letter Applicant',
      no_wa: '08123456785',
      role: 'WARGA',
      rt_id: rtId,
    });
    userId = user.id;

    // Setup Family
    const family = await familyRepository.create({
      user_id: userId,
      rt_id: rtId,
      no_kk: '2222333344445555',
      tipe_warga: 'LAMA',
      status_tinggal: 'TETAP',
      status_pernikahan: 'KAWIN'
    });
    familyId = family.id;
  });

  describe('createLetter', () => {
    it('Success: membuat pengajuan surat baru', async () => {
      const letter = await letterRepository.createLetter({
        family_id: familyId,
        jenis_surat: 'SURAT_PENGANTAR_DOMISILI',
        keterangan_keperluan: 'Pindah kerja'
      });

      expect(letter).toBeDefined();
      expect(letter.status).toBe('PENDING_RT');
      expect(letter.jenis_surat).toBe('SURAT_PENGANTAR_DOMISILI');
    });
  });

  describe('getLetterById', () => {
    it('Success: mengambil detail surat dengan join RT/RW', async () => {
      const letter = await letterRepository.createLetter({
        family_id: familyId,
        jenis_surat: 'SURAT_KETERANGAN_TIDAK_MAMPU',
        keterangan_keperluan: 'Beasiswa'
      });

      const found = await letterRepository.getLetterById(letter.id);
      expect(found).toBeDefined();
      expect(found.nomor_rt).toBe('01');
      expect(found.nomor_rw).toBe('01');
    });
  });

  describe('updateLetterStatus', () => {
    it('Success: menyetujui surat oleh RT', async () => {
      const letter = await letterRepository.createLetter({
        family_id: familyId,
        jenis_surat: 'SURAT_PENGANTAR_KK',
        keterangan_keperluan: 'Update KK'
      });

      const updated = await letterRepository.updateLetterStatus(letter.id, 'APPROVED_RT_PENDING_RW');
      expect(updated.status).toBe('APPROVED_RT_PENDING_RW');
    });
  });
});
