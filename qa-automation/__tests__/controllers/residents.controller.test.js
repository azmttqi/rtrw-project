const residentsController = require('../../../backend/src/controllers/residents.controller');
const residentService = require('../../../backend/src/services/resident.service');
const { successResponse, createdResponse, validationErrorResponse, notFoundResponse } = require('../../../backend/src/utils/response');

jest.mock('../../../backend/src/services/resident.service');
jest.mock('../../../backend/src/utils/response');

describe('Residents Controller', () => {
  let req, res, next;

  beforeEach(() => {
    req = {
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

  describe('getResidentsByFamily', () => {
    it('should return residents by family id (Success Path)', async () => {
      req.query.family_id = '1';
      const mockResidents = [{ id: 1, nama_lengkap: 'Budi' }];
      residentService.getResidentsByFamily.mockResolvedValue(mockResidents);

      await residentsController.getResidentsByFamily(req, res, next);

      expect(residentService.getResidentsByFamily).toHaveBeenCalledWith('1');
      expect(successResponse).toHaveBeenCalledWith(res, 'Daftar anggota keluarga', mockResidents);
    });

    it('should return validation error if family_id is missing (Negative Path)', async () => {
      const error = new Error('Family ID diperlukan');
      residentService.getResidentsByFamily.mockRejectedValue(error);

      await residentsController.getResidentsByFamily(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Family ID diperlukan');
      expect(next).not.toHaveBeenCalled();
    });

    it('should call next with generic error (Negative Path)', async () => {
      const error = new Error('Database Error');
      residentService.getResidentsByFamily.mockRejectedValue(error);

      await residentsController.getResidentsByFamily(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('addResident', () => {
    it('should create resident and return 201 (Success Path)', async () => {
      req.body = { family_id: '1', nik: '123', nama_lengkap: 'Budi' };
      const mockResident = { id: 1, ...req.body };
      residentService.addResident.mockResolvedValue(mockResident);

      await residentsController.addResident(req, res, next);

      expect(residentService.addResident).toHaveBeenCalledWith(req.body);
      expect(createdResponse).toHaveBeenCalledWith(res, 'Anggota keluarga ditambahkan', mockResident);
    });

    it('should return validation error if data is incomplete (Negative Path)', async () => {
      const error = new Error('Data anggota keluarga tidak lengkap');
      residentService.addResident.mockRejectedValue(error);

      await residentsController.addResident(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Data anggota keluarga tidak lengkap');
    });

    it('should return validation error if NIK is registered (Negative Path)', async () => {
      const error = new Error('NIK sudah terdaftar');
      residentService.addResident.mockRejectedValue(error);

      await residentsController.addResident(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'NIK sudah terdaftar');
    });

    it('should call next with generic error (Negative Path)', async () => {
      const error = new Error('Internal Error');
      residentService.addResident.mockRejectedValue(error);

      await residentsController.addResident(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('updateResident', () => {
    it('should update resident and return 200 (Success Path)', async () => {
      req.params.id = '1';
      req.body = { nik: '1234', nama_lengkap: 'Budi Edit' };
      const mockResident = { id: 1, ...req.body };
      residentService.updateResident.mockResolvedValue(mockResident);

      await residentsController.updateResident(req, res, next);

      expect(residentService.updateResident).toHaveBeenCalledWith('1', req.body);
      expect(successResponse).toHaveBeenCalledWith(res, 'Anggota keluarga diperbarui', mockResident);
    });

    it('should return not found if resident not found (Negative Path)', async () => {
      const error = new Error('Anggota keluarga tidak ditemukan');
      req.params.id = '999';
      residentService.updateResident.mockRejectedValue(error);

      await residentsController.updateResident(req, res, next);

      expect(notFoundResponse).toHaveBeenCalledWith(res, 'Anggota keluarga tidak ditemukan');
    });

    it('should call next with generic error (Negative Path)', async () => {
      const error = new Error('Some error');
      residentService.updateResident.mockRejectedValue(error);

      await residentsController.updateResident(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('deleteResident', () => {
    it('should delete resident and return 200 (Success Path)', async () => {
      req.params.id = '1';
      const mockResident = { id: 1, nama_lengkap: 'Budi' };
      residentService.deleteResident.mockResolvedValue(mockResident);

      await residentsController.deleteResident(req, res, next);

      expect(residentService.deleteResident).toHaveBeenCalledWith('1');
      expect(successResponse).toHaveBeenCalledWith(res, 'Anggota keluarga dihapus', mockResident);
    });

    it('should return not found if resident not found (Negative Path)', async () => {
      const error = new Error('Anggota keluarga tidak ditemukan');
      req.params.id = '999';
      residentService.deleteResident.mockRejectedValue(error);

      await residentsController.deleteResident(req, res, next);

      expect(notFoundResponse).toHaveBeenCalledWith(res, 'Anggota keluarga tidak ditemukan');
    });

    it('should call next with generic error (Negative Path)', async () => {
      const error = new Error('Delete failed');
      residentService.deleteResident.mockRejectedValue(error);

      await residentsController.deleteResident(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });
});
