const request = require('supertest');

// Users route uses isRT() and isRW() — mock both auth + role middleware
jest.mock('../../../backend/src/middleware/auth.middleware', () => ({
  authenticate: (req, _res, next) => {
    req.user = { id: 'user-1', role: 'RW', rt_id: 'rt-1', rw_id: 'rw-1' };
    next();
  },
}));

jest.mock('../../../backend/src/repositories/user.repository');
const userRepository = require('../../../backend/src/repositories/user.repository');

const app = require('../../../backend/src/app');

const MOCK_RT   = { id: 'user-1', nama: 'Budi', role: 'RT', rt_id: 'rt-1', rw_id: 'rw-1' };
const MOCK_LIST = { data: [MOCK_RT], total: 1 };

describe('Users API Integration Tests', () => {
  beforeEach(() => jest.clearAllMocks());

  // ── GET /api/users ──────────────────────────────────────────────────────
  describe('GET /api/users', () => {
    it('Success: mendapatkan daftar user', async () => {
      userRepository.findAll.mockResolvedValue(MOCK_LIST);

      const res = await request(app).get('/api/users');
      expect(res.status).toBe(200);
      expect(res.body.data.users).toHaveLength(1);
    });

    it('Success: filter dengan query rt_id', async () => {
      userRepository.findAll.mockResolvedValue(MOCK_LIST);

      const res = await request(app).get('/api/users').query({ rt_id: 'rt-1' });
      expect(res.status).toBe(200);
      expect(userRepository.findAll).toHaveBeenCalledWith(
        expect.objectContaining({ rt_id: 'rt-1' })
      );
    });

    it('Negative: error database', async () => {
      userRepository.findAll.mockRejectedValue(new Error('DB Error'));

      const res = await request(app).get('/api/users');
      expect(res.status).toBe(500);
    });
  });

  // ── GET /api/users/:id ──────────────────────────────────────────────────
  describe('GET /api/users/:id', () => {
    it('Success: mendapatkan user berdasarkan ID', async () => {
      userRepository.findById.mockResolvedValue(MOCK_RT);

      const res = await request(app).get('/api/users/user-1');
      expect(res.status).toBe(200);
      expect(res.body.data.nama).toBe('Budi');
    });

    it('Negative: user tidak ditemukan', async () => {
      userRepository.findById.mockResolvedValue(null);

      const res = await request(app).get('/api/users/not-exist');
      expect(res.status).toBe(404);
    });
  });

  // ── PATCH /api/users/:id/verify-rt ─────────────────────────────────────
  describe('PATCH /api/users/:id/verify-rt', () => {
    it('Success: RT berhasil diverifikasi (APPROVED)', async () => {
      userRepository.findById.mockResolvedValue(MOCK_RT);
      userRepository.update.mockResolvedValue({ ...MOCK_RT, is_verified: true });

      const res = await request(app)
        .patch('/api/users/user-1/verify-rt')
        .send({ status: 'APPROVED', rt_id: 'rt-1' });

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
    });

    it('Success: RT verifikasi ditolak (REJECTED)', async () => {
      userRepository.findById.mockResolvedValue(MOCK_RT);

      const res = await request(app)
        .patch('/api/users/user-1/verify-rt')
        .send({ status: 'REJECTED' });

      expect(res.status).toBe(200);
      expect(res.body.message).toMatch(/ditolak/);
    });

    it('Negative: user bukan RT', async () => {
      userRepository.findById.mockResolvedValue({ ...MOCK_RT, role: 'WARGA' });

      const res = await request(app)
        .patch('/api/users/user-1/verify-rt')
        .send({ status: 'APPROVED' });

      expect(res.status).toBe(400);
    });

    it('Negative: user tidak ditemukan', async () => {
      userRepository.findById.mockResolvedValue(null);

      const res = await request(app)
        .patch('/api/users/not-exist/verify-rt')
        .send({ status: 'APPROVED' });

      expect(res.status).toBe(400);
    });
  });
});
