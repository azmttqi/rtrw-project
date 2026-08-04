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
      user: {}
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
    next = jest.fn();
    jest.clearAllMocks();
  });

  describe('getDuesNotifications', () => {
    it('should return dues notifications for RW (Success Path)', async () => {
      req.user = { role: 'RW', rw_id: 1 };
      const mockData = [{ id: 1 }];
      notificationRepository.getDuesNotificationsForRW.mockResolvedValue(mockData);

      await notificationController.getDuesNotifications(req, res, next);

      expect(notificationRepository.getDuesNotificationsForRW).toHaveBeenCalledWith(1);
      expect(successResponse).toHaveBeenCalledWith(res, 'Notifikasi keuangan', mockData);
    });

    it('should return dues notifications for RT (Success Path)', async () => {
      req.user = { role: 'RT', rt_id: 1 };
      const mockData = [{ id: 1 }];
      notificationRepository.getDuesNotificationsForRT.mockResolvedValue(mockData);

      await notificationController.getDuesNotifications(req, res, next);

      expect(notificationRepository.getDuesNotificationsForRT).toHaveBeenCalledWith(1);
      expect(successResponse).toHaveBeenCalledWith(res, 'Notifikasi keuangan', mockData);
    });

    it('should call next on error (Negative Path)', async () => {
      req.user = { role: 'RW', rw_id: 1 };
      const error = new Error('DB Error');
      notificationRepository.getDuesNotificationsForRW.mockRejectedValue(error);

      await notificationController.getDuesNotifications(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('getLetterInbox', () => {
    it('should return letter inbox for RW (Success Path)', async () => {
      req.user = { role: 'RW', rw_id: 1 };
      const mockData = [{ id: 1 }];
      letterRepository.getLettersByRW.mockResolvedValue(mockData);

      await notificationController.getLetterInbox(req, res, next);

      expect(letterRepository.getLettersByRW).toHaveBeenCalledWith(1);
      expect(successResponse).toHaveBeenCalledWith(res, 'Inbox surat', mockData);
    });

    it('should return letter inbox for RT (Success Path)', async () => {
      req.user = { role: 'RT', rt_id: 1 };
      const mockData = [{ id: 1 }];
      letterRepository.getLettersByRT.mockResolvedValue(mockData);

      await notificationController.getLetterInbox(req, res, next);

      expect(letterRepository.getLettersByRT).toHaveBeenCalledWith(1);
      expect(successResponse).toHaveBeenCalledWith(res, 'Inbox surat', mockData);
    });

    it('should call next on error (Negative Path)', async () => {
      req.user = { role: 'RW', rw_id: 1 };
      const error = new Error('DB Error');
      letterRepository.getLettersByRW.mockRejectedValue(error);

      await notificationController.getLetterInbox(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });
});
