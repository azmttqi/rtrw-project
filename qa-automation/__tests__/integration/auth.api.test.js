const request = require('supertest');

// ── Mocks ────────────────────────────────────────────────────────────────────
jest.mock('../../../backend/src/middleware/auth.middleware', () => ({
  authenticate: (req, _res, next) => {
    req.user = { id: 'user-1', role: 'RT', rt_id: 'rt-1', rw_id: 'rw-1', is_verified: true };
    next();
  },
}));

jest.mock('../../../backend/src/repositories/user.repository');
jest.mock('../../../backend/src/repositories/family.repository');
jest.mock('../../../backend/src/repositories/invitation.repository');

const userRepository       = require('../../../backend/src/repositories/user.repository');
const invitationRepository = require('../../../backend/src/repositories/invitation.repository');

jest.mock('bcryptjs', () => ({
  hash: jest.fn().mockResolvedValue('hashed_password'),
  compare: jest.fn().mockImplementation((plain, hashed) => Promise.resolve(plain === 'password')),
}));

const app = require('../../../backend/src/app');

const VALID_USER = {
  id: 'user-1', nama: 'Budi', no_wa: '08111', email: 'budi@test.com',
  password_hash: '$2a$10$Yj6f.8yq0oQ1U7zO3HBFBOeGKIoBHiP3s8VmL0WVLaS6lnEniukdm', // bcrypt("password")
  role: 'RT', rt_id: 'rt-1', rw_id: 'rw-1', is_verified: true, google_id: null,
};

describe('Auth API Integration Tests', () => {
  beforeEach(() => jest.clearAllMocks());

  // ── POST /api/auth/register ─────────────────────────────────────────────
  describe('POST /api/auth/register', () => {
    it('Success: mendaftarkan user baru (RT)', async () => {
      userRepository.findByNoWa.mockResolvedValue(null);
      userRepository.findByEmail.mockResolvedValue(null);
      userRepository.create.mockResolvedValue(VALID_USER);

      const res = await request(app).post('/api/auth/register').send({
        nama: 'Budi', no_wa: '08111', password: 'password', role: 'RT',
      });

      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);
    });

    it('Negative: field wajib tidak diisi', async () => {
      const res = await request(app).post('/api/auth/register').send({ nama: 'Budi' });
      expect(res.status).toBe(400);
      expect(res.body.success).toBe(false);
    });

    it('Negative: nomor WA sudah terdaftar', async () => {
      userRepository.findByNoWa.mockResolvedValue(VALID_USER);

      const res = await request(app).post('/api/auth/register').send({
        nama: 'Budi', no_wa: '08111', password: 'password',
      });
      expect(res.status).toBe(400);
      expect(res.body.message).toMatch(/already registered/);
    });

    it('Negative: token undangan tidak valid/expired', async () => {
      userRepository.findByNoWa.mockResolvedValue(null);
      userRepository.findByEmail.mockResolvedValue(null);
      invitationRepository.findByToken.mockResolvedValue(null); // null = not found

      const res = await request(app).post('/api/auth/register').send({
        nama: 'Budi', no_wa: '08111', password: 'password',
        token_invitation: 'invalid-token',
      });
      expect(res.status).toBe(400);
    });
  });

  // ── POST /api/auth/login ────────────────────────────────────────────────
  describe('POST /api/auth/login', () => {
    it('Success: login dengan kredensial yang benar', async () => {
      userRepository.findByIdentifier.mockResolvedValue(VALID_USER);

      const res = await request(app).post('/api/auth/login').send({
        no_wa: '08111', password: 'password',
      });
      expect(res.status).toBe(200);
      expect(res.body.data).toHaveProperty('token');
    });

    it('Negative: field wajib tidak diisi', async () => {
      const res = await request(app).post('/api/auth/login').send({ no_wa: '08111' });
      expect(res.status).toBe(400);
    });

    it('Negative: user tidak ditemukan', async () => {
      userRepository.findByIdentifier.mockResolvedValue(null);

      const res = await request(app).post('/api/auth/login').send({
        no_wa: '08999', password: 'wrong',
      });
      expect(res.status).toBe(400);
      expect(res.body.message).toMatch(/salah/);
    });

    it('Negative: password salah', async () => {
      userRepository.findByIdentifier.mockResolvedValue(VALID_USER);

      const res = await request(app).post('/api/auth/login').send({
        no_wa: '08111', password: 'wrongpassword',
      });
      expect(res.status).toBe(400);
    });
  });

  // ── GET /api/auth/me ────────────────────────────────────────────────────
  describe('GET /api/auth/me', () => {
    it('Success: mendapatkan profil user', async () => {
      userRepository.findById.mockResolvedValue(VALID_USER);

      const res = await request(app).get('/api/auth/me');
      expect(res.status).toBe(200);
      expect(res.body.data).toHaveProperty('nama');
    });
  });

  // ── PATCH /api/auth/me ──────────────────────────────────────────────────
  describe('PATCH /api/auth/me', () => {
    it('Success: update profil user', async () => {
      const updated = { ...VALID_USER, nama: 'Budi Santoso' };
      userRepository.update.mockResolvedValue(updated);

      const res = await request(app).patch('/api/auth/me').send({ nama: 'Budi Santoso' });
      expect(res.status).toBe(200);
      expect(res.body.data.nama).toBe('Budi Santoso');
    });
  });

  // ── POST /api/auth/verify-email ─────────────────────────────────────────
  describe('POST /api/auth/verify-email', () => {
    it('Success: verifikasi OTP berhasil', async () => {
      userRepository.findByIdentifier.mockResolvedValue(VALID_USER);
      userRepository.update.mockResolvedValue({ ...VALID_USER, is_verified: true });

      const res = await request(app).post('/api/auth/verify-email').send({
        identifier: '08111', otp: '123456',
      });
      expect(res.status).toBe(200);
    });

    it('Negative: OTP salah', async () => {
      const res = await request(app).post('/api/auth/verify-email').send({
        identifier: '08111', otp: '000000',
      });
      expect(res.status).toBe(400);
    });

    it('Negative: field tidak diisi', async () => {
      const res = await request(app).post('/api/auth/verify-email').send({ identifier: '08111' });
      expect(res.status).toBe(400);
    });
  });

  // ── POST /api/auth/register-google ─────────────────────────────────────
  describe('POST /api/auth/register-google', () => {
    it('Success: login Google dengan mock token', async () => {
      userRepository.findByGoogleId.mockResolvedValue(null);
      userRepository.findByEmail.mockResolvedValue(null);
      userRepository.create.mockResolvedValue(VALID_USER);

      const res = await request(app).post('/api/auth/register-google').send({ idToken: 'mock_rt' });
      expect(res.status).toBe(200);
      expect(res.body.data).toHaveProperty('token');
    });

    it('Negative: idToken tidak dikirim', async () => {
      const res = await request(app).post('/api/auth/register-google').send({});
      expect(res.status).toBe(400);
    });

    it('Success: user Google sudah ada, langsung login', async () => {
      userRepository.findByGoogleId.mockResolvedValue(VALID_USER);

      const res = await request(app).post('/api/auth/register-google').send({ idToken: 'mock_rt' });
      expect(res.status).toBe(200);
      expect(res.body.data).toHaveProperty('token');
    });
  });
});
