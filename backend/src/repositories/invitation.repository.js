const pool = require('../config/database');
const { v4: uuidv4 } = require('uuid');

const invitationRepository = {
  async findByToken(token) {
    const result = await pool.query('SELECT * FROM invitations WHERE token = $1', [token]);
    return result.rows[0];
  },

  async findByNoWaAndRT(no_wa, rt_id) {
    const result = await pool.query(
      'SELECT * FROM invitations WHERE no_wa = $1 AND rt_id = $2 AND is_used = false AND expires_at > NOW()',
      [no_wa, rt_id]
    );
    return result.rows[0];
  },

  async findByNoWaAndRW(no_wa, rw_id) {
    const result = await pool.query(
      'SELECT * FROM invitations WHERE no_wa = $1 AND rw_id = $2 AND is_used = false AND expires_at > NOW()',
      [no_wa, rw_id]
    );
    return result.rows[0];
  },

  async findAllByRT(rt_id) {
    const result = await pool.query(
      'SELECT * FROM invitations WHERE rt_id = $1 ORDER BY created_at DESC',
      [rt_id]
    );
    return result.rows;
  },

  async findAllByRW(rw_id) {
    const result = await pool.query(
      'SELECT * FROM invitations WHERE rw_id = $1 ORDER BY created_at DESC',
      [rw_id]
    );
    return result.rows;
  },

  async create({ no_wa = null, rt_id = null, rw_id = null }) {
    const token = uuidv4();
    const result = await pool.query(
      `INSERT INTO invitations (no_wa, rt_id, rw_id, token) VALUES ($1, $2, $3, $4) RETURNING *`,
      [no_wa, rt_id, rw_id, token]
    );
    return result.rows[0];
  },

  async markAsUsed(token) {
    const result = await pool.query(
      'UPDATE invitations SET is_used = true WHERE token = $1 RETURNING *',
      [token]
    );
    return result.rows[0];
  },

  async delete(id) {
    const result = await pool.query('DELETE FROM invitations WHERE id = $1 RETURNING *', [id]);
    return result.rows[0];
  },
};

module.exports = invitationRepository;

