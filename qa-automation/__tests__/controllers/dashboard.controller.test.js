const dashboardController = require('../../../backend/src/controllers/dashboard.controller');
const dashboardService = require('../../../backend/src/services/dashboard.service');
const financeRepository = require('../../../backend/src/repositories/finance.repository');
const { successResponse } = require('../../../backend/src/utils/response');
const Tesseract = require('tesseract.js');

jest.mock('../../../backend/src/services/dashboard.service');
jest.mock('../../../backend/src/repositories/finance.repository');
jest.mock('../../../backend/src/utils/response');
jest.mock('tesseract.js');

describe('Dashboard Controller', () => {
  let req, res, next;

  beforeEach(() => {
    req = {
      user: { id: 1, role: 'RW', rw_id: 10, rt_id: 5 },
      query: {},
      body: {},
      params: {}
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
    next = jest.fn();
    jest.clearAllMocks();
  });

  describe('getStats', () => {
    it('should return dashboard statistics successfully (Success Path)', async () => {
      const mockStats = { totalWarga: 150, totalRT: 5, kasRW: 10000000 };
      dashboardService.getStats.mockResolvedValue(mockStats);

      await dashboardController.getStats(req, res, next);

      expect(dashboardService.getStats).toHaveBeenCalledWith(req.user);
      expect(successResponse).toHaveBeenCalledWith(res, 'Dashboard statistics fetched', mockStats);
    });

    it('should call next on service failure (Negative Path)', async () => {
      const error = new Error('Database stats error');
      dashboardService.getStats.mockRejectedValue(error);

      await dashboardController.getStats(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('getFinanceSummary', () => {
    it('should fetch finance summary for RW role (Success Path)', async () => {
      req.user = { id: 1, role: 'RW', rw_id: 10 };
      const mockFinanceRW = { totalPemasukan: 5000000, totalPengeluaran: 2000000 };
      financeRepository.getFinanceSummaryForRW.mockResolvedValue(mockFinanceRW);

      await dashboardController.getFinanceSummary(req, res, next);

      expect(financeRepository.getFinanceSummaryForRW).toHaveBeenCalledWith(10);
      expect(successResponse).toHaveBeenCalledWith(res, 'Finance summary', mockFinanceRW);
    });

    it('should fetch finance summary for RT role (Success Path)', async () => {
      req.user = { id: 2, role: 'RT', rt_id: 5 };
      const mockFinanceRT = { totalPemasukan: 2000000, totalPengeluaran: 500000 };
      financeRepository.getFinanceSummaryForRT.mockResolvedValue(mockFinanceRT);

      await dashboardController.getFinanceSummary(req, res, next);

      expect(financeRepository.getFinanceSummaryForRT).toHaveBeenCalledWith(5);
      expect(successResponse).toHaveBeenCalledWith(res, 'Finance summary', mockFinanceRT);
    });

    it('should fetch finance summary for WARGA role (Success Path)', async () => {
      req.user = { id: 3, role: 'WARGA' };
      const mockFinanceWarga = { totalTagihan: 50000, statusBayar: 'LUNAS' };
      financeRepository.getFinanceSummaryForWarga.mockResolvedValue(mockFinanceWarga);

      await dashboardController.getFinanceSummary(req, res, next);

      expect(financeRepository.getFinanceSummaryForWarga).toHaveBeenCalledWith(3);
      expect(successResponse).toHaveBeenCalledWith(res, 'Finance summary', mockFinanceWarga);
    });

    it('should call next on repository failure (Negative Path)', async () => {
      req.user = { id: 1, role: 'RW', rw_id: 10 };
      const error = new Error('Query error');
      financeRepository.getFinanceSummaryForRW.mockRejectedValue(error);

      await dashboardController.getFinanceSummary(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('scanReceipt', () => {
    it('should return 400 if no image file is uploaded (Negative Path)', async () => {
      req.file = undefined;

      await dashboardController.scanReceipt(req, res, next);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ success: false, message: 'No image uploaded' });
    });

    it('should extract amount and rawText from receipt image successfully (Success Path)', async () => {
      req.file = { buffer: Buffer.from('fake image content') };
      Tesseract.recognize.mockResolvedValue({
        data: { text: 'STRUK PEMBAYARAN\nTOTAL: Rp 150.000\nTerima Kasih' }
      });

      await dashboardController.scanReceipt(req, res, next);

      expect(Tesseract.recognize).toHaveBeenCalledWith(
        req.file.buffer,
        'ind',
        expect.any(Object)
      );
      expect(successResponse).toHaveBeenCalledWith(res, 'Receipt scanned successfully', {
        amount: 150000,
        rawText: 'STRUK PEMBAYARAN\nTOTAL: Rp 150.000\nTerima Kasih'
      });
    });

    it('should handle text with no numbers matched and set amount to 0 (Success Path)', async () => {
      req.file = { buffer: Buffer.from('fake image content') };
      Tesseract.recognize.mockResolvedValue({
        data: { text: 'STRUK TANPA NOMINAL' }
      });

      await dashboardController.scanReceipt(req, res, next);

      expect(successResponse).toHaveBeenCalledWith(res, 'Receipt scanned successfully', {
        amount: 0,
        rawText: 'STRUK TANPA NOMINAL'
      });
    });

    it('should return 500 when OCR processing fails (Negative Path)', async () => {
      req.file = { buffer: Buffer.from('corrupt image') };
      Tesseract.recognize.mockRejectedValue(new Error('Tesseract failed'));

      await dashboardController.scanReceipt(req, res, next);

      expect(res.status).toHaveBeenCalledWith(500);
      expect(res.json).toHaveBeenCalledWith({ success: false, message: 'Failed to process image' });
    });
  });
});
