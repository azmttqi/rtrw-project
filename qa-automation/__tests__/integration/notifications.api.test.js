const request = require('supertest');

jest.mock('../../../backend/src/middleware/auth.middleware', () => ({
  authenticate: (req, _res, next) => {
    req.user = { id: 'user-1', role: 'RT', rt_id: 'rt-1', rw_id: 'rw-1' };
    next();
  },
}));

jest.mock('../../../backend/src/repositories/notification.repository');
jest.mock('../../../backend/src/repositories/letter.repository');
jest.mock('../../../backend/src/repositories/announcement.repository');

const notificationRepository  = require('../../../backend/src/repositories/notification.repository');
const letterRepository         = require('../../../backend/src/repositories/letter.repository');

const app = require('../../../backend/src/app');

const MOCK_DUES_NOTIF = [{ family_id: 'fam-1', tunggakan: 2, total: 100000 }];
const MOCK_LETTERS    = [{ id: 'let-1', jenis_surat: 'DOMISILI', status: 'PENDING' }];

describe('Notifications API Integration Tests', () => {
  beforeEach(() => jest.clearAllMocks());

  // ── GET /api/notifications/dues ─────────────────────────────────────────
  describe('GET /api/notifications/dues', () => {
    it('Success: notifikasi iuran untuk RT', async () => {
      notificationRepository.getDuesNotificationsForRT.mockResolvedValue(MOCK_DUES_NOTIF);

      const res = await request(app).get('/api/notifications/dues');
      expect(res.status).toBe(200);
      expect(res.body.data).toHaveLength(1);
    });

    it('Negative: error dari repository', async () => {
      notificationRepository.getDuesNotificationsForRT.mockRejectedValue(new Error('DB Error'));

      const res = await request(app).get('/api/notifications/dues');
      expect(res.status).toBe(500);
    });
  });

  // ── GET /api/notifications/letters ─────────────────────────────────────
  describe('GET /api/notifications/letters', () => {
    it('Success: inbox surat untuk RT', async () => {
      letterRepository.getLettersByRT.mockResolvedValue(MOCK_LETTERS);

      const res = await request(app).get('/api/notifications/letters');
      expect(res.status).toBe(200);
      expect(res.body.data).toHaveLength(1);
    });

    it('Negative: error dari repository', async () => {
      letterRepository.getLettersByRT.mockRejectedValue(new Error('DB Error'));

      const res = await request(app).get('/api/notifications/letters');
      expect(res.status).toBe(500);
    });
  });
});
