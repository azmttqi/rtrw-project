const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth.middleware');
const { isRT } = require('../middleware/role.middleware');
const familyRepository = require('../repositories/family.repository');
const { successResponse, createdResponse, validationErrorResponse, notFoundResponse } = require('../utils/response');
const { getPaginationMeta } = require('../utils/pagination');

// Get my family (for warga)
router.get('/me', authenticate, async (req, res, next) => {
  try {
    const family = await familyRepository.findByUserId(req.user.id);
    if (!family) {
      return notFoundResponse(res, 'Keluarga tidak ditemukan');
    }
    return successResponse(res, 'Data keluarga', family);
  } catch (error) {
    next(error);
  }
});

// Create family (for warga)
router.post('/', authenticate, async (req, res, next) => {
  try {
    const { rt_id, no_kk, tipe_warga, status_tinggal, status_pernikahan } = req.body;

    if (!no_kk || !rt_id || !tipe_warga || !status_tinggal) {
      return validationErrorResponse(res, 'Data keluarga tidak lengkap');
    }

    // Check if KK already exists
    const existing = await familyRepository.findByNoKK(no_kk);
    if (existing) {
      return validationErrorResponse(res, 'Nomor KK sudah terdaftar');
    }

    const family = await familyRepository.create({
      user_id: req.user.id,
      rt_id,
      no_kk,
      tipe_warga,
      status_tinggal,
      status_pernikahan,
    });

    return createdResponse(res, 'Keluarga berhasil didaftarkan', family);
  } catch (error) {
    next(error);
  }
});

// Get families by RT
router.get('/', authenticate, isRT(), async (req, res, next) => {
  try {
    const { page = 1, limit = 10 } = req.query;
    const rt_id = req.user.rt_id;

    const result = await familyRepository.findAllByRT(rt_id, { 
      page: parseInt(page), 
      limit: parseInt(limit) 
    });

    return successResponse(res, 'Daftar keluarga', {
      families: result.data,
      pagination: getPaginationMeta(result.total, page, limit),
    });
  } catch (error) {
    next(error);
  }
});

// Verify family (RT only)
router.patch('/:id/verify', authenticate, isRT(), async (req, res, next) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!['APPROVED', 'REJECTED'].includes(status)) {
      return validationErrorResponse(res, 'Status tidak valid');
    }

    const family = await familyRepository.update(id, { status_verifikasi: status });
    if (!family) {
      return notFoundResponse(res, 'Keluarga tidak ditemukan');
    }

    return successResponse(res, `Keluarga berhasil di${status === 'APPROVED' ? 'setuju' : 'tolak'}`, family);
  } catch (error) {
    next(error);
  }
});

module.exports = router;

