const familiesController = require('../../../backend/src/controllers/families.controller');
const familyService = require('../../../backend/src/services/family.service');
const { successResponse, createdResponse, validationErrorResponse, notFoundResponse } = require('../../../backend/src/utils/response');

jest.mock('../../../backend/src/services/family.service');
jest.mock('../../../backend/src/utils/response');

describe('Families Controller', () => {
  let req, res, next;

  beforeEach(() => {
    req = {
      user: { id: 1, role: 'RT', rt_id: 5 },
      query: {},
      body: {},
      params: {},
      files: undefined
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
    next = jest.fn();
    jest.clearAllMocks();
  });

  describe('getMyFamily', () => {
    it('should return family details for the authenticated user (Success Path)', async () => {
      req.user = { id: 10, role: 'WARGA' };
      const mockFamily = { id: 1, no_kk: '3201234567890001', kepala_keluarga_nama: 'Ahmad' };
      familyService.getMyFamily.mockResolvedValue(mockFamily);

      await familiesController.getMyFamily(req, res, next);

      expect(familyService.getMyFamily).toHaveBeenCalledWith(10);
      expect(successResponse).toHaveBeenCalledWith(res, 'Data keluarga', mockFamily);
    });

    it('should return notFoundResponse if family is not found (Negative Path)', async () => {
      req.user = { id: 10 };
      const error = new Error('Keluarga tidak ditemukan');
      familyService.getMyFamily.mockRejectedValue(error);

      await familiesController.getMyFamily(req, res, next);

      expect(notFoundResponse).toHaveBeenCalledWith(res, 'Keluarga tidak ditemukan');
    });

    it('should call next on generic error in getMyFamily (Negative Path)', async () => {
      req.user = { id: 10 };
      const error = new Error('Database disconnected');
      familyService.getMyFamily.mockRejectedValue(error);

      await familiesController.getMyFamily(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('createFamily', () => {
    it('should register a family without document uploads (Success Path)', async () => {
      req.user = { id: 10 };
      req.body = {
        rt_id: 5,
        no_kk: '3201234567890001',
        tipe_warga: 'TETAP',
        status_tinggal: 'RUMAH_SENDIRI',
        status_pernikahan: 'MENIKAH'
      };
      const mockCreated = { id: 1, user_id: 10, ...req.body, documents: [] };
      familyService.createFamily.mockResolvedValue(mockCreated);

      await familiesController.createFamily(req, res, next);

      expect(familyService.createFamily).toHaveBeenCalledWith(10, {
        ...req.body,
        documents: []
      });
      expect(createdResponse).toHaveBeenCalledWith(res, 'Keluarga berhasil didaftarkan', mockCreated);
    });

    it('should register a family with document uploads (Success Path)', async () => {
      req.user = { id: 10 };
      req.body = {
        rt_id: 5,
        no_kk: '3201234567890001',
        tipe_warga: 'TETAP',
        status_tinggal: 'RUMAH_SENDIRI',
        status_pernikahan: 'MENIKAH'
      };
      req.files = [
        { filename: 'kk_scan.pdf' },
        { filename: 'ktp_scan.jpg' }
      ];
      const expectedDocuments = [
        { jenis_dokumen: 'KK/KTP', file_url: '/uploads/documents/kk_scan.pdf' },
        { jenis_dokumen: 'KK/KTP', file_url: '/uploads/documents/ktp_scan.jpg' }
      ];
      const mockCreated = { id: 1, user_id: 10, ...req.body, documents: expectedDocuments };
      familyService.createFamily.mockResolvedValue(mockCreated);

      await familiesController.createFamily(req, res, next);

      expect(familyService.createFamily).toHaveBeenCalledWith(10, {
        ...req.body,
        documents: expectedDocuments
      });
      expect(createdResponse).toHaveBeenCalledWith(res, 'Keluarga berhasil didaftarkan', mockCreated);
    });

    it('should return validation error if data is incomplete (Negative Path)', async () => {
      req.user = { id: 10 };
      req.body = { rt_id: 5 };
      const error = new Error('Data keluarga tidak lengkap');
      familyService.createFamily.mockRejectedValue(error);

      await familiesController.createFamily(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Data keluarga tidak lengkap');
    });

    it('should return validation error if KK is already registered (Negative Path)', async () => {
      req.user = { id: 10 };
      req.body = { no_kk: '3201234567890001' };
      const error = new Error('Nomor KK sudah terdaftar');
      familyService.createFamily.mockRejectedValue(error);

      await familiesController.createFamily(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Nomor KK sudah terdaftar');
    });

    it('should call next on generic error during createFamily (Negative Path)', async () => {
      req.user = { id: 10 };
      const error = new Error('Database write error');
      familyService.createFamily.mockRejectedValue(error);

      await familiesController.createFamily(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('getFamiliesByRT', () => {
    it('should return families for RT with pagination (Success Path)', async () => {
      req.query = { page: '1', limit: '10' };
      const mockResult = {
        data: [{ id: 1, no_kk: '3201234567890001' }],
        total: 1
      };
      familyService.getFamiliesByRT.mockResolvedValue(mockResult);

      await familiesController.getFamiliesByRT(req, res, next);

      expect(familyService.getFamiliesByRT).toHaveBeenCalledWith(5, '1', '10');
      expect(successResponse).toHaveBeenCalledWith(
        res,
        'Daftar keluarga',
        expect.objectContaining({
          families: mockResult.data,
          pagination: expect.any(Object)
        })
      );
    });

    it('should call next if getFamiliesByRT fails (Negative Path)', async () => {
      const error = new Error('Failed to retrieve families');
      familyService.getFamiliesByRT.mockRejectedValue(error);

      await familiesController.getFamiliesByRT(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('verifyFamily', () => {
    it('should approve family verification (Success Path)', async () => {
      req.params.id = '1';
      req.body = { status: 'APPROVED' };
      const mockFamily = { id: 1, status_verifikasi: 'APPROVED' };
      familyService.verifyFamily.mockResolvedValue(mockFamily);

      await familiesController.verifyFamily(req, res, next);

      expect(familyService.verifyFamily).toHaveBeenCalledWith('1', 'APPROVED');
      expect(successResponse).toHaveBeenCalledWith(res, 'Keluarga berhasil disetuju', mockFamily);
    });

    it('should reject family verification (Success Path)', async () => {
      req.params.id = '1';
      req.body = { status: 'REJECTED' };
      const mockFamily = { id: 1, status_verifikasi: 'REJECTED' };
      familyService.verifyFamily.mockResolvedValue(mockFamily);

      await familiesController.verifyFamily(req, res, next);

      expect(familyService.verifyFamily).toHaveBeenCalledWith('1', 'REJECTED');
      expect(successResponse).toHaveBeenCalledWith(res, 'Keluarga berhasil ditolak', mockFamily);
    });

    it('should return validation error if status is invalid (Negative Path)', async () => {
      req.params.id = '1';
      req.body = { status: 'PENDING' };
      const error = new Error('Status tidak valid');
      familyService.verifyFamily.mockRejectedValue(error);

      await familiesController.verifyFamily(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Status tidak valid');
    });

    it('should return notFoundResponse if family is not found (Negative Path)', async () => {
      req.params.id = '999';
      req.body = { status: 'APPROVED' };
      const error = new Error('Keluarga tidak ditemukan');
      familyService.verifyFamily.mockRejectedValue(error);

      await familiesController.verifyFamily(req, res, next);

      expect(notFoundResponse).toHaveBeenCalledWith(res, 'Keluarga tidak ditemukan');
    });

    it('should call next on generic error during verifyFamily (Negative Path)', async () => {
      req.params.id = '1';
      const error = new Error('Server error');
      familyService.verifyFamily.mockRejectedValue(error);

      await familiesController.verifyFamily(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });
});
