const notificationRepository = require('../../../backend/src/repositories/notification.repository');
const userRepository = require('../../../backend/src/repositories/user.repository');
const pool = require('../../../backend/src/config/database');

describe('Notification Repository', () => {
  let rtId, rwId, userId;

  beforeEach(async () => {
    // Setup RT and RW data
    const rwRes = await pool.query(`INSERT INTO rws (nomor_rw, nama_wilayah, alamat) VALUES ('01', 'Test RW', 'Test Alamat') RETURNING id`);
    rwId = rwRes.rows[0].id;

    const rtRes = await pool.query(`INSERT INTO rts (rw_id, nomor_rt) VALUES ($1, '01') RETURNING id`, [rwId]);
    rtId = rtRes.rows[0].id;

    // Setup User
    const user = await userRepository.create({
      nama: 'Notify Me',
      no_wa: '08123456784',
      role: 'WARGA',
      rt_id: rtId,
    });
    userId = user.id;
  });

  describe('create', () => {
    it('Success: membuat notifikasi baru', async () => {
      const notif = await notificationRepository.create({
        user_id: userId,
        title: 'Halo',
        message: 'Ini pesan test'
      });

      expect(notif).toBeDefined();
      expect(notif.title).toBe('Halo');
      expect(notif.is_read).toBe(false);
    });
  });

  describe('markAsRead', () => {
    it('Success: mengubah status notifikasi menjadi terbaca', async () => {
      const notif = await notificationRepository.create({
        user_id: userId,
        title: 'Pesan 1',
        message: 'Test'
      });

      const updated = await notificationRepository.markAsRead(notif.id);
      expect(updated.is_read).toBe(true);
    });
  });

  describe('findByUserId', () => {
    it('Success: mengambil notifikasi milik user', async () => {
      await notificationRepository.create({ user_id: userId, title: 'Notif 1', message: 'M' });
      await notificationRepository.create({ user_id: userId, title: 'Notif 2', message: 'M' });

      const list = await notificationRepository.findByUserId(userId);
      expect(list).toHaveLength(2);
      expect(list[0].title).toBe('Notif 2'); // DESC order
    });
  });
});
