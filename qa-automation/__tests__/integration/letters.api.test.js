const request = require('supertest');

jest.mock('../../../backend/src/middleware/auth.middleware', () => ({
  authenticate: (req, _res, next) => {
    req.user = {
      id: 'user-1', role: 'WARGA', rt_id: 'rt-1', rw_id: 'rw-1', is_verified: true,
    };
    next();
  },
}));

// letters.controller uses pool.query directly — mock pg pool
jest.mock('../../../backend/src/config/database', () => ({
  query: jest.fn(),
  connect: jest.fn(),
}));
jest.mock('../../../backend/src/services/letter.service');

const pool         = require('../../../backend/src/config/database');
const letterService = require('../../../backend/src/services/letter.service');

const app = require('../../../backend/src/app');

const MOCK_LETTER = {
  id: 'let-1', jenis_surat: 'DOMISILI', status: 'PENDING', family_id: 'fam-1',
};

describe('Letters API Integration Tests', () => {
  beforeEach(() => jest.clearAllMocks());

  // ── POST /api/letters ───────────────────────────────────────────────────
  describe('POST /api/letters', () => {
    it('Success: mengajukan surat baru', async () => {
      pool.query.mockResolvedValue({ rows: [{ id: 'fam-1', status_verifikasi: 'APPROVED' }] });
      letterService.createLetter.mockResolvedValue(MOCK_LETTER);

      const res = await request(app).post('/api/letters').send({
        jenis_surat: 'DOMISILI', keterangan_keperluan: 'Keperluan pindah',
      });
      expect(res.status).toBe(201);
      expect(res.body.data.jenis_surat).toBe('DOMISILI');
    });

    it('Negative: user belum punya KK', async () => {
      pool.query.mockResolvedValue({ rows: [] }); // no family

      const res = await request(app).post('/api/letters').send({ jenis_surat: 'DOMISILI' });
      expect(res.status).toBe(400);
      expect(res.body.message).toMatch(/KK/);
    });

    it('Negative: KK belum disetujui RT', async () => {
      pool.query.mockResolvedValue({ rows: [{ id: 'fam-1', status_verifikasi: 'PENDING' }] });

      const res = await request(app).post('/api/letters').send({ jenis_surat: 'DOMISILI' });
      expect(res.status).toBe(400);
      expect(res.body.message).toMatch(/belum disetujui/);
    });

    it('Negative: jenis surat wajib diisi', async () => {
      pool.query.mockResolvedValue({ rows: [{ id: 'fam-1', status_verifikasi: 'APPROVED' }] });
      letterService.createLetter.mockRejectedValue(new Error('jenis_surat wajib diisi'));

      const res = await request(app).post('/api/letters').send({});
      expect(res.status).toBe(400);
    });
  });

  // ── GET /api/letters ────────────────────────────────────────────────────
  describe('GET /api/letters', () => {
    it('Success: mendapatkan daftar surat', async () => {
      letterService.getLetters.mockResolvedValue([MOCK_LETTER]);

      const res = await request(app).get('/api/letters');
      expect(res.status).toBe(200);
      expect(res.body.data).toHaveLength(1);
    });

    it('Negative: error dari service', async () => {
      letterService.getLetters.mockRejectedValue(new Error('DB Error'));

      const res = await request(app).get('/api/letters');
      expect(res.status).toBe(500);
    });
  });

  // ── PATCH /api/letters/:id/verify ──────────────────────────────────────
  describe('PATCH /api/letters/:id/verify', () => {
    it('Success: verifikasi surat APPROVED', async () => {
      const approved = { ...MOCK_LETTER, status: 'APPROVED_RT' };
      letterService.verifyLetter.mockResolvedValue(approved);

      const res = await request(app)
        .patch('/api/letters/let-1/verify')
        .send({ status: 'APPROVED' });

      expect(res.status).toBe(200);
    });

    it('Negative: surat tidak ditemukan', async () => {
      letterService.verifyLetter.mockRejectedValue(new Error('Surat tidak ditemukan'));

      const res = await request(app)
        .patch('/api/letters/not-exist/verify')
        .send({ status: 'APPROVED' });

      expect(res.status).toBe(404);
    });

    it('Negative: tidak punya wewenang', async () => {
      letterService.verifyLetter.mockRejectedValue(new Error('Tidak punya wewenang'));

      const res = await request(app)
        .patch('/api/letters/let-1/verify')
        .send({ status: 'APPROVED' });

      expect(res.status).toBe(400);
    });
  });
});
