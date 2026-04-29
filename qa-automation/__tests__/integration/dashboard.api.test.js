const request = require('supertest');

jest.mock('../../../backend/src/middleware/auth.middleware', () => ({
  authenticate: (req, _res, next) => {
    req.user = { id: 'user-1', role: 'RT', rt_id: 'rt-1', rw_id: 'rw-1' };
    next();
  },
}));

jest.mock('../../../backend/src/services/dashboard.service');
jest.mock('../../../backend/src/repositories/finance.repository');

const dashboardService    = require('../../../backend/src/services/dashboard.service');
const financeRepository   = require('../../../backend/src/repositories/finance.repository');

const app = require('../../../backend/src/app');

const MOCK_STATS   = { total_warga: 120, total_keluarga: 40, iuran_terkumpul: 2000000 };
const MOCK_FINANCE = { pemasukan: 3000000, pengeluaran: 500000, saldo: 2500000 };

describe('Dashboard API Integration Tests', () => {
  beforeEach(() => jest.clearAllMocks());

  // ── GET /api/dashboard/stats ────────────────────────────────────────────
  describe('GET /api/dashboard/stats', () => {
    it('Success: mendapatkan statistik dashboard', async () => {
      dashboardService.getStats.mockResolvedValue(MOCK_STATS);

      const res = await request(app).get('/api/dashboard/stats');
      expect(res.status).toBe(200);
      expect(res.body.data.total_warga).toBe(120);
    });

    it('Negative: error dari service', async () => {
      dashboardService.getStats.mockRejectedValue(new Error('DB Error'));

      const res = await request(app).get('/api/dashboard/stats');
      expect(res.status).toBe(500);
    });
  });

  // ── GET /api/dashboard/finance ──────────────────────────────────────────
  describe('GET /api/dashboard/finance', () => {
    it('Success: mendapatkan ringkasan keuangan (RT)', async () => {
      financeRepository.getFinanceSummaryForRT.mockResolvedValue(MOCK_FINANCE);

      const res = await request(app).get('/api/dashboard/finance');
      expect(res.status).toBe(200);
      expect(res.body.data.saldo).toBe(2500000);
    });

    it('Negative: error dari repository', async () => {
      financeRepository.getFinanceSummaryForRT.mockRejectedValue(new Error('DB Error'));

      const res = await request(app).get('/api/dashboard/finance');
      expect(res.status).toBe(500);
    });
  });
});
