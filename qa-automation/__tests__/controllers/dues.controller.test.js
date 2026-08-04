const duesController = require('../../../backend/src/controllers/dues.controller');
const dueService = require('../../../backend/src/services/due.service');
const familyRepository = require('../../../backend/src/repositories/family.repository');
const { successResponse, createdResponse, validationErrorResponse, notFoundResponse } = require('../../../backend/src/utils/response');

jest.mock('../../../backend/src/services/due.service');
jest.mock('../../../backend/src/repositories/family.repository');
jest.mock('../../../backend/src/utils/response');

describe('Dues Controller', () => {
  let req, res, next;

  beforeEach(() => {
    req = {
      user: { id: 1, role: 'RT', rt_id: 5, rw_id: 10 },
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

  describe('getSettings', () => {
    it('should get settings for WARGA level with rt_id (Success Path)', async () => {
      req.query.tingkat = 'WARGA';
      const mockSettings = [{ id: 1, tingkat: 'WARGA', nominal: 50000 }];
      dueService.getSettingsByRT.mockResolvedValue(mockSettings);

      await duesController.getSettings(req, res, next);

      expect(dueService.getSettingsByRT).toHaveBeenCalledWith(5);
      expect(successResponse).toHaveBeenCalledWith(res, 'Pengaturan Iuran', mockSettings);
    });

    it('should get settings for RT level with rw_id (Success Path)', async () => {
      req.query.tingkat = 'RT';
      const mockSettings = [{ id: 2, tingkat: 'RT', nominal: 200000 }];
      dueService.getSettingsByRW.mockResolvedValue(mockSettings);

      await duesController.getSettings(req, res, next);

      expect(dueService.getSettingsByRW).toHaveBeenCalledWith(10);
      expect(successResponse).toHaveBeenCalledWith(res, 'Pengaturan Iuran', mockSettings);
    });

    it('should return validation error if tingkat or role is invalid (Negative Path)', async () => {
      req.query.tingkat = 'INVALID_TINGKAT';

      await duesController.getSettings(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Tingkat atau Role tidak sesuai');
    });

    it('should return validation error if service throws required error (Negative Path)', async () => {
      req.query.tingkat = 'WARGA';
      const error = new Error('RT ID diperlukan');
      dueService.getSettingsByRT.mockRejectedValue(error);

      await duesController.getSettings(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'RT ID diperlukan');
    });

    it('should call next on generic error (Negative Path)', async () => {
      req.query.tingkat = 'WARGA';
      const error = new Error('Database error');
      dueService.getSettingsByRT.mockRejectedValue(error);

      await duesController.getSettings(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('createSetting', () => {
    it('should create setting for WARGA by RT (Success Path)', async () => {
      req.body = { tingkat: 'WARGA', nominal: 50000, tenggat_tanggal: 10 };
      const mockCreated = { id: 1, rt_id: 5, ...req.body };
      dueService.createSetting.mockResolvedValue(mockCreated);

      await duesController.createSetting(req, res, next);

      expect(dueService.createSetting).toHaveBeenCalledWith({
        tingkat: 'WARGA',
        rt_id: 5,
        rw_id: null,
        nominal: 50000,
        tenggat_tanggal: 10
      });
      expect(createdResponse).toHaveBeenCalledWith(res, 'Pengaturan iuran berhasil disimpan', mockCreated);
    });

    it('should create setting for RT by RW (Success Path)', async () => {
      req.user = { id: 2, role: 'RW', rw_id: 10 };
      req.body = { tingkat: 'RT', nominal: 250000, tenggat_tanggal: 5 };
      const mockCreated = { id: 2, rw_id: 10, ...req.body };
      dueService.createSetting.mockResolvedValue(mockCreated);

      await duesController.createSetting(req, res, next);

      expect(dueService.createSetting).toHaveBeenCalledWith({
        tingkat: 'RT',
        rt_id: null,
        rw_id: 10,
        nominal: 250000,
        tenggat_tanggal: 5
      });
      expect(createdResponse).toHaveBeenCalledWith(res, 'Pengaturan iuran berhasil disimpan', mockCreated);
    });

    it('should return validation error if data is incomplete (Negative Path)', async () => {
      req.body = { tingkat: 'WARGA' };
      const error = new Error('Data tidak lengkap');
      dueService.createSetting.mockRejectedValue(error);

      await duesController.createSetting(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Data tidak lengkap');
    });

    it('should call next on generic error during createSetting (Negative Path)', async () => {
      req.body = { tingkat: 'WARGA', nominal: 50000, tenggat_tanggal: 10 };
      const error = new Error('Database failure');
      dueService.createSetting.mockRejectedValue(error);

      await duesController.createSetting(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('createBill', () => {
    it('should create a due bill successfully (Success Path)', async () => {
      req.body = { family_id: 1, bulan: 8, tahun: 2026, nominal: 50000 };
      const mockBill = { id: 10, ...req.body };
      dueService.createBill.mockResolvedValue(mockBill);

      await duesController.createBill(req, res, next);

      expect(dueService.createBill).toHaveBeenCalledWith(req.body);
      expect(createdResponse).toHaveBeenCalledWith(res, 'Tagihan berhasil dibuat', mockBill);
    });

    it('should return validation error if bill already exists or incomplete (Negative Path)', async () => {
      req.body = { family_id: 1, bulan: 8, tahun: 2026, nominal: 50000 };
      const error = new Error('Tagihan untuk periode ini sudah ada');
      dueService.createBill.mockRejectedValue(error);

      await duesController.createBill(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Tagihan untuk periode ini sudah ada');
    });

    it('should call next on generic error (Negative Path)', async () => {
      req.body = { family_id: 1, bulan: 8, tahun: 2026, nominal: 50000 };
      const error = new Error('System error');
      dueService.createBill.mockRejectedValue(error);

      await duesController.createBill(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('getBillsByRT', () => {
    it('should return list of bills for RT (Success Path)', async () => {
      req.query = { page: '1', limit: '10' };
      const mockResult = {
        data: [{ id: 1, bulan: 8, tahun: 2026, nominal: 50000 }],
        total: 1
      };
      dueService.getBillsByRT.mockResolvedValue(mockResult);

      await duesController.getBillsByRT(req, res, next);

      expect(dueService.getBillsByRT).toHaveBeenCalledWith(5, '1', '10');
      expect(successResponse).toHaveBeenCalledWith(
        res,
        'Daftar Tagihan',
        expect.objectContaining({
          bills: mockResult.data,
          pagination: expect.any(Object)
        })
      );
    });

    it('should call next if getBillsByRT fails (Negative Path)', async () => {
      const error = new Error('Fetch bills failed');
      dueService.getBillsByRT.mockRejectedValue(error);

      await duesController.getBillsByRT(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('getDueHistory', () => {
    it('should return mapped history for citizen family (Success Path)', async () => {
      req.user = { id: 5, role: 'WARGA' };
      familyRepository.findByUserId.mockResolvedValue({ id: 2, no_kk: '1234567890' });
      const mockHistory = [
        { id: 1, bulan: 1, tahun: 2026, jumlah: '50000', bill_status: 'APPROVED', tanggal_bayar: '2026-01-05' },
        { id: 2, bulan: 2, tahun: 2026, jumlah: '50000', payment_status: 'PENDING', tanggal_bayar: null },
        { id: 3, bulan: 3, tahun: 2026, jumlah: '50000', bill_status: 'UNPAID', payment_status: null, tanggal_bayar: null }
      ];
      dueService.getDueHistoryByFamily.mockResolvedValue(mockHistory);

      await duesController.getDueHistory(req, res, next);

      expect(familyRepository.findByUserId).toHaveBeenCalledWith(5);
      expect(dueService.getDueHistoryByFamily).toHaveBeenCalledWith(2);
      expect(successResponse).toHaveBeenCalledWith(res, 'Riwayat Iuran', [
        { id: 1, bulan: 'Januari', tahun: 2026, jumlah: 50000, status: 'LUNAS', tanggal_bayar: '2026-01-05' },
        { id: 2, bulan: 'Februari', tahun: 2026, jumlah: 50000, status: 'PENDING', tanggal_bayar: null },
        { id: 3, bulan: 'Maret', tahun: 2026, jumlah: 50000, status: 'BELUM_BAYAR', tanggal_bayar: null }
      ]);
    });

    it('should return notFoundResponse if family is not found for user (Negative Path)', async () => {
      req.user = { id: 5 };
      familyRepository.findByUserId.mockResolvedValue(null);

      await duesController.getDueHistory(req, res, next);

      expect(notFoundResponse).toHaveBeenCalledWith(res, 'Data keluarga tidak ditemukan');
    });

    it('should call next on generic error (Negative Path)', async () => {
      req.user = { id: 5 };
      familyRepository.findByUserId.mockRejectedValue(new Error('DB Error'));

      await duesController.getDueHistory(req, res, next);

      expect(next).toHaveBeenCalledWith(expect.any(Error));
    });
  });

  describe('createPayment', () => {
    it('should create payment for Warga/Family head (Success Path)', async () => {
      req.user = { id: 5, role: 'WARGA' };
      familyRepository.findByUserId.mockResolvedValue({ id: 3 });
      req.body = {
        bulan: 8,
        tahun: 2026,
        nominal: 50000,
        metode_bayar: 'TRANSFER',
        bukti_bayar_url: 'http://example.com/receipt.jpg'
      };
      const mockPayment = { id: 100, ...req.body, pembayar_family_id: 3, pembayar_rt_id: null };
      dueService.createPayment.mockResolvedValue(mockPayment);

      await duesController.createPayment(req, res, next);

      expect(dueService.createPayment).toHaveBeenCalledWith({
        pembayar_family_id: 3,
        pembayar_rt_id: null,
        ...req.body
      });
      expect(createdResponse).toHaveBeenCalledWith(res, 'Pembayaran berhasil disubmit', mockPayment);
    });

    it('should create payment for RT user paying to RW (Success Path)', async () => {
      req.user = { id: 2, role: 'RT', rt_id: 5 };
      familyRepository.findByUserId.mockResolvedValue(null);
      req.body = {
        bulan: 8,
        tahun: 2026,
        nominal: 200000,
        metode_bayar: 'TRANSFER',
        bukti_bayar_url: 'http://example.com/receipt_rt.jpg'
      };
      const mockPayment = { id: 101, ...req.body, pembayar_family_id: null, pembayar_rt_id: 5 };
      dueService.createPayment.mockResolvedValue(mockPayment);

      await duesController.createPayment(req, res, next);

      expect(dueService.createPayment).toHaveBeenCalledWith({
        pembayar_family_id: null,
        pembayar_rt_id: 5,
        ...req.body
      });
      expect(createdResponse).toHaveBeenCalledWith(res, 'Pembayaran berhasil disubmit', mockPayment);
    });

    it('should return validation error if user is neither family nor RT (Negative Path)', async () => {
      req.user = { id: 99, role: 'ADMIN' };
      familyRepository.findByUserId.mockResolvedValue(null);

      await duesController.createPayment(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Akses ditolak: User bukan kepala keluarga');
    });

    it('should return validation error if payment data is incomplete (Negative Path)', async () => {
      req.user = { id: 5, role: 'WARGA' };
      familyRepository.findByUserId.mockResolvedValue({ id: 3 });
      req.body = { nominal: 50000 };
      const error = new Error('Data pembayaran tidak lengkap');
      dueService.createPayment.mockRejectedValue(error);

      await duesController.createPayment(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Data pembayaran tidak lengkap');
    });

    it('should call next on generic error during createPayment (Negative Path)', async () => {
      req.user = { id: 5, role: 'WARGA' };
      familyRepository.findByUserId.mockResolvedValue({ id: 3 });
      const error = new Error('Payment gateway error');
      dueService.createPayment.mockRejectedValue(error);

      await duesController.createPayment(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('getPaymentsByRT', () => {
    it('should get payments list for RT (Success Path)', async () => {
      req.query = { page: '1', limit: '10' };
      const mockResult = {
        data: [{ id: 1, nominal: 50000, status: 'PENDING' }],
        total: 1
      };
      dueService.getPaymentsByRT.mockResolvedValue(mockResult);

      await duesController.getPaymentsByRT(req, res, next);

      expect(dueService.getPaymentsByRT).toHaveBeenCalledWith(5, '1', '10');
      expect(successResponse).toHaveBeenCalledWith(
        res,
        'Daftar Pembayaran',
        expect.objectContaining({
          payments: mockResult.data,
          pagination: expect.any(Object)
        })
      );
    });

    it('should call next on error in getPaymentsByRT (Negative Path)', async () => {
      const error = new Error('Query error');
      dueService.getPaymentsByRT.mockRejectedValue(error);

      await duesController.getPaymentsByRT(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('verifyPayment', () => {
    it('should verify payment as APPROVED (Success Path)', async () => {
      req.params.id = '10';
      req.body.status = 'APPROVED';
      const mockVerified = { id: 10, status: 'APPROVED' };
      dueService.verifyPayment.mockResolvedValue(mockVerified);

      await duesController.verifyPayment(req, res, next);

      expect(dueService.verifyPayment).toHaveBeenCalledWith('10', 'APPROVED');
      expect(successResponse).toHaveBeenCalledWith(res, 'Pembayaran berhasil disetuju', mockVerified);
    });

    it('should verify payment as REJECTED (Success Path)', async () => {
      req.params.id = '10';
      req.body.status = 'REJECTED';
      const mockVerified = { id: 10, status: 'REJECTED' };
      dueService.verifyPayment.mockResolvedValue(mockVerified);

      await duesController.verifyPayment(req, res, next);

      expect(dueService.verifyPayment).toHaveBeenCalledWith('10', 'REJECTED');
      expect(successResponse).toHaveBeenCalledWith(res, 'Pembayaran berhasil ditolak', mockVerified);
    });

    it('should return validation error if status is not valid (Negative Path)', async () => {
      req.params.id = '10';
      req.body.status = 'UNKNOWN';
      const error = new Error('Status pembayaran tidak valid');
      dueService.verifyPayment.mockRejectedValue(error);

      await duesController.verifyPayment(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Status pembayaran tidak valid');
    });

    it('should return notFoundResponse if payment not found (Negative Path)', async () => {
      req.params.id = '999';
      req.body.status = 'APPROVED';
      const error = new Error('Pembayaran tidak ditemukan');
      dueService.verifyPayment.mockRejectedValue(error);

      await duesController.verifyPayment(req, res, next);

      expect(notFoundResponse).toHaveBeenCalledWith(res, 'Pembayaran tidak ditemukan');
    });

    it('should call next on generic error during verifyPayment (Negative Path)', async () => {
      req.params.id = '10';
      const error = new Error('DB write failed');
      dueService.verifyPayment.mockRejectedValue(error);

      await duesController.verifyPayment(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('sendManualReminder', () => {
    it('should send manual reminder successfully (Success Path)', async () => {
      req.params.id = '10';
      dueService.sendManualReminder.mockResolvedValue(true);

      await duesController.sendManualReminder(req, res, next);

      expect(dueService.sendManualReminder).toHaveBeenCalledWith('10');
      expect(successResponse).toHaveBeenCalledWith(res, 'Pengingat WhatsApp berhasil dikirim');
    });

    it('should return notFoundResponse if bill not found (Negative Path)', async () => {
      req.params.id = '999';
      const error = new Error('Tagihan tidak ditemukan');
      dueService.sendManualReminder.mockRejectedValue(error);

      await duesController.sendManualReminder(req, res, next);

      expect(notFoundResponse).toHaveBeenCalledWith(res, 'Tagihan tidak ditemukan');
    });

    it('should return validation error if bill is already paid (Negative Path)', async () => {
      req.params.id = '10';
      const error = new Error('Tagihan sudah lunas');
      dueService.sendManualReminder.mockRejectedValue(error);

      await duesController.sendManualReminder(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Tagihan sudah lunas');
    });

    it('should call next on generic error during sendManualReminder (Negative Path)', async () => {
      req.params.id = '10';
      const error = new Error('WhatsApp service down');
      dueService.sendManualReminder.mockRejectedValue(error);

      await duesController.sendManualReminder(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });
});
