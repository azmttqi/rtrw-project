const notificationRepository = require('../repositories/notification.repository');
const letterRepository = require('../repositories/letter.repository');
const announcementsRepository = require('../repositories/announcement.repository');
const { successResponse } = require('../utils/response');

const notificationController = {

  // Notifikasi Keuangan (RW: per-RT | RT: per-keluarga)
  async getDuesNotifications(req, res, next) {
    try {
      const user = req.user;
      let data = [];

      if (user.role === 'RW') {
        data = await notificationRepository.getDuesNotificationsForRW(user.rw_id);
      } else if (user.role === 'RT') {
        data = await notificationRepository.getDuesNotificationsForRT(user.rt_id);
      }

      return successResponse(res, 'Notifikasi keuangan', data);
    } catch (error) {
      next(error);
    }
  },

  // Surat untuk RT/RW (dari letter.repository yang sudah ada)
  async getLetterInbox(req, res, next) {
    try {
      const user = req.user;
      let letters = [];

      if (user.role === 'RW') {
        letters = await letterRepository.getLettersByRW(user.rw_id);
      } else if (user.role === 'RT') {
        letters = await letterRepository.getLettersByRT(user.rt_id);
      }

      return successResponse(res, 'Inbox surat', letters);
    } catch (error) {
      next(error);
    }
  },
};

module.exports = notificationController;
