const facilityService = require('../services/facility.service');
const { successResponse, createdResponse, validationErrorResponse, notFoundResponse } = require('../utils/response');

const facilitiesController = {
  // --- Catalog ---
  async createFacility(req, res, next) {
    try {
      const { nama_fasilitas, deskripsi, foto_url, alamat, koordinat_maps_url, bisa_dipinjam } = req.body;
      const rt_id = req.user.rt_id; // From authenticate midlleware (Assuming RT creates it)

      const data = { rt_id, nama_fasilitas, deskripsi, foto_url, alamat, koordinat_maps_url, bisa_dipinjam };
      const facility = await facilityService.createFacility(data);

      return createdResponse(res, 'Fasilitas ditambahkan', facility);
    } catch (error) {
      if (error.message.includes('wajib diisi')) return validationErrorResponse(res, error.message);
      next(error);
    }
  },

  async getFacilities(req, res, next) {
    try {
      // Warga bisa filter by RT mereka
      const rt_id = req.query.rt_id || req.user.rt_id; 
      
      const facilities = await facilityService.getFacilities(rt_id);
      return successResponse(res, 'Daftar fasilitas', facilities);
    } catch (error) {
      next(error);
    }
  },

  async updateFacility(req, res, next) {
    try {
      const { id } = req.params;
      const data = req.body;
      const facility = await facilityService.updateFacility(id, data);

      return successResponse(res, 'Fasilitas diperbarui', facility);
    } catch (error) {
      if (error.message.includes('tidak ditemukan')) return notFoundResponse(res, error.message);
      next(error);
    }
  },

  async deleteFacility(req, res, next) {
    try {
      const { id } = req.params;
      await facilityService.deleteFacility(id);
      return successResponse(res, 'Fasilitas dihapus', null);
    } catch (error) {
      if (error.message.includes('tidak ditemukan')) return notFoundResponse(res, error.message);
      next(error);
    }
  },

  // --- Reservations ---
  async createReservation(req, res, next) {
      try {
          const { id: facility_id } = req.params; 
          const { tanggal_mulai, tanggal_selesai, keterangan } = req.body;
          const peminjam_user_id = req.user.id; // Any user (warga)

          const data = { facility_id, peminjam_user_id, tanggal_mulai, tanggal_selesai, keterangan };
          const reservation = await facilityService.createReservation(data);

          return createdResponse(res, 'Pengajuan peminjaman fasilitas berhasil dikirim', reservation);
      } catch (error) {
          if (error.message.includes('lengkap') || error.message.includes('sebelum') || error.message.includes('dibooking') || error.message.includes('tidak diperuntukkan')) {
              return validationErrorResponse(res, error.message);
          }
          if (error.message.includes('tidak ditemukan')) {
              return notFoundResponse(res, error.message);
          }
          next(error);
      }
  },

  async getReservations(req, res, next) {
      try {
          const rt_id = req.user.rt_id; // RT viewing their facility reservations
          const reservations = await facilityService.getReservations(rt_id);
          return successResponse(res, 'Daftar pengajuan peminjaman', reservations);
      } catch (error) {
          next(error);
      }
  },

  async verifyReservation(req, res, next) {
      try {
          const { id } = req.params;
          const { status } = req.body; // 'APPROVED' | 'REJECTED'

          const reservation = await facilityService.verifyReservation(id, status);
          return successResponse(res, 'Status pengajuan berhasil diupdate', reservation);
      } catch (error) {
          if (error.message.includes('tidak valid')) return validationErrorResponse(res, error.message);
          if (error.message.includes('tidak ditemukan')) return notFoundResponse(res, error.message);
          next(error);
      }
  }
};

module.exports = facilitiesController;
