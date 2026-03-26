const userRepository = require('../repositories/user.repository');
const { successResponse, errorResponse, validationErrorResponse } = require('../utils/response');
const { getPaginationMeta } = require('../utils/pagination');

const usersController = {
  async getUsers(req, res, next) {
    try {
      const { rt_id, rw_id, page = 1, limit = 10 } = req.query;
      const result = await userRepository.findAll({ rt_id, rw_id, page: parseInt(page), limit: parseInt(limit) });
      
      return successResponse(res, 'Users retrieved', {
        users: result.data,
        pagination: getPaginationMeta(result.total, page, limit),
      });
    } catch (error) {
      next(error);
    }
  },

  async getUserById(req, res, next) {
    try {
      const user = await userRepository.findById(req.params.id);
      if (!user) return errorResponse(res, 'User not found', 404);
      return successResponse(res, 'User details', user);
    } catch (error) {
      next(error);
    }
  },

  async verifyRT(req, res, next) {
    try {
      const { id } = req.params;
      const { status, rt_id } = req.body; // status: 'APPROVED' or 'REJECTED'

      const user = await userRepository.findById(id);
      if (!user || user.role !== 'RT') {
        return validationErrorResponse(res, 'User bukan RT atau tidak ditemukan');
      }

      if (status === 'APPROVED') {
        const updateData = { is_verified: true };
        if (rt_id) updateData.rt_id = rt_id;
        
        const updatedUser = await userRepository.update(id, updateData);
        return successResponse(res, 'RT berhasil diverifikasi', updatedUser);
      } else {
        // Jika ditolak, mungkin hapus atau biarkan unverified
        return successResponse(res, 'Verifikasi RT ditolak');
      }
    } catch (error) {
      next(error);
    }
  },
};

module.exports = usersController;

