const duesController = require('../../../backend/src/controllers/dues.controller');
const dueService = require('../../../backend/src/services/due.service');
const familyRepository = require('../../../backend/src/repositories/family.repository');
const { successResponse, createdResponse, validationErrorResponse, notFoundResponse } = require('../../../backend/src/utils/response');
const { getPaginationMeta } = require('../../../backend/src/utils/pagination');

jest.mock('../../../backend/src/services/due.service');
jest.mock('../../../backend/src/repositories/family.repository');
jest.mock('../../../backend/src/utils/response');
jest.mock('../../../backend/src/utils/pagination');

describe('Dues Controller', () => {
  let req, res, next;

  beforeEach(() => {
    req = {
      query: {},
      body: {},
      params: {},
      user: {}
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
    next = jest.fn();
    jest.clearAllMocks();
  });

  describe('getSettings', () => {
    it('should return settings for WARGA (Success Path)', async () => {
      req.query.tingkat = 'WARGA';
      req.user = { rt_id: 1 };
      const mockSettings = [{ id: 1 }];
      dueService.getSettingsByRT.mockResolvedValue(mockSettings);

      await duesController.getSettings(req, res, next);

      expect(dueService.getSettingsByRT).toHaveBeenCalledWith(1);
      expect(successResponse).toHaveBeenCalledWith(res, 'Pengaturan Iuran', mockSettings);
    });

    it('should return settings for RT (Success Path)', async () => {
      req.query.tingkat = 'RT';
      req.user = { rw_id: 1 };
      const mockSettings = [{ id: 2 }];
      dueService.getSettingsByRW.mockResolvedValue(mockSettings);

      await duesController.getSettings(req, res, next);

      expect(dueService.getSettingsByRW).toHaveBeenCalledWith(1);
      expect(successResponse).toHaveBeenCalledWith(res, 'Pengaturan Iuran', mockSettings);
    });

    it('should return validation error for invalid tingkat (Negative Path)', async () => {
      req.query.tingkat = 'INVALID';
      
      await duesController.getSettings(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Tingkat atau Role tidak sesuai');
    });

    it('should call next on generic error (Negative Path)', async () => {
      req.query.tingkat = 'WARGA';
      req.user = { rt_id: 1 };
      const error = new Error('DB Error');
      dueService.getSettingsByRT.mockRejectedValue(error);

      await duesController.getSettings(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('createSetting', () => {
    it('should create setting and return 201 (Success Path)', async () => {
      req.body = { tingkat: 'WARGA', nominal: 50000, tenggat_tanggal: 10 };
      req.user = { rt_id: 1 };
      const mockSetting = { id: 1, ...req.body };
      dueService.createSetting.mockResolvedValue(mockSetting);

      await duesController.createSetting(req, res, next);

      expect(dueService.createSetting).toHaveBeenCalledWith({
        tingkat: 'WARGA', rt_id: 1, rw_id: null, nominal: 50000, tenggat_tanggal: 10
      });
      expect(createdResponse).toHaveBeenCalledWith(res, 'Pengaturan iuran berhasil disimpan', mockSetting);
    });

    it('should handle validation errors (Negative Path)', async () => {
      req.body = { tingkat: 'WARGA' };
      req.user = { rt_id: 1 };
      const error = new Error('Data tidak lengkap');
      dueService.createSetting.mockRejectedValue(error);

      await duesController.createSetting(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Data tidak lengkap');
    });
  });

  describe('createBill', () => {
    it('should create bill and return 201 (Success Path)', async () => {
      req.body = { family_id: 1, bulan: 1, tahun: 2024, nominal: 50000 };
      const mockBill = { id: 1, ...req.body };
      dueService.createBill.mockResolvedValue(mockBill);

      await duesController.createBill(req, res, next);

      expect(dueService.createBill).toHaveBeenCalledWith(req.body);
      expect(createdResponse).toHaveBeenCalledWith(res, 'Tagihan berhasil dibuat', mockBill);
    });

    it('should handle validation errors (Negative Path)', async () => {
      req.body = { family_id: 1 };
      const error = new Error('Tagihan sudah ada');
      dueService.createBill.mockRejectedValue(error);

      await duesController.createBill(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Tagihan sudah ada');
    });
  });

  describe('getBillsByRT', () => {
    it('should return bills (Success Path)', async () => {
      req.query = { page: 1, limit: 10 };
      req.user = { rt_id: 1 };
      const mockResult = { data: [{ id: 1 }], total: 1 };
      dueService.getBillsByRT.mockResolvedValue(mockResult);
      getPaginationMeta.mockReturnValue({ page: 1, limit: 10, total: 1, totalPages: 1 });

      await duesController.getBillsByRT(req, res, next);

      expect(dueService.getBillsByRT).toHaveBeenCalledWith(1, 1, 10);
      expect(successResponse).toHaveBeenCalledWith(res, 'Daftar Tagihan', {
        bills: mockResult.data,
        pagination: { page: 1, limit: 10, total: 1, totalPages: 1 }
      });
    });
  });

  describe('getDueHistory', () => {
    it('should return due history (Success Path)', async () => {
      req.user = { id: 1 };
      familyRepository.findByUserId.mockResolvedValue({ id: 1 });
      const mockHistory = [
        { id: 1, bulan: 1, tahun: 2024, jumlah: '50000', bill_status: 'APPROVED', payment_status: 'APPROVED', tanggal_bayar: '2024-01-01' },
        { id: 2, bulan: 2, tahun: 2024, jumlah: '50000', bill_status: 'PENDING', payment_status: 'PENDING', tanggal_bayar: null }
      ];
      dueService.getDueHistoryByFamily.mockResolvedValue(mockHistory);

      await duesController.getDueHistory(req, res, next);

      expect(familyRepository.findByUserId).toHaveBeenCalledWith(1);
      expect(dueService.getDueHistoryByFamily).toHaveBeenCalledWith(1);
      expect(successResponse).toHaveBeenCalledWith(res, 'Riwayat Iuran', [
        { id: 1, bulan: 'Januari', tahun: 2024, jumlah: 50000, status: 'LUNAS', tanggal_bayar: '2024-01-01' },
        { id: 2, bulan: 'Februari', tahun: 2024, jumlah: 50000, status: 'PENDING', tanggal_bayar: null }
      ]);
    });

    it('should return 404 if family not found (Negative Path)', async () => {
      req.user = { id: 1 };
      familyRepository.findByUserId.mockResolvedValue(null);

      await duesController.getDueHistory(req, res, next);

      expect(notFoundResponse).toHaveBeenCalledWith(res, 'Data keluarga tidak ditemukan');
    });
  });

  describe('createPayment', () => {
    it('should create payment by WARGA (Success Path)', async () => {
      req.body = { bulan: 1, tahun: 2024, nominal: 50000, metode_bayar: 'TRANSFER' };
      req.user = { id: 1, role: 'WARGA' };
      familyRepository.findByUserId.mockResolvedValue({ id: 1 });
      const mockPayment = { id: 1 };
      dueService.createPayment.mockResolvedValue(mockPayment);

      await duesController.createPayment(req, res, next);

      expect(dueService.createPayment).toHaveBeenCalledWith({
        pembayar_family_id: 1, pembayar_rt_id: null, bulan: 1, tahun: 2024, nominal: 50000, metode_bayar: 'TRANSFER', bukti_bayar_url: undefined
      });
      expect(createdResponse).toHaveBeenCalledWith(res, 'Pembayaran berhasil disubmit', mockPayment);
    });
    
    it('should return validation error if neither family nor RT (Negative Path)', async () => {
      req.user = { id: 1, role: 'ADMIN' };
      familyRepository.findByUserId.mockResolvedValue(null);

      await duesController.createPayment(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Akses ditolak: User bukan kepala keluarga');
    });
  });

  describe('getPaymentsByRT', () => {
    it('should return payments (Success Path)', async () => {
      req.query = { page: 1, limit: 10 };
      req.user = { rt_id: 1 };
      const mockResult = { data: [{ id: 1 }], total: 1 };
      dueService.getPaymentsByRT.mockResolvedValue(mockResult);
      getPaginationMeta.mockReturnValue({ page: 1, limit: 10, total: 1, totalPages: 1 });

      await duesController.getPaymentsByRT(req, res, next);

      expect(dueService.getPaymentsByRT).toHaveBeenCalledWith(1, 1, 10);
      expect(successResponse).toHaveBeenCalledWith(res, 'Daftar Pembayaran', {
        payments: mockResult.data,
        pagination: { page: 1, limit: 10, total: 1, totalPages: 1 }
      });
    });
  });

  describe('verifyPayment', () => {
    it('should verify payment and return 200 (Success Path)', async () => {
      req.params.id = '1';
      req.body = { status: 'APPROVED' };
      dueService.verifyPayment.mockResolvedValue({ id: 1 });

      await duesController.verifyPayment(req, res, next);

      expect(dueService.verifyPayment).toHaveBeenCalledWith('1', 'APPROVED');
      expect(successResponse).toHaveBeenCalledWith(res, 'Pembayaran berhasil disetuju', { id: 1 });
    });

    it('should handle not found error (Negative Path)', async () => {
      req.params.id = '1';
      req.body = { status: 'APPROVED' };
      dueService.verifyPayment.mockRejectedValue(new Error('tidak ditemukan'));

      await duesController.verifyPayment(req, res, next);

      expect(notFoundResponse).toHaveBeenCalledWith(res, 'tidak ditemukan');
    });
  });

  describe('sendManualReminder', () => {
    it('should send reminder and return 200 (Success Path)', async () => {
      req.params.id = '1';
      dueService.sendManualReminder.mockResolvedValue();

      await duesController.sendManualReminder(req, res, next);

      expect(dueService.sendManualReminder).toHaveBeenCalledWith('1');
      expect(successResponse).toHaveBeenCalledWith(res, 'Pengingat WhatsApp berhasil dikirim');
    });

    it('should handle already paid error (Negative Path)', async () => {
      req.params.id = '1';
      dueService.sendManualReminder.mockRejectedValue(new Error('Tagihan sudah lunas'));

      await duesController.sendManualReminder(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Tagihan sudah lunas');
    });
  });
});
