const familyService = require('../services/family.service');
const { successResponse, createdResponse, errorResponse, validationErrorResponse, notFoundResponse } = require('../utils/response');
const { getPaginationMeta } = require('../utils/pagination');

const familiesController = {
  async getMyFamily(req, res, next) {
    try {
      const family = await familyService.getMyFamily(req.user.id);
      return successResponse(res, 'Data keluarga', family);
    } catch (error) {
      if (error.message === 'Keluarga tidak ditemukan') {
        return notFoundResponse(res, error.message);
      }
      next(error);
    }
  },

  async createFamily(req, res, next) {
    try {
      const { rt_id, no_kk, tipe_warga, status_tinggal, status_pernikahan } = req.body;
      const documents = req.files ? req.files.map(file => ({
        jenis_dokumen: 'KK/KTP', // Default category, could be more dynamic
        file_url: `/uploads/documents/${file.filename}`
      })) : [];

      const family = await familyService.createFamily(req.user.id, {
        rt_id, no_kk, tipe_warga, status_tinggal, status_pernikahan, documents
      });
      return createdResponse(res, 'Keluarga berhasil didaftarkan', family);
    } catch (error) {
       if (error.message === 'Data keluarga tidak lengkap' || error.message === 'Nomor KK sudah terdaftar') {
        return validationErrorResponse(res, error.message);
      }
      next(error);
    }
  },

  async getFamiliesByRT(req, res, next) {
    try {
      const { page = 1, limit = 10 } = req.query;
      const rt_id = req.user.rt_id;

      const result = await familyService.getFamiliesByRT(rt_id, page, limit);

      return successResponse(res, 'Daftar keluarga', {
        families: result.data,
        pagination: getPaginationMeta(result.total, page, limit),
      });
    } catch (error) {
      next(error);
    }
  },

  async verifyFamily(req, res, next) {
    try {
      const { id } = req.params;
      const { status } = req.body;

      const family = await familyService.verifyFamily(id, status);
      return successResponse(res, `Keluarga berhasil di${status === 'APPROVED' ? 'setuju' : 'tolak'}`, family);
    } catch (error) {
      if (error.message === 'Status tidak valid') {
        return validationErrorResponse(res, error.message);
      }
      if (error.message === 'Keluarga tidak ditemukan') {
        return notFoundResponse(res, error.message);
      }
      next(error);
    }
  }
};

module.exports = familiesController;
