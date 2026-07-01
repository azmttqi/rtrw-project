const dashboardService = require('../../../backend/src/services/dashboard.service');
const dashboardRepository = require('../../../backend/src/repositories/dashboard.repository');

jest.mock('../../../backend/src/repositories/dashboard.repository');

describe('Dashboard Service', () => {
  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should return RW stats if user role is RW', async () => {
    const mockStats = { total: 100 };
    dashboardRepository.getRWStats.mockResolvedValue(mockStats);
    
    const user = { role: 'RW', rw_id: 1 };
    const result = await dashboardService.getStats(user);
    
    expect(dashboardRepository.getRWStats).toHaveBeenCalledWith(1);
    expect(result).toEqual(mockStats);
  });

  it('should return RT stats if user role is RT', async () => {
    const mockStats = { total: 50 };
    dashboardRepository.getRTStats.mockResolvedValue(mockStats);
    
    const user = { role: 'RT', rt_id: 2 };
    const result = await dashboardService.getStats(user);
    
    expect(dashboardRepository.getRTStats).toHaveBeenCalledWith(2);
    expect(result).toEqual(mockStats);
  });

  it('should return Warga stats if user role is WARGA', async () => {
    const mockStats = { total: 10 };
    dashboardRepository.getWargaStats.mockResolvedValue(mockStats);
    
    const user = { role: 'WARGA', id: 5, rt_id: 2 };
    const result = await dashboardService.getStats(user);
    
    expect(dashboardRepository.getWargaStats).toHaveBeenCalledWith(5, 2);
    expect(result).toEqual(mockStats);
  });

  it('should throw Error for unauthorized role', async () => {
    const user = { role: 'ADMIN' };
    await expect(dashboardService.getStats(user)).rejects.toThrow('Unauthorized role for dashboard stats');
  });
});
