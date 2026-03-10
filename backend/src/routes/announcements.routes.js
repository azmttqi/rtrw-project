const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth.middleware');
const { isRT, isRW } = require('../middleware/role.middleware');
const pool = require('../config/database');
const { successResponse, createdResponse, validationErrorResponse, notFoundResponse } = require('../utils/response');
const { getPaginationMeta } = require('../utils/pagination');

// Create announcement
router.post('/', authenticate, isRT(), async (req, res, next) => {
  try {
    const { target, target_rt_id, judul, konten, is_kegiatan, tanggal_kegiatan } = req.body;
    const pembuat_user_id = req.user.id;

    if (!target || !judul || !konten) {
      return validationErrorResponse(res, 'Data pengumuman tidak lengkap');
    }

    const result = await pool.query(
      `INSERT INTO announcements (pembuat_user_id, target, target_rt_id, judul, konten, is_kegiatan, tanggal_kegiatan) 
       VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
      [pembuat_user_id, target, target_rt_id || null, judul, konten, is_kegiatan || false, tanggal_kegiatan || null]
    );

    return createdResponse(res, 'Pengumuman dibuat', result.rows[0]);
  } catch (error) {
    next(error);
  }
});

// Get announcements
router.get('/', authenticate, async (req, res, next) => {
  try {
    const { rt_id, rw_id, page = 1, limit = 10 } = req.query;
    const offset = (parseInt(page) - 1) * parseInt(limit);

    let query = 'SELECT a.*, u.nama as pembuat_nama FROM announcements a JOIN users u ON a.pembuat_user_id = u.id WHERE 1=1';
    const params = [];
    let paramIndex = 1;

    if (rt_id) {
      query += ` AND (a.target = 'SEMUA_RW' OR a.target = 'SEMUA_RT' OR a.target_rt_id = $${paramIndex})`;
      params.push(rt_id);
      paramIndex++;
    }

    query += ` ORDER BY a.created_at DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(parseInt(limit), offset);

    const result = await pool.query(query, params);
    const countResult = await pool.query('SELECT COUNT(*) FROM announcements');
    const total = parseInt(countResult.rows[0].count);

    return successResponse(res, 'Daftar pengumuman', {
      announcements: result.rows,
      pagination: getPaginationMeta(total, page, limit),
    });
  } catch (error) {
    next(error);
  }
});

// Update announcement
router.patch('/:id', authenticate, isRT(), async (req, res, next) => {
  try {
    const { id } = req.params;
    const { judul, konten, is_kegiatan, tanggal_kegiatan } = req.body;

    const result = await pool.query(
      `UPDATE announcements SET judul = $1, konten = $2, is_kegiatan = $3, tanggal_kegiatan = $4 WHERE id = $5 RETURNING *`,
      [judul, konten, is_kegiatan, tanggal_kegiatan, id]
    );

    if (result.rows.length === 0) {
      return notFoundResponse(res, 'Pengumuman tidak ditemukan');
    }

    return successResponse(res, 'Pengumuman diperbarui', result.rows[0]);
  } catch (error) {
    next(error);
  }
});

// Delete announcement
router.delete('/:id', authenticate, isRT(), async (req, res, next) => {
  try {
    const { id } = req.params;
    const result = await pool.query('DELETE FROM announcements WHERE id = $1 RETURNING *', [id]);

    if (result.rows.length === 0) {
      return notFoundResponse(res, 'Pengumuman tidak ditemukan');
    }

    return successResponse(res, 'Pengumuman dihapus');
  } catch (error) {
    next(error);
  }
});

module.exports = router;

