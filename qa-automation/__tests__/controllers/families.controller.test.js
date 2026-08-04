const familiesController = require('../../../backend/src/controllers/families.controller');
const familyService = require('../../../backend/src/services/family.service');
const { successResponse, createdResponse, validationErrorResponse, notFoundResponse } = require('../../../backend/src/utils/response');
const { getPaginationMeta } = require('../../../backend/src/utils/pagination');

jest.mock('../../../backend/src/services/family.service');
jest.mock('../../../backend/src/utils/response');
jest.mock('../../../backend/src/utils/pagination');

describe('Families Controller', () => {
  let req, res, next;

  beforeEach(() => {
    req = {
      query: {},
      body: {},
      params: {},
      user: {},
      files: []
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
    next = jest.fn();
    jest.clearAllMocks();
  });

  describe('getMyFamily', () => {
    it('should return family and 200 (Success Path)', async () => {
      req.user = { id: 1 };
      const mockFamily = { id: 1, no_kk: '123' };
      familyService.getMyFamily.mockResolvedValue(mockFamily);

      await familiesController.getMyFamily(req, res, next);

      expect(familyService.getMyFamily).toHaveBeenCalledWith(1);
      expect(successResponse).toHaveBeenCalledWith(res, 'Data keluarga', mockFamily);
    });

    it('should return 404 if family not found (Negative Path)', async () => {
      req.user = { id: 1 };
      familyService.getMyFamily.mockRejectedValue(new Error('Keluarga tidak ditemukan'));

      await familiesController.getMyFamily(req, res, next);

      expect(notFoundResponse).toHaveBeenCalledWith(res, 'Keluarga tidak ditemukan');
    });
    
    it('should call next on generic error (Negative Path)', async () => {
      req.user = { id: 1 };
      const error = new Error('Database Error');
      familyService.getMyFamily.mockRejectedValue(error);

      await familiesController.getMyFamily(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('createFamily', () => {
    it('should create family and return 201 (Success Path)', async () => {
      req.user = { id: 1 };
      req.body = { rt_id: 1, no_kk: '1234567890123456', tipe_warga: 'TETAP', status_tinggal: 'MILIK_SENDIRI', status_pernikahan: 'KAWIN' };
      req.files = [{ filename: 'test.pdf' }];
      const mockFamily = { id: 1, ...req.body };
      familyService.createFamily.mockResolvedValue(mockFamily);

      await familiesController.createFamily(req, res, next);

      expect(familyService.createFamily).toHaveBeenCalledWith(1, {
        ...req.body,
        documents: [{ jenis_dokumen: 'KK/KTP', file_url: '/uploads/documents/test.pdf' }]
      });
      expect(createdResponse).toHaveBeenCalledWith(res, 'Keluarga berhasil didaftarkan', mockFamily);
    });

    it('should handle missing documents (Success Path)', async () => {
      req.user = { id: 1 };
      req.body = { rt_id: 1, no_kk: '1234567890123456', tipe_warga: 'TETAP', status_tinggal: 'MILIK_SENDIRI', status_pernikahan: 'KAWIN' };
      delete req.files; // No files provided
      const mockFamily = { id: 1, ...req.body };
      familyService.createFamily.mockResolvedValue(mockFamily);

      await familiesController.createFamily(req, res, next);

      expect(familyService.createFamily).toHaveBeenCalledWith(1, {
        ...req.body,
        documents: []
      });
      expect(createdResponse).toHaveBeenCalledWith(res, 'Keluarga berhasil didaftarkan', mockFamily);
    });

    it('should return validation error if data incomplete (Negative Path)', async () => {
      req.user = { id: 1 };
      req.body = {};
      familyService.createFamily.mockRejectedValue(new Error('Data keluarga tidak lengkap'));

      await familiesController.createFamily(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Data keluarga tidak lengkap');
    });

    it('should return validation error if KK registered (Negative Path)', async () => {
      req.user = { id: 1 };
      familyService.createFamily.mockRejectedValue(new Error('Nomor KK sudah terdaftar'));

      await familiesController.createFamily(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Nomor KK sudah terdaftar');
    });
  });

  describe('getFamiliesByRT', () => {
    it('should return families (Success Path)', async () => {
      req.query = { page: 1, limit: 10 };
      req.user = { rt_id: 1 };
      const mockResult = { data: [{ id: 1 }], total: 1 };
      familyService.getFamiliesByRT.mockResolvedValue(mockResult);
      getPaginationMeta.mockReturnValue({ page: 1, limit: 10, total: 1, totalPages: 1 });

      await familiesController.getFamiliesByRT(req, res, next);

      expect(familyService.getFamiliesByRT).toHaveBeenCalledWith(1, 1, 10);
      expect(successResponse).toHaveBeenCalledWith(res, 'Daftar keluarga', {
        families: mockResult.data,
        pagination: { page: 1, limit: 10, total: 1, totalPages: 1 }
      });
    });
    
    it('should call next on error (Negative Path)', async () => {
      req.user = { rt_id: 1 };
      const error = new Error('Error');
      familyService.getFamiliesByRT.mockRejectedValue(error);

      await familiesController.getFamiliesByRT(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('verifyFamily', () => {
    it('should verify family and return 200 (Success Path)', async () => {
      req.params.id = '1';
      req.body = { status: 'APPROVED' };
      const mockFamily = { id: 1 };
      familyService.verifyFamily.mockResolvedValue(mockFamily);

      await familiesController.verifyFamily(req, res, next);

      expect(familyService.verifyFamily).toHaveBeenCalledWith('1', 'APPROVED');
      expect(successResponse).toHaveBeenCalledWith(res, 'Keluarga berhasil disetuju', mockFamily);
    });
    
    it('should handle rejection (Success Path)', async () => {
      req.params.id = '1';
      req.body = { status: 'REJECTED' };
      const mockFamily = { id: 1 };
      familyService.verifyFamily.mockResolvedValue(mockFamily);

      await familiesController.verifyFamily(req, res, next);

      expect(familyService.verifyFamily).toHaveBeenCalledWith('1', 'REJECTED');
      expect(successResponse).toHaveBeenCalledWith(res, 'Keluarga berhasil ditolak', mockFamily);
    });

    it('should handle invalid status error (Negative Path)', async () => {
      req.params.id = '1';
      req.body = { status: 'INVALID' };
      familyService.verifyFamily.mockRejectedValue(new Error('Status tidak valid'));

      await familiesController.verifyFamily(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Status tidak valid');
    });

    it('should handle not found error (Negative Path)', async () => {
      req.params.id = '1';
      req.body = { status: 'APPROVED' };
      familyService.verifyFamily.mockRejectedValue(new Error('Keluarga tidak ditemukan'));

      await familiesController.verifyFamily(req, res, next);

      expect(notFoundResponse).toHaveBeenCalledWith(res, 'Keluarga tidak ditemukan');
    });
  });
});
