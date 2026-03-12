const pool = require('../config/database');

const notificationRepository = {
  async create({ user_id, title, message }) {
    const result = await pool.query(
      'INSERT INTO notifications (user_id, title, message) VALUES ($1, $2, $3) RETURNING *',
      [user_id, title, message]
    );
    return result.rows[0];
  },

  async findByUserId(userId, { limit = 10, offset = 0 } = {}) {
    const result = await pool.query(
      'SELECT * FROM notifications WHERE user_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3',
      [userId, limit, offset]
    );
    return result.rows;
  },

  async markAsRead(id) {
    const result = await pool.query(
      'UPDATE notifications SET is_read = TRUE WHERE id = $1 RETURNING *',
      [id]
    );
    return result.rows[0];
  },

  async markAllAsRead(userId) {
    const result = await pool.query(
      'UPDATE notifications SET is_read = TRUE WHERE user_id = $1 RETURNING *',
      [userId]
    );
    return result.rows;
  },

  async delete(id) {
    await pool.query('DELETE FROM notifications WHERE id = $1', [id]);
  }
};

module.exports = notificationRepository;
