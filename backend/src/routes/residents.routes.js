const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth.middleware');
const residentRepository = require('../repositories/resident.repository');
const familyRepository = require('../repositories/family.repository');
const { successResponse, createdResponse, validationErrorResponse, notFoundResponse } = require('../utils/response');

// Get residents by family
router.get('/', authenticate, async (req, res, next) => {
  try {
    const { family_id } = req.query;
    
    if (!family_id) {
      return validationErrorResponse(res, 'Family ID diperlukan');
    }

    const residents = await residentRepository.findByFamilyId(family_id);
    return successResponse(res, 'Daftar anggota keluarga', residents);
  } catch (error) {
    next(error);
  }
});

// Add resident
router.post('/', authenticate, async (req, res, next) => {
  try {
    const { family_id, nik, nama_lengkap, jenis_kelamin, tanggal_lahir, hubungan_keluarga } = req.body;

    if (!family_id || !nik || !nama_lengkap || !jenis_kelamin || !tanggal_lahir || !hubungan_keluarga) {
      return validationErrorResponse(res, 'Data anggota keluarga tidak lengkap');
    }

    // Check if NIK already exists
    const existingNik = await residentRepository.findByNik(nik);
    if (existingNik) {
      return validationErrorResponse(res, 'NIK sudah terdaftar');
    }

    const resident = await residentRepository.create({
      family_id,
      nik,
      nama_lengkap,
      jenis_kelamin,
      tanggal_lahir,
      hubungan_keluarga,
    });

    return createdResponse(res, 'Anggota keluarga ditambahkan', resident);
  } catch (error) {
    next(error);
  }
});

// Update resident
router.patch('/:id', authenticate, async (req, res, next) => {
  try {
    const { id } = req.params;
    const { nik, nama_lengkap, jenis_kelamin, tanggal_lahir, hubungan_keluarga } = req.body;

    const resident = await residentRepository.update(id, {
      nik,
      nama_lengkap,
      jenis_kelamin,
      tanggal_lahir,
      hubungan_keluarga,
    });

    if (!resident) {
      return notFoundResponse(res, 'Anggota keluarga tidak ditemukan');
    }

    return successResponse(res, 'Anggota keluarga diperbarui', resident);
  } catch (error) {
    next(error);
  }
});

// Delete resident
router.delete('/:id', authenticate, async (req, res, next) => {
  try {
    const { id } = req.params;
    const resident = await residentRepository.delete(id);

    if (!resident) {
      return notFoundResponse(res, 'Anggota keluarga tidak ditemukan');
    }

    return successResponse(res, 'Anggota keluarga dihapus');
  } catch (error) {
    next(error);
  }
});

module.exports = router;

