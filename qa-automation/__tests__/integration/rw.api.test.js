const request = require('supertest');

jest.mock('../../../backend/src/middleware/auth.middleware', () => ({
  authenticate: (req, _res, next) => {
    req.user = { id: 'user-1', role: 'RW', rt_id: null, rw_id: 'rw-1' };
    next();
  },
}));

// rw.controller.js uses pool directly
jest.mock('../../../backend/src/config/database', () => {
  const mockClient = {
    query: jest.fn(),
    release: jest.fn(),
  };
  return {
    query: jest.fn(),
    connect: jest.fn().mockResolvedValue(mockClient),
    _mockClient: mockClient,
  };
});

const pool = require('../../../backend/src/config/database');
const app  = require('../../../backend/src/app');

describe('RW API Integration Tests', () => {
  beforeEach(() => jest.clearAllMocks());

  // ── POST /api/rw/setup ──────────────────────────────────────────────────
  describe('POST /api/rw/setup', () => {
    it('Success: setup environment RW berhasil', async () => {
      const client = pool._mockClient;
      client.query
        .mockResolvedValueOnce({})                              // BEGIN
        .mockResolvedValueOnce({ rows: [{ id: 'rw-1' }] })     // INSERT rws
        .mockResolvedValueOnce({})                              // UPDATE users
        .mockResolvedValueOnce({ rows: [{ id: 'rt-1', nomor_rt: '001' }] }) // INSERT rts
        .mockResolvedValueOnce({});                             // COMMIT

      const res = await request(app).post('/api/rw/setup').send({
        nomor_rw: '005', rts: ['001'],
      });

      expect(res.status).toBe(201);
      expect(res.body.data).toHaveProperty('nomor_rw');
    });

    it('Negative: field wajib tidak diisi', async () => {
      const res = await request(app).post('/api/rw/setup').send({ nomor_rw: '005' });
      expect(res.status).toBe(400);
    });

    it('Negative: rts bukan array', async () => {
      const res = await request(app).post('/api/rw/setup').send({
        nomor_rw: '005', rts: 'bukan-array',
      });
      expect(res.status).toBe(400);
    });

    it('Negative: error database (rollback)', async () => {
      const client = pool._mockClient;
      client.query
        .mockResolvedValueOnce({})                          // BEGIN
        .mockRejectedValueOnce(new Error('DB Constraint')); // INSERT rws gagal

      const res = await request(app).post('/api/rw/setup').send({
        nomor_rw: '005', rts: ['001'],
      });

      expect(res.status).toBe(500);
      expect(client.query).toHaveBeenCalledWith('ROLLBACK');
    });
  });
});
