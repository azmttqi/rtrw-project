const notificationService = require('../../../backend/src/services/notification.service');
const notificationRepository = require('../../../backend/src/repositories/notification.repository');
const whatsappService = require('../../../backend/src/services/whatsapp.service');
const pool = require('../../../backend/src/config/database');

jest.mock('../../../backend/src/repositories/notification.repository');
jest.mock('../../../backend/src/services/whatsapp.service');
jest.mock('../../../backend/src/config/database', () => ({
  query: jest.fn()
}));

describe('Notification Service', () => {
  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('notifyUser', () => {
    it('should create notification without sending WA', async () => {
      const mockNotif = { id: 1, title: 'Test', message: 'Hello' };
      notificationRepository.create.mockResolvedValue(mockNotif);

      const result = await notificationService.notifyUser(1, { title: 'Test', message: 'Hello' });

      expect(notificationRepository.create).toHaveBeenCalledWith({
        user_id: 1,
        title: 'Test',
        message: 'Hello'
      });
      expect(whatsappService.sendMessage).not.toHaveBeenCalled();
      expect(result).toEqual(mockNotif);
    });

    it('should create notification and send WA if requested and user has no_wa', async () => {
      const mockNotif = { id: 1, title: 'Test', message: 'Hello' };
      notificationRepository.create.mockResolvedValue(mockNotif);
      pool.query.mockResolvedValue({ rows: [{ no_wa: '08123456789' }] });

      const result = await notificationService.notifyUser(1, { title: 'Test', message: 'Hello', sendWA: true });

      expect(pool.query).toHaveBeenCalledWith('SELECT no_wa FROM users WHERE id = $1', [1]);
      expect(whatsappService.sendMessage).toHaveBeenCalledWith('08123456789', '*Test*\n\nHello');
      expect(result).toEqual(mockNotif);
    });

    it('should create notification but not send WA if user has no no_wa', async () => {
      const mockNotif = { id: 1, title: 'Test', message: 'Hello' };
      notificationRepository.create.mockResolvedValue(mockNotif);
      pool.query.mockResolvedValue({ rows: [] });

      await notificationService.notifyUser(1, { title: 'Test', message: 'Hello', sendWA: true });

      expect(whatsappService.sendMessage).not.toHaveBeenCalled();
    });
  });

  describe('getMyNotifications', () => {
    it('should calculate offset and return notifications', async () => {
      notificationRepository.findByUserId.mockResolvedValue([{ id: 1 }]);
      
      const result = await notificationService.getMyNotifications(1, 2, 10);
      
      expect(notificationRepository.findByUserId).toHaveBeenCalledWith(1, { limit: 10, offset: 10 });
      expect(result).toEqual([{ id: 1 }]);
    });
  });

  describe('markRead', () => {
    it('should call repository markAsRead', async () => {
      notificationRepository.markAsRead.mockResolvedValue({ id: 1, is_read: true });
      
      const result = await notificationService.markRead(1);
      
      expect(notificationRepository.markAsRead).toHaveBeenCalledWith(1);
      expect(result).toEqual({ id: 1, is_read: true });
    });
  });

  describe('markAllRead', () => {
    it('should call repository markAllAsRead', async () => {
      notificationRepository.markAllAsRead.mockResolvedValue(true);
      
      const result = await notificationService.markAllRead(1);
      
      expect(notificationRepository.markAllAsRead).toHaveBeenCalledWith(1);
      expect(result).toBe(true);
    });
  });
});
