const announcementService = require('../services/announcement.service');
const { successResponse, createdResponse, errorResponse, validationErrorResponse, notFoundResponse } = require('../utils/response');
const { getPaginationMeta } = require('../utils/pagination');

const announcementsController = {
  async createAnnouncement(req, res, next) {
    try {
      const { target, target_rt_id, judul, konten, is_kegiatan, tanggal_kegiatan } = req.body;
      const pembuat_user_id = req.user.id; // From authenticate middleware

      const data = { pembuat_user_id, target, target_rt_id, judul, konten, is_kegiatan, tanggal_kegiatan };
      const announcement = await announcementService.createAnnouncement(data);

      return createdResponse(res, 'Pengumuman dibuat', announcement);
    } catch (error) {
      if (error.message.includes('не lengkap') || error.message.includes('diisi')) {
        return validationErrorResponse(res, error.message);
      }
      next(error);
    }
  },

  async getAnnouncements(req, res, next) {
    try {
      const { rt_id, page = 1, limit = 10 } = req.query;
      // Enforce rw_id for non-admin users
      let rw_id = req.user.rw_id;
      if (req.user.role === 'ADMIN') {
         // Allow admin to see all via query or just no filter
         rw_id = req.query.rw_id || null;
      }
      const filters = { rt_id, rw_id };

      const result = await announcementService.getAnnouncements(filters, page, limit);

      return successResponse(res, 'Daftar pengumuman', {
        announcements: result.data,
        pagination: getPaginationMeta(result.total, page, limit),
      });
    } catch (error) {
      next(error);
    }
  },

  async updateAnnouncement(req, res, next) {
    try {
      const { id } = req.params;
      const { judul, konten, is_kegiatan, tanggal_kegiatan } = req.body;

      const data = { judul, konten, is_kegiatan, tanggal_kegiatan };
      const announcement = await announcementService.updateAnnouncement(id, data);

      return successResponse(res, 'Pengumuman diperbarui', announcement);
    } catch (error) {
      if (error.message.includes('tidak ditemukan')) return notFoundResponse(res, error.message);
      next(error);
    }
  },

  async deleteAnnouncement(req, res, next) {
    try {
      const { id } = req.params;
      await announcementService.deleteAnnouncement(id);
      return successResponse(res, 'Pengumuman dihapus', null);
    } catch (error) {
      if (error.message.includes('tidak ditemukan')) return notFoundResponse(res, error.message);
      next(error);
    }
  }
};

module.exports = announcementsController;
