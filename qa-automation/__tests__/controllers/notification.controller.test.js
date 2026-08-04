const notificationController = require('../../../backend/src/controllers/notification.controller');
const notificationRepository = require('../../../backend/src/repositories/notification.repository');
const letterRepository = require('../../../backend/src/repositories/letter.repository');
const { successResponse } = require('../../../backend/src/utils/response');

jest.mock('../../../backend/src/repositories/notification.repository');
jest.mock('../../../backend/src/repositories/letter.repository');
jest.mock('../../../backend/src/utils/response');

describe('Notification Controller', () => {
  let req, res, next;

  beforeEach(() => {
    req = {
      user: { id: 1, role: 'RW', rw_id: 10, rt_id: 5 },
      query: {},
      body: {},
      params: {}
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
    next = jest.fn();
    jest.clearAllMocks();
  });

  describe('getDuesNotifications', () => {
    it('should return dues notifications for RW role (Success Path)', async () => {
      req.user = { id: 1, role: 'RW', rw_id: 10 };
      const mockData = [{ id: 1, title: 'Iuran RT 01 Jatuh Tempo' }];
      notificationRepository.getDuesNotificationsForRW.mockResolvedValue(mockData);

      await notificationController.getDuesNotifications(req, res, next);

      expect(notificationRepository.getDuesNotificationsForRW).toHaveBeenCalledWith(10);
      expect(successResponse).toHaveBeenCalledWith(res, 'Notifikasi keuangan', mockData);
    });

    it('should return dues notifications for RT role (Success Path)', async () => {
      req.user = { id: 2, role: 'RT', rt_id: 5 };
      const mockData = [{ id: 2, title: 'Warga A belum bayar iuran' }];
      notificationRepository.getDuesNotificationsForRT.mockResolvedValue(mockData);

      await notificationController.getDuesNotifications(req, res, next);

      expect(notificationRepository.getDuesNotificationsForRT).toHaveBeenCalledWith(5);
      expect(successResponse).toHaveBeenCalledWith(res, 'Notifikasi keuangan', mockData);
    });

    it('should return empty list for other roles (Success Path)', async () => {
      req.user = { id: 3, role: 'WARGA' };

      await notificationController.getDuesNotifications(req, res, next);

      expect(successResponse).toHaveBeenCalledWith(res, 'Notifikasi keuangan', []);
    });

    it('should call next on repository error (Negative Path)', async () => {
      req.user = { id: 1, role: 'RW', rw_id: 10 };
      const error = new Error('Query error');
      notificationRepository.getDuesNotificationsForRW.mockRejectedValue(error);

      await notificationController.getDuesNotifications(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('getLetterInbox', () => {
    it('should return letter inbox for RW role (Success Path)', async () => {
      req.user = { id: 1, role: 'RW', rw_id: 10 };
      const mockLetters = [{ id: 1, jenis_surat: 'SURAT_PENGANTAR_KTP', status: 'PENDING_RW' }];
      letterRepository.getLettersByRW.mockResolvedValue(mockLetters);

      await notificationController.getLetterInbox(req, res, next);

      expect(letterRepository.getLettersByRW).toHaveBeenCalledWith(10);
      expect(successResponse).toHaveBeenCalledWith(res, 'Inbox surat', mockLetters);
    });

    it('should return letter inbox for RT role (Success Path)', async () => {
      req.user = { id: 2, role: 'RT', rt_id: 5 };
      const mockLetters = [{ id: 2, jenis_surat: 'SURAT_PENGANTAR_KK', status: 'PENDING_RT' }];
      letterRepository.getLettersByRT.mockResolvedValue(mockLetters);

      await notificationController.getLetterInbox(req, res, next);

      expect(letterRepository.getLettersByRT).toHaveBeenCalledWith(5);
      expect(successResponse).toHaveBeenCalledWith(res, 'Inbox surat', mockLetters);
    });

    it('should return empty list for other roles (Success Path)', async () => {
      req.user = { id: 3, role: 'WARGA' };

      await notificationController.getLetterInbox(req, res, next);

      expect(successResponse).toHaveBeenCalledWith(res, 'Inbox surat', []);
    });

    it('should call next on error in getLetterInbox (Negative Path)', async () => {
      req.user = { id: 1, role: 'RW', rw_id: 10 };
      const error = new Error('Database inbox error');
      letterRepository.getLettersByRW.mockRejectedValue(error);

      await notificationController.getLetterInbox(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });
});
