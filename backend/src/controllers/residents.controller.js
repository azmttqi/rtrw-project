const residentService = require('../services/resident.service');
const { successResponse, createdResponse, validationErrorResponse, notFoundResponse } = require('../utils/response');

const residentsController = {
  async getResidentsByFamily(req, res, next) {
    try {
      const residents = await residentService.getResidentsByFamily(req.query.family_id);
      return successResponse(res, 'Daftar anggota keluarga', residents);
    } catch (error) {
      if (error.message === 'Family ID diperlukan') {
        return validationErrorResponse(res, error.message);
      }
      next(error);
    }
  },

  async addResident(req, res, next) {
    try {
      const { family_id, nik, nama_lengkap, jenis_kelamin, tanggal_lahir, hubungan_keluarga } = req.body;
      const resident = await residentService.addResident({
        family_id, nik, nama_lengkap, jenis_kelamin, tanggal_lahir, hubungan_keluarga
      });
      return createdResponse(res, 'Anggota keluarga ditambahkan', resident);
    } catch (error) {
       if (error.message === 'Data anggota keluarga tidak lengkap' || error.message === 'NIK sudah terdaftar') {
        return validationErrorResponse(res, error.message);
      }
      next(error);
    }
  },

  async updateResident(req, res, next) {
    try {
      const { id } = req.params;
      const { nik, nama_lengkap, jenis_kelamin, tanggal_lahir, hubungan_keluarga } = req.body;
      
      const resident = await residentService.updateResident(id, {
        nik, nama_lengkap, jenis_kelamin, tanggal_lahir, hubungan_keluarga
      });
      return successResponse(res, 'Anggota keluarga diperbarui', resident);
    } catch (error) {
       if (error.message === 'Anggota keluarga tidak ditemukan') {
        return notFoundResponse(res, error.message);
      }
      next(error);
    }
  },

  async deleteResident(req, res, next) {
    try {
      const { id } = req.params;
      const resident = await residentService.deleteResident(id);
      return successResponse(res, 'Anggota keluarga dihapus', resident);
    } catch (error) {
       if (error.message === 'Anggota keluarga tidak ditemukan') {
        return notFoundResponse(res, error.message);
      }
      next(error);
    }
  }
};

module.exports = residentsController;
