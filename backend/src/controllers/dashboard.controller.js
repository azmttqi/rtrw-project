const dashboardService = require('../services/dashboard.service');
const financeRepository = require('../repositories/finance.repository');
const { successResponse, errorResponse } = require('../utils/response');

const dashboardController = {
  async getStats(req, res, next) {
    try {
      const stats = await dashboardService.getStats(req.user);
      return successResponse(res, 'Dashboard statistics fetched', stats);
    } catch (error) {
      next(error);
    }
  },

  async getFinanceSummary(req, res, next) {
    try {
      const user = req.user;
      let data = {};
      if (user.role === 'RW') {
        data = await financeRepository.getFinanceSummaryForRW(user.rw_id);
      } else if (user.role === 'RT') {
        data = await financeRepository.getFinanceSummaryForRT(user.rt_id);
      } else if (user.role === 'WARGA') {
        data = await financeRepository.getFinanceSummaryForWarga(user.id);
      }
      return successResponse(res, 'Finance summary', data);
    } catch (error) {
      next(error);
    }
  },
};

module.exports = dashboardController;
