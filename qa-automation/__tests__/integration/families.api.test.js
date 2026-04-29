const request = require('supertest');

jest.mock('../../../backend/src/middleware/auth.middleware', () => ({
  authenticate: (req, _res, next) => {
    // RT role passes isRT() middleware
    req.user = { id: 'user-1', role: 'RT', rt_id: 'rt-1', rw_id: 'rw-1' };
    next();
  },
}));

jest.mock('../../../backend/src/services/family.service');
const familyService = require('../../../backend/src/services/family.service');

const app = require('../../../backend/src/app');

const MOCK_FAMILY = {
  id: 'fam-1', no_kk: '3201011234560001',
  tipe_warga: 'TETAP', status_tinggal: 'MILIK_SENDIRI',
  status_pernikahan: 'MENIKAH', status_verifikasi: 'PENDING',
};
const MOCK_LIST = { data: [MOCK_FAMILY], total: 1 };

describe('Families API Integration Tests', () => {
  beforeEach(() => jest.clearAllMocks());

  // ── GET /api/families/me ────────────────────────────────────────────────
  describe('GET /api/families/me', () => {
    it('Success: mendapatkan data keluarga sendiri', async () => {
      familyService.getMyFamily.mockResolvedValue(MOCK_FAMILY);

      const res = await request(app).get('/api/families/me');
      expect(res.status).toBe(200);
      expect(res.body.data.no_kk).toBe('3201011234560001');
    });

    it('Negative: keluarga tidak ditemukan', async () => {
      familyService.getMyFamily.mockRejectedValue(new Error('Keluarga tidak ditemukan'));

      const res = await request(app).get('/api/families/me');
      expect(res.status).toBe(404);
    });
  });

  // ── POST /api/families ──────────────────────────────────────────────────
  describe('POST /api/families', () => {
    it('Success: mendaftarkan keluarga baru', async () => {
      familyService.createFamily.mockResolvedValue(MOCK_FAMILY);

      const res = await request(app).post('/api/families').send({
        rt_id: 'rt-1', no_kk: '3201011234560001',
        tipe_warga: 'TETAP', status_tinggal: 'MILIK_SENDIRI',
        status_pernikahan: 'MENIKAH',
      });
      expect(res.status).toBe(201);
    });

    it('Negative: data tidak lengkap', async () => {
      familyService.createFamily.mockRejectedValue(new Error('Data keluarga tidak lengkap'));

      const res = await request(app).post('/api/families').send({});
      expect(res.status).toBe(400);
    });

    it('Negative: nomor KK sudah terdaftar', async () => {
      familyService.createFamily.mockRejectedValue(new Error('Nomor KK sudah terdaftar'));

      const res = await request(app).post('/api/families').send({ no_kk: '3201011234560001' });
      expect(res.status).toBe(400);
    });
  });

  // ── GET /api/families ───────────────────────────────────────────────────
  describe('GET /api/families', () => {
    it('Success: mendapatkan daftar keluarga per RT', async () => {
      familyService.getFamiliesByRT.mockResolvedValue(MOCK_LIST);

      const res = await request(app).get('/api/families');
      expect(res.status).toBe(200);
      expect(res.body.data.families).toHaveLength(1);
      expect(res.body.data).toHaveProperty('pagination');
    });

    it('Negative: error dari service', async () => {
      familyService.getFamiliesByRT.mockRejectedValue(new Error('DB Error'));

      const res = await request(app).get('/api/families');
      expect(res.status).toBe(500);
    });
  });

  // ── PATCH /api/families/:id/verify ─────────────────────────────────────
  describe('PATCH /api/families/:id/verify', () => {
    it('Success: verifikasi keluarga APPROVED', async () => {
      const approved = { ...MOCK_FAMILY, status_verifikasi: 'APPROVED' };
      familyService.verifyFamily.mockResolvedValue(approved);

      const res = await request(app)
        .patch('/api/families/fam-1/verify')
        .send({ status: 'APPROVED' });

      expect(res.status).toBe(200);
      expect(res.body.message).toMatch(/setuju/);
    });

    it('Success: verifikasi keluarga REJECTED', async () => {
      const rejected = { ...MOCK_FAMILY, status_verifikasi: 'REJECTED' };
      familyService.verifyFamily.mockResolvedValue(rejected);

      const res = await request(app)
        .patch('/api/families/fam-1/verify')
        .send({ status: 'REJECTED' });

      expect(res.status).toBe(200);
    });

    it('Negative: status tidak valid', async () => {
      familyService.verifyFamily.mockRejectedValue(new Error('Status tidak valid'));

      const res = await request(app)
        .patch('/api/families/fam-1/verify')
        .send({ status: 'UNKNOWN' });

      expect(res.status).toBe(400);
    });

    it('Negative: keluarga tidak ditemukan', async () => {
      familyService.verifyFamily.mockRejectedValue(new Error('Keluarga tidak ditemukan'));

      const res = await request(app)
        .patch('/api/families/not-exist/verify')
        .send({ status: 'APPROVED' });

      expect(res.status).toBe(404);
    });
  });
});
