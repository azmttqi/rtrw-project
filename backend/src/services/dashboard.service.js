const dashboardRepository = require('../repositories/dashboard.repository');

const dashboardService = {
  async getStats(user) {
    if (user.role === 'RW') {
      return await dashboardRepository.getRWStats(user.rw_id);
    } else if (user.role === 'RT') {
      return await dashboardRepository.getRTStats(user.rt_id);
    } else if (user.role === 'WARGA') {
      return await dashboardRepository.getWargaStats(user.id, user.rt_id);
    } else {
      throw new Error('Unauthorized role for dashboard stats');
    }
  }
};

module.exports = dashboardService;
