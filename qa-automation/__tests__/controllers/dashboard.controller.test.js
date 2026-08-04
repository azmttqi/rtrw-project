const dashboardController = require('../../../backend/src/controllers/dashboard.controller');
const dashboardService = require('../../../backend/src/services/dashboard.service');
const financeRepository = require('../../../backend/src/repositories/finance.repository');
const { successResponse } = require('../../../backend/src/utils/response');
const Tesseract = require('tesseract.js');

jest.mock('../../../backend/src/services/dashboard.service');
jest.mock('../../../backend/src/repositories/finance.repository');
jest.mock('../../../backend/src/utils/response');
jest.mock('tesseract.js', () => ({
  recognize: jest.fn()
}), { virtual: true });

describe('Dashboard Controller', () => {
  let req, res, next;

  beforeEach(() => {
    req = {
      user: {},
      file: null
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
    next = jest.fn();
    jest.clearAllMocks();
  });

  describe('getStats', () => {
    it('should get dashboard stats and return 200 (Success Path)', async () => {
      req.user = { id: 1, role: 'WARGA' };
      const mockStats = { total_warga: 10 };
      dashboardService.getStats.mockResolvedValue(mockStats);

      await dashboardController.getStats(req, res, next);

      expect(dashboardService.getStats).toHaveBeenCalledWith(req.user);
      expect(successResponse).toHaveBeenCalledWith(res, 'Dashboard statistics fetched', mockStats);
    });

    it('should call next on error (Negative Path)', async () => {
      req.user = { id: 1 };
      const error = new Error('Database Error');
      dashboardService.getStats.mockRejectedValue(error);

      await dashboardController.getStats(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('getFinanceSummary', () => {
    it('should return finance summary for RW (Success Path)', async () => {
      req.user = { role: 'RW', rw_id: 1 };
      const mockData = { total_pemasukan: 1000 };
      financeRepository.getFinanceSummaryForRW.mockResolvedValue(mockData);

      await dashboardController.getFinanceSummary(req, res, next);

      expect(financeRepository.getFinanceSummaryForRW).toHaveBeenCalledWith(1);
      expect(successResponse).toHaveBeenCalledWith(res, 'Finance summary', mockData);
    });

    it('should return finance summary for RT (Success Path)', async () => {
      req.user = { role: 'RT', rt_id: 1 };
      const mockData = { total_pemasukan: 500 };
      financeRepository.getFinanceSummaryForRT.mockResolvedValue(mockData);

      await dashboardController.getFinanceSummary(req, res, next);

      expect(financeRepository.getFinanceSummaryForRT).toHaveBeenCalledWith(1);
      expect(successResponse).toHaveBeenCalledWith(res, 'Finance summary', mockData);
    });

    it('should return finance summary for WARGA (Success Path)', async () => {
      req.user = { role: 'WARGA', id: 1 };
      const mockData = { tagihan_bulanan: 100 };
      financeRepository.getFinanceSummaryForWarga.mockResolvedValue(mockData);

      await dashboardController.getFinanceSummary(req, res, next);

      expect(financeRepository.getFinanceSummaryForWarga).toHaveBeenCalledWith(1);
      expect(successResponse).toHaveBeenCalledWith(res, 'Finance summary', mockData);
    });

    it('should call next on error (Negative Path)', async () => {
      req.user = { role: 'RW', rw_id: 1 };
      const error = new Error('DB Error');
      financeRepository.getFinanceSummaryForRW.mockRejectedValue(error);

      await dashboardController.getFinanceSummary(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('scanReceipt', () => {
    it('should scan receipt and return guessed amount (Success Path)', async () => {
      req.file = { buffer: Buffer.from('mock image') };
      const mockTesseractResult = { data: { text: 'Total: Rp 150.000,00' } };
      Tesseract.recognize.mockResolvedValue(mockTesseractResult);

      await dashboardController.scanReceipt(req, res, next);

      expect(Tesseract.recognize).toHaveBeenCalledWith(req.file.buffer, 'ind', expect.any(Object));
      expect(successResponse).toHaveBeenCalledWith(res, 'Receipt scanned successfully', {
        amount: 15000000,
        rawText: 'Total: Rp 150.000,00'
      });
    });

    it('should return 400 if no file is provided (Negative Path)', async () => {
      req.file = null;

      await dashboardController.scanReceipt(req, res, next);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ success: false, message: 'No image uploaded' });
    });

    it('should return 500 if tesseract fails (Negative Path)', async () => {
      req.file = { buffer: Buffer.from('mock image') };
      const error = new Error('OCR Error');
      Tesseract.recognize.mockRejectedValue(error);

      // We should mock console.error to avoid noise in test output
      jest.spyOn(console, 'error').mockImplementation(() => {});

      await dashboardController.scanReceipt(req, res, next);

      expect(res.status).toHaveBeenCalledWith(500);
      expect(res.json).toHaveBeenCalledWith({ success: false, message: 'Failed to process image' });
      
      console.error.mockRestore();
    });
  });
});
