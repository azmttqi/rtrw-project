const pool = require('../config/database');

const announcementRepository = {
  async createAnnouncement(data) {
    const { pembuat_user_id, target, target_rt_id, judul, konten, is_kegiatan, tanggal_kegiatan } = data;
    const result = await pool.query(
      `INSERT INTO announcements (pembuat_user_id, target, target_rt_id, judul, konten, is_kegiatan, tanggal_kegiatan) 
       VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
      [pembuat_user_id, target, target_rt_id || null, judul, konten, is_kegiatan || false, tanggal_kegiatan || null]
    );
    return result.rows[0];
  },

  async getAnnouncements(filters, page, limit) {
    const offset = (page - 1) * limit;
    const { rt_id } = filters;

    let query = 'SELECT a.*, u.nama as pembuat_nama FROM announcements a JOIN users u ON a.pembuat_user_id = u.id WHERE 1=1';
    const params = [];
    let paramIndex = 1;

    if (rt_id) {
      query += ` AND (a.target = 'SEMUA_RW' OR a.target = 'SEMUA_RT' OR a.target_rt_id = $${paramIndex})`;
      params.push(rt_id);
      paramIndex++;
    }

    query += ` ORDER BY a.created_at DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(limit, offset);

    const result = await pool.query(query, params);
    
    // Count Query Needs matching logic
    let countQuery = 'SELECT COUNT(*) FROM announcements a WHERE 1=1';
    const countParams = [];
    let countParamIndex = 1;

    if (rt_id) {
      countQuery += ` AND (a.target = 'SEMUA_RW' OR a.target = 'SEMUA_RT' OR a.target_rt_id = $${countParamIndex})`;
      countParams.push(rt_id);
    }

    const countResult = await pool.query(countQuery, countParams);

    return {
      data: result.rows,
      total: parseInt(countResult.rows[0].count)
    };
  },

  async getAnnouncementById(id) {
     const result = await pool.query('SELECT * FROM announcements WHERE id = $1', [id]);
     return result.rows[0];
  },

  async updateAnnouncement(id, data) {
    const { judul, konten, is_kegiatan, tanggal_kegiatan } = data;
    const result = await pool.query(
      `UPDATE announcements SET judul = $1, konten = $2, is_kegiatan = $3, tanggal_kegiatan = $4 WHERE id = $5 RETURNING *`,
      [judul, konten, is_kegiatan, tanggal_kegiatan, id]
    );
    return result.rows[0];
  },

  async deleteAnnouncement(id) {
    const result = await pool.query('DELETE FROM announcements WHERE id = $1 RETURNING *', [id]);
    return result.rows[0];
  }
};

module.exports = announcementRepository;
