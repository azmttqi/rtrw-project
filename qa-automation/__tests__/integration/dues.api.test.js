const request = require('supertest');

jest.mock('../../../backend/src/middleware/auth.middleware', () => ({
  authenticate: (req, _res, next) => {
    req.user = { id: 'user-1', role: 'RT', rt_id: 'rt-1', rw_id: 'rw-1' };
    next();
  },
}));

jest.mock('../../../backend/src/services/due.service');
jest.mock('../../../backend/src/repositories/family.repository');

const dueService       = require('../../../backend/src/services/due.service');
const familyRepository = require('../../../backend/src/repositories/family.repository');

const app = require('../../../backend/src/app');

const MOCK_SETTING  = { id: 'set-1', tingkat: 'WARGA', nominal: 50000 };
const MOCK_BILL     = { id: 'bill-1', family_id: 'fam-1', bulan: 4, tahun: 2026, nominal: 50000 };
const MOCK_PAYMENT  = { id: 'pay-1', pembayar_family_id: 'fam-1', nominal: 50000, status: 'PENDING' };
const MOCK_BILLS    = { data: [MOCK_BILL],    total: 1 };
const MOCK_PAYMENTS = { data: [MOCK_PAYMENT], total: 1 };

describe('Dues API Integration Tests', () => {
  beforeEach(() => jest.clearAllMocks());

  // ── GET /api/dues/settings ──────────────────────────────────────────────
  describe('GET /api/dues/settings', () => {
    it('Success: mendapatkan setting iuran WARGA (via RT user)', async () => {
      dueService.getSettingsByRT.mockResolvedValue(MOCK_SETTING);

      const res = await request(app).get('/api/dues/settings').query({ tingkat: 'WARGA' });
      expect(res.status).toBe(200);
      expect(res.body.data.nominal).toBe(50000);
    });

    it('Success: mendapatkan setting iuran RT (via RW)', async () => {
      dueService.getSettingsByRW.mockResolvedValue(MOCK_SETTING);

      const res = await request(app).get('/api/dues/settings').query({ tingkat: 'RT' });
      expect(res.status).toBe(200);
    });

    it('Negative: tingkat tidak sesuai', async () => {
      const res = await request(app).get('/api/dues/settings').query({ tingkat: 'INVALID' });
      expect(res.status).toBe(400);
    });
  });

  // ── POST /api/dues/settings ─────────────────────────────────────────────
  describe('POST /api/dues/settings', () => {
    it('Success: membuat setting iuran baru', async () => {
      dueService.createSetting.mockResolvedValue(MOCK_SETTING);

      const res = await request(app).post('/api/dues/settings').send({
        tingkat: 'WARGA', nominal: 50000, tenggat_tanggal: 25,
      });
      expect(res.status).toBe(201);
    });

    it('Negative: error validasi dari service', async () => {
      dueService.createSetting.mockRejectedValue(new Error('Data tidak lengkap'));

      const res = await request(app).post('/api/dues/settings').send({});
      expect(res.status).toBe(400);
    });
  });

  // ── POST /api/dues/bills ────────────────────────────────────────────────
  describe('POST /api/dues/bills', () => {
    it('Success: membuat tagihan baru', async () => {
      dueService.createBill.mockResolvedValue(MOCK_BILL);

      const res = await request(app).post('/api/dues/bills').send({
        family_id: 'fam-1', bulan: 4, tahun: 2026, nominal: 50000,
      });
      expect(res.status).toBe(201);
    });

    it('Negative: tagihan sudah ada', async () => {
      dueService.createBill.mockRejectedValue(new Error('Tagihan sudah ada'));

      const res = await request(app).post('/api/dues/bills').send({
        family_id: 'fam-1', bulan: 4, tahun: 2026, nominal: 50000,
      });
      expect(res.status).toBe(400);
    });
  });

  // ── GET /api/dues/bills ─────────────────────────────────────────────────
  describe('GET /api/dues/bills', () => {
    it('Success: mendapatkan daftar tagihan per RT', async () => {
      dueService.getBillsByRT.mockResolvedValue(MOCK_BILLS);

      const res = await request(app).get('/api/dues/bills');
      expect(res.status).toBe(200);
      expect(res.body.data.bills).toHaveLength(1);
    });

    it('Negative: error dari service', async () => {
      dueService.getBillsByRT.mockRejectedValue(new Error('DB Error'));

      const res = await request(app).get('/api/dues/bills');
      expect(res.status).toBe(500);
    });
  });

  // ── POST /api/dues/pay ──────────────────────────────────────────────────
  describe('POST /api/dues/pay', () => {
    it('Success: submit pembayaran oleh kepala keluarga', async () => {
      familyRepository.findByUserId.mockResolvedValue({ id: 'fam-1' });
      dueService.createPayment.mockResolvedValue(MOCK_PAYMENT);

      const res = await request(app).post('/api/dues/pay').send({
        bulan: 4, tahun: 2026, nominal: 50000, metode_bayar: 'TRANSFER',
      });
      expect(res.status).toBe(201);
    });

    it('Success: submit pembayaran oleh RT (role RT, family null)', async () => {
      familyRepository.findByUserId.mockResolvedValue(null);
      dueService.createPayment.mockResolvedValue(MOCK_PAYMENT);

      const res = await request(app).post('/api/dues/pay').send({
        bulan: 4, tahun: 2026, nominal: 50000, metode_bayar: 'TRANSFER',
      });
      expect(res.status).toBe(201);
    });
  });

  // ── GET /api/dues/payments ──────────────────────────────────────────────
  describe('GET /api/dues/payments', () => {
    it('Success: mendapatkan daftar pembayaran per RT', async () => {
      dueService.getPaymentsByRT.mockResolvedValue(MOCK_PAYMENTS);

      const res = await request(app).get('/api/dues/payments');
      expect(res.status).toBe(200);
      expect(res.body.data.payments).toHaveLength(1);
    });
  });

  // ── PATCH /api/dues/payments/:id/verify ────────────────────────────────
  describe('PATCH /api/dues/payments/:id/verify', () => {
    it('Success: pembayaran disetujui (APPROVED)', async () => {
      dueService.verifyPayment.mockResolvedValue({ ...MOCK_PAYMENT, status: 'APPROVED' });

      const res = await request(app)
        .patch('/api/dues/payments/pay-1/verify')
        .send({ status: 'APPROVED' });

      expect(res.status).toBe(200);
      expect(res.body.message).toMatch(/setuju/);
    });

    it('Negative: status tidak valid', async () => {
      dueService.verifyPayment.mockRejectedValue(new Error('Status tidak valid'));

      const res = await request(app)
        .patch('/api/dues/payments/pay-1/verify')
        .send({ status: 'UNKNOWN' });

      expect(res.status).toBe(400);
    });

    it('Negative: pembayaran tidak ditemukan', async () => {
      dueService.verifyPayment.mockRejectedValue(new Error('Pembayaran tidak ditemukan'));

      const res = await request(app)
        .patch('/api/dues/payments/not-exist/verify')
        .send({ status: 'APPROVED' });

      expect(res.status).toBe(404);
    });
  });
});
