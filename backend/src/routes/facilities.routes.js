const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth.middleware');
const { isRT } = require('../middleware/role.middleware');
const pool = require('../config/database');
const { successResponse, createdResponse, validationErrorResponse, notFoundResponse } = require('../utils/response');

// Create facility
router.post('/', authenticate, isRT(), async (req, res, next) => {
  try {
    const { nama_fasilitas, deskripsi, foto_url } = req.body;
    const rt_id = req.user.rt_id;

    if (!nama_fasilitas) {
      return validationErrorResponse(res, 'Nama fasilitas wajib diisi');
    }

    const result = await pool.query(
      'INSERT INTO facilities (rt_id, nama_fasilitas, deskripsi, foto_url) VALUES ($1, $2, $3, $4) RETURNING *',
      [rt_id, nama_fasilitas, deskripsi, foto_url]
    );

    return createdResponse(res, 'Fasilitas ditambahkan', result.rows[0]);
  } catch (error) {
    next(error);
  }
});

// Get facilities
router.get('/', authenticate, async (req, res, next) => {
  try {
    const { rt_id } = req.query;
    let query = 'SELECT * FROM facilities WHERE 1=1';
    const params = [];

    if (rt_id) {
      query += ' AND rt_id = $1';
      params.push(rt_id);
    }

    query += ' ORDER BY created_at DESC';

    const result = await pool.query(query, params);
    return successResponse(res, 'Daftar fasilitas', result.rows);
  } catch (error) {
    next(error);
  }
});

// Update facility
router.patch('/:id', authenticate, isRT(), async (req, res, next) => {
  try {
    const { id } = req.params;
    const { nama_fasilitas, deskripsi, foto_url } = req.body;

    const result = await pool.query(
      'UPDATE facilities SET nama_fasilitas = $1, deskripsi = $2, foto_url = $3 WHERE id = $4 RETURNING *',
      [nama_fasilitas, deskripsi, foto_url, id]
    );

    if (result.rows.length === 0) {
      return notFoundResponse(res, 'Fasilitas tidak ditemukan');
    }

    return successResponse(res, 'Fasilitas diperbarui', result.rows[0]);
  } catch (error) {
    next(error);
  }
});

// Delete facility
router.delete('/:id', authenticate, isRT(), async (req, res, next) => {
  try {
    const { id } = req.params;
    const result = await pool.query('DELETE FROM facilities WHERE id = $1 RETURNING *', [id]);

    if (result.rows.length === 0) {
      return notFoundResponse(res, 'Fasilitas tidak ditemukan');
    }

    return successResponse(res, 'Fasilitas dihapus');
  } catch (error) {
    next(error);
  }
});

module.exports = router;

