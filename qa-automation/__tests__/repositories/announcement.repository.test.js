const announcementRepository = require('../../../backend/src/repositories/announcement.repository');
const userRepository = require('../../../backend/src/repositories/user.repository');
const pool = require('../../../backend/src/config/database');

describe('Announcement Repository', () => {
  let rtId, rwId, userId;

  beforeEach(async () => {
    // Setup RT and RW data
    const rwRes = await pool.query(`INSERT INTO rws (nomor_rw, nama_wilayah, alamat) VALUES ('01', 'Test RW', 'Test Alamat') RETURNING id`);
    rwId = rwRes.rows[0].id;

    const rtRes = await pool.query(`INSERT INTO rts (rw_id, nomor_rt) VALUES ($1, '01') RETURNING id`, [rwId]);
    rtId = rtRes.rows[0].id;

    // Setup User (Pembuat Pengumuman)
    const user = await userRepository.create({
      nama: 'Bapak RT',
      no_wa: '08123456782',
      role: 'RT',
      rt_id: rtId,
      rw_id: rwId,
    });
    userId = user.id;
  });

  describe('createAnnouncement', () => {
    it('Success: membuat pengumuman baru', async () => {
      const data = {
        pembuat_user_id: userId,
        target: 'WARGA_RT',
        target_rt_id: rtId,
        judul: 'Kerja Bakti',
        konten: 'Ayo kerja bakti besok pagi.',
        is_kegiatan: true,
        tanggal_kegiatan: '2026-05-01'
      };

      const announcement = await announcementRepository.createAnnouncement(data);

      expect(announcement).toBeDefined();
      expect(announcement.judul).toBe('Kerja Bakti');
      expect(announcement.target_rt_id).toBe(rtId);
    });
  });

  describe('getAnnouncements', () => {
    it('Success: mengambil pengumuman berdasarkan RT', async () => {
      await announcementRepository.createAnnouncement({
        pembuat_user_id: userId,
        target: 'WARGA_RT',
        target_rt_id: rtId,
        judul: 'Info Iuran',
        konten: 'Iuran bulan ini Rp 50.000'
      });

      const result = await announcementRepository.getAnnouncements({ rt_id: rtId, rw_id: rwId }, 1, 10);
      expect(result.data).toHaveLength(1);
      expect(result.data[0].judul).toBe('Info Iuran');
      expect(result.total).toBe(1);
    });
  });

  describe('deleteAnnouncement', () => {
    it('Success: menghapus pengumuman', async () => {
      const announcement = await announcementRepository.createAnnouncement({
        pembuat_user_id: userId,
        target: 'SEMUA_RT',
        judul: 'Hapus Saya',
        konten: 'Test'
      });

      const deleted = await announcementRepository.deleteAnnouncement(announcement.id);
      expect(deleted.judul).toBe('Hapus Saya');

      const found = await announcementRepository.getAnnouncementById(announcement.id);
      expect(found).toBeUndefined();
    });
  });
});
