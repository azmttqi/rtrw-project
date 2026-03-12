const notificationRepository = require('../repositories/notification.repository');
const whatsappService = require('./whatsapp.service');
const pool = require('../config/database');

const notificationService = {
  /**
   * Membuat notifikasi baru dan opsional mengirim WhatsApp
   */
  async notifyUser(userId, { title, message, sendWA = false }) {
    // 1. Simpan ke database untuk history di aplikasi
    const notification = await notificationRepository.create({
      user_id: userId,
      title,
      message
    });

    // 2. Jika diminta, kirim melalui WhatsApp
    if (sendWA) {
      const userRes = await pool.query('SELECT no_wa FROM users WHERE id = $1', [userId]);
      const no_wa = userRes.rows[0]?.no_wa;
      
      if (no_wa) {
        await whatsappService.sendMessage(no_wa, `*${title}*\n\n${message}`);
      }
    }

    return notification;
  },

  async getMyNotifications(userId, page = 1, limit = 10) {
    const offset = (page - 1) * limit;
    return await notificationRepository.findByUserId(userId, { limit, offset });
  },

  async markRead(id) {
    return await notificationRepository.markAsRead(id);
  },

  async markAllRead(userId) {
    return await notificationRepository.markAllAsRead(userId);
  }
};

module.exports = notificationService;
