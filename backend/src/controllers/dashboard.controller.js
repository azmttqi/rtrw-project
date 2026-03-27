const dashboardService = require('../services/dashboard.service');
const { successResponse, errorResponse } = require('../utils/response');

const dashboardController = {
  async getStats(req, res, next) {
    try {
      const stats = await dashboardService.getStats(req.user);
      return successResponse(res, 'Dashboard statistics fetched', stats);
    } catch (error) {
      next(error);
    }
  }
};

module.exports = dashboardController;
