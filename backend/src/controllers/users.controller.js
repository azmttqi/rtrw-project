const userRepository = require('../repositories/user.repository');
const { successResponse, notFoundResponse } = require('../utils/response');
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
      const { id } = req.params;
      const user = await userRepository.findById(id);
      if (!user) {
        return notFoundResponse(res, 'User not found');
      }
      return successResponse(res, 'User retrieved', user);
    } catch (error) {
      next(error);
    }
  },
};

module.exports = usersController;

