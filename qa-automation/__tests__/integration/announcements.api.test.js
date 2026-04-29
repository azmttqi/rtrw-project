const request = require('supertest');

jest.mock('../../../backend/src/middleware/auth.middleware', () => ({
  authenticate: (req, _res, next) => {
    req.user = { id: 'user-1', role: 'RT', rt_id: 'rt-1', rw_id: 'rw-1' };
    next();
  },
}));

jest.mock('../../../backend/src/services/announcement.service');
const announcementService = require('../../../backend/src/services/announcement.service');

const app = require('../../../backend/src/app');

const MOCK_ANN = { id: 'ann-1', judul: 'Kerja Bakti', konten: 'Acara kerja bakti', is_kegiatan: false };
const MOCK_LIST = { data: [MOCK_ANN], total: 1 };

describe('Announcements API Integration Tests', () => {
  beforeEach(() => jest.clearAllMocks());

  // ── POST /api/announcements ─────────────────────────────────────────────
  describe('POST /api/announcements', () => {
    it('Success: membuat pengumuman baru', async () => {
      announcementService.createAnnouncement.mockResolvedValue(MOCK_ANN);

      const res = await request(app).post('/api/announcements').send({
        judul: 'Kerja Bakti', konten: 'Acara kerja bakti', target: 'RT',
      });
      expect(res.status).toBe(201);
      expect(res.body.data.judul).toBe('Kerja Bakti');
    });

    it('Negative: error dari service', async () => {
      announcementService.createAnnouncement.mockRejectedValue(new Error('DB Error'));

      const res = await request(app).post('/api/announcements').send({
        judul: 'Test', konten: 'Test', target: 'RT',
      });
      expect(res.status).toBe(500);
    });
  });

  // ── GET /api/announcements ──────────────────────────────────────────────
  describe('GET /api/announcements', () => {
    it('Success: mendapatkan daftar pengumuman', async () => {
      announcementService.getAnnouncements.mockResolvedValue(MOCK_LIST);

      const res = await request(app).get('/api/announcements');
      expect(res.status).toBe(200);
      expect(res.body.data.announcements).toHaveLength(1);
      expect(res.body.data).toHaveProperty('pagination');
    });

    it('Negative: error dari service', async () => {
      announcementService.getAnnouncements.mockRejectedValue(new Error('DB Error'));

      const res = await request(app).get('/api/announcements');
      expect(res.status).toBe(500);
    });
  });

  // ── PATCH /api/announcements/:id ───────────────────────────────────────
  describe('PATCH /api/announcements/:id', () => {
    it('Success: mengupdate pengumuman', async () => {
      const updated = { ...MOCK_ANN, judul: 'Update Judul' };
      announcementService.updateAnnouncement.mockResolvedValue(updated);

      const res = await request(app)
        .patch('/api/announcements/ann-1')
        .send({ judul: 'Update Judul' });

      expect(res.status).toBe(200);
      expect(res.body.data.judul).toBe('Update Judul');
    });

    it('Negative: pengumuman tidak ditemukan', async () => {
      announcementService.updateAnnouncement.mockRejectedValue(new Error('Pengumuman tidak ditemukan'));

      const res = await request(app)
        .patch('/api/announcements/not-exist')
        .send({ judul: 'x' });

      expect(res.status).toBe(404);
    });
  });

  // ── DELETE /api/announcements/:id ──────────────────────────────────────
  describe('DELETE /api/announcements/:id', () => {
    it('Success: menghapus pengumuman', async () => {
      announcementService.deleteAnnouncement.mockResolvedValue(undefined);

      const res = await request(app).delete('/api/announcements/ann-1');
      expect(res.status).toBe(200);
    });

    it('Negative: pengumuman tidak ditemukan', async () => {
      announcementService.deleteAnnouncement.mockRejectedValue(new Error('Pengumuman tidak ditemukan'));

      const res = await request(app).delete('/api/announcements/not-exist');
      expect(res.status).toBe(404);
    });
  });
});
