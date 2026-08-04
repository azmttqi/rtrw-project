const facilitiesController = require('../../../backend/src/controllers/facilities.controller');
const facilityService = require('../../../backend/src/services/facility.service');
const { successResponse, createdResponse, validationErrorResponse, notFoundResponse } = require('../../../backend/src/utils/response');

jest.mock('../../../backend/src/services/facility.service');
jest.mock('../../../backend/src/utils/response');

describe('Facilities Controller', () => {
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

  describe('createFacility', () => {
    it('should create facility and return 201 (Success Path)', async () => {
      req.user = { rt_id: 1 };
      req.body = { nama_fasilitas: 'Lapangan', deskripsi: 'Test' };
      const mockFacility = { id: 1, ...req.body };
      facilityService.createFacility.mockResolvedValue(mockFacility);

      await facilitiesController.createFacility(req, res, next);

      expect(facilityService.createFacility).toHaveBeenCalledWith({
        rt_id: 1, nama_fasilitas: 'Lapangan', deskripsi: 'Test',
        foto_url: undefined, alamat: undefined, koordinat_maps_url: undefined, bisa_dipinjam: undefined
      });
      expect(createdResponse).toHaveBeenCalledWith(res, 'Fasilitas ditambahkan', mockFacility);
    });

    it('should return validation error if missing fields (Negative Path)', async () => {
      req.user = { rt_id: 1 };
      const error = new Error('wajib diisi');
      facilityService.createFacility.mockRejectedValue(error);

      await facilitiesController.createFacility(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'wajib diisi');
    });
    
    it('should call next on generic error (Negative Path)', async () => {
      req.user = { rt_id: 1 };
      const error = new Error('Database error');
      facilityService.createFacility.mockRejectedValue(error);

      await facilitiesController.createFacility(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('getFacilities', () => {
    it('should return facilities (Success Path)', async () => {
      req.user = { rt_id: 1 };
      const mockFacilities = [{ id: 1 }];
      facilityService.getFacilities.mockResolvedValue(mockFacilities);

      await facilitiesController.getFacilities(req, res, next);

      expect(facilityService.getFacilities).toHaveBeenCalledWith(1);
      expect(successResponse).toHaveBeenCalledWith(res, 'Daftar fasilitas', mockFacilities);
    });
  });

  describe('updateFacility', () => {
    it('should update facility and return 200 (Success Path)', async () => {
      req.params.id = '1';
      req.body = { nama_fasilitas: 'Updated' };
      const mockFacility = { id: 1, nama_fasilitas: 'Updated' };
      facilityService.updateFacility.mockResolvedValue(mockFacility);

      await facilitiesController.updateFacility(req, res, next);

      expect(facilityService.updateFacility).toHaveBeenCalledWith('1', req.body);
      expect(successResponse).toHaveBeenCalledWith(res, 'Fasilitas diperbarui', mockFacility);
    });

    it('should return not found if facility not found (Negative Path)', async () => {
      req.params.id = '999';
      facilityService.updateFacility.mockRejectedValue(new Error('tidak ditemukan'));

      await facilitiesController.updateFacility(req, res, next);

      expect(notFoundResponse).toHaveBeenCalledWith(res, 'tidak ditemukan');
    });
  });

  describe('deleteFacility', () => {
    it('should delete facility and return 200 (Success Path)', async () => {
      req.params.id = '1';
      facilityService.deleteFacility.mockResolvedValue();

      await facilitiesController.deleteFacility(req, res, next);

      expect(facilityService.deleteFacility).toHaveBeenCalledWith('1');
      expect(successResponse).toHaveBeenCalledWith(res, 'Fasilitas dihapus', null);
    });
    
    it('should return not found if facility not found (Negative Path)', async () => {
      req.params.id = '999';
      facilityService.deleteFacility.mockRejectedValue(new Error('tidak ditemukan'));

      await facilitiesController.deleteFacility(req, res, next);

      expect(notFoundResponse).toHaveBeenCalledWith(res, 'tidak ditemukan');
    });
  });

  describe('createReservation', () => {
    it('should create reservation and return 201 (Success Path)', async () => {
      req.params.id = '1';
      req.user = { id: 1 };
      req.body = { tanggal_mulai: '2024-01-01', tanggal_selesai: '2024-01-02' };
      const mockReservation = { id: 1 };
      facilityService.createReservation.mockResolvedValue(mockReservation);

      await facilitiesController.createReservation(req, res, next);

      expect(facilityService.createReservation).toHaveBeenCalledWith({
        facility_id: '1', peminjam_user_id: 1, tanggal_mulai: '2024-01-01', tanggal_selesai: '2024-01-02', keterangan: undefined
      });
      expect(createdResponse).toHaveBeenCalledWith(res, 'Pengajuan peminjaman fasilitas berhasil dikirim', mockReservation);
    });

    it('should handle validation errors (Negative Path)', async () => {
      req.params.id = '1';
      req.user = { id: 1 };
      const error = new Error('sudah dibooking');
      facilityService.createReservation.mockRejectedValue(error);

      await facilitiesController.createReservation(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'sudah dibooking');
    });
  });

  describe('getReservations', () => {
    it('should return reservations (Success Path)', async () => {
      req.user = { rt_id: 1 };
      const mockReservations = [{ id: 1 }];
      facilityService.getReservations.mockResolvedValue(mockReservations);

      await facilitiesController.getReservations(req, res, next);

      expect(facilityService.getReservations).toHaveBeenCalledWith(1);
      expect(successResponse).toHaveBeenCalledWith(res, 'Daftar pengajuan peminjaman', mockReservations);
    });
  });

  describe('verifyReservation', () => {
    it('should verify reservation and return 200 (Success Path)', async () => {
      req.params.id = '1';
      req.body = { status: 'APPROVED' };
      const mockReservation = { id: 1 };
      facilityService.verifyReservation.mockResolvedValue(mockReservation);

      await facilitiesController.verifyReservation(req, res, next);

      expect(facilityService.verifyReservation).toHaveBeenCalledWith('1', 'APPROVED');
      expect(successResponse).toHaveBeenCalledWith(res, 'Status pengajuan berhasil diupdate', mockReservation);
    });
    
    it('should handle invalid status error (Negative Path)', async () => {
      req.params.id = '1';
      req.body = { status: 'INVALID' };
      facilityService.verifyReservation.mockRejectedValue(new Error('tidak valid'));

      await facilitiesController.verifyReservation(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'tidak valid');
    });
  });
});
