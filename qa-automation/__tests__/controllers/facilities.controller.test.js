const facilitiesController = require('../../../backend/src/controllers/facilities.controller');
const facilityService = require('../../../backend/src/services/facility.service');
const { successResponse, createdResponse, validationErrorResponse, notFoundResponse } = require('../../../backend/src/utils/response');

jest.mock('../../../backend/src/services/facility.service');
jest.mock('../../../backend/src/utils/response');

describe('Facilities Controller', () => {
  let req, res, next;

  beforeEach(() => {
    req = {
      user: { id: 1, role: 'RT', rt_id: 5 },
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

  describe('createFacility', () => {
    it('should create a new facility successfully (Success Path)', async () => {
      req.body = {
        nama_fasilitas: 'Lapangan Bulutangkis',
        deskripsi: 'Lapangan indoor',
        foto_url: 'http://example.com/field.jpg',
        alamat: 'Blok A',
        koordinat_maps_url: 'http://maps.google.com',
        bisa_dipinjam: true
      };
      const mockCreated = { id: 10, rt_id: 5, ...req.body };
      facilityService.createFacility.mockResolvedValue(mockCreated);

      await facilitiesController.createFacility(req, res, next);

      expect(facilityService.createFacility).toHaveBeenCalledWith({
        rt_id: 5,
        ...req.body
      });
      expect(createdResponse).toHaveBeenCalledWith(res, 'Fasilitas ditambahkan', mockCreated);
    });

    it('should return validation error if required fields are missing (Negative Path)', async () => {
      req.body = {};
      const error = new Error('Nama fasilitas wajib diisi');
      facilityService.createFacility.mockRejectedValue(error);

      await facilitiesController.createFacility(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Nama fasilitas wajib diisi');
    });

    it('should call next on generic error during createFacility (Negative Path)', async () => {
      req.body = { nama_fasilitas: 'Lapangan' };
      const error = new Error('Database error');
      facilityService.createFacility.mockRejectedValue(error);

      await facilitiesController.createFacility(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('getFacilities', () => {
    it('should return list of facilities for RT (Success Path)', async () => {
      req.query = { rt_id: '5' };
      const mockFacilities = [{ id: 1, nama_fasilitas: 'Balai Warga' }];
      facilityService.getFacilities.mockResolvedValue(mockFacilities);

      await facilitiesController.getFacilities(req, res, next);

      expect(facilityService.getFacilities).toHaveBeenCalledWith('5');
      expect(successResponse).toHaveBeenCalledWith(res, 'Daftar fasilitas', mockFacilities);
    });

    it('should default to req.user.rt_id if query rt_id not specified (Success Path)', async () => {
      req.query = {};
      const mockFacilities = [{ id: 2, nama_fasilitas: 'Taman' }];
      facilityService.getFacilities.mockResolvedValue(mockFacilities);

      await facilitiesController.getFacilities(req, res, next);

      expect(facilityService.getFacilities).toHaveBeenCalledWith(5);
      expect(successResponse).toHaveBeenCalledWith(res, 'Daftar fasilitas', mockFacilities);
    });

    it('should call next on error in getFacilities (Negative Path)', async () => {
      const error = new Error('Failed to fetch');
      facilityService.getFacilities.mockRejectedValue(error);

      await facilitiesController.getFacilities(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('updateFacility', () => {
    it('should update facility successfully (Success Path)', async () => {
      req.params.id = '10';
      req.body = { nama_fasilitas: 'Balai RW Updated' };
      const mockUpdated = { id: 10, ...req.body };
      facilityService.updateFacility.mockResolvedValue(mockUpdated);

      await facilitiesController.updateFacility(req, res, next);

      expect(facilityService.updateFacility).toHaveBeenCalledWith('10', req.body);
      expect(successResponse).toHaveBeenCalledWith(res, 'Fasilitas diperbarui', mockUpdated);
    });

    it('should return notFoundResponse if facility not found (Negative Path)', async () => {
      req.params.id = '999';
      const error = new Error('Fasilitas tidak ditemukan');
      facilityService.updateFacility.mockRejectedValue(error);

      await facilitiesController.updateFacility(req, res, next);

      expect(notFoundResponse).toHaveBeenCalledWith(res, 'Fasilitas tidak ditemukan');
    });

    it('should call next on generic error during updateFacility (Negative Path)', async () => {
      req.params.id = '10';
      const error = new Error('Update error');
      facilityService.updateFacility.mockRejectedValue(error);

      await facilitiesController.updateFacility(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('deleteFacility', () => {
    it('should delete facility successfully (Success Path)', async () => {
      req.params.id = '10';
      facilityService.deleteFacility.mockResolvedValue(true);

      await facilitiesController.deleteFacility(req, res, next);

      expect(facilityService.deleteFacility).toHaveBeenCalledWith('10');
      expect(successResponse).toHaveBeenCalledWith(res, 'Fasilitas dihapus', null);
    });

    it('should return notFoundResponse if facility not found to delete (Negative Path)', async () => {
      req.params.id = '999';
      const error = new Error('Fasilitas tidak ditemukan');
      facilityService.deleteFacility.mockRejectedValue(error);

      await facilitiesController.deleteFacility(req, res, next);

      expect(notFoundResponse).toHaveBeenCalledWith(res, 'Fasilitas tidak ditemukan');
    });

    it('should call next on generic error during deleteFacility (Negative Path)', async () => {
      req.params.id = '10';
      const error = new Error('Delete constraint failed');
      facilityService.deleteFacility.mockRejectedValue(error);

      await facilitiesController.deleteFacility(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('createReservation', () => {
    it('should submit facility reservation successfully (Success Path)', async () => {
      req.params.id = '10';
      req.user = { id: 3, role: 'WARGA' };
      req.body = {
        tanggal_mulai: '2026-08-10 08:00',
        tanggal_selesai: '2026-08-10 12:00',
        keterangan: 'Acara Ulang Tahun'
      };
      const mockReservation = { id: 100, facility_id: '10', peminjam_user_id: 3, ...req.body };
      facilityService.createReservation.mockResolvedValue(mockReservation);

      await facilitiesController.createReservation(req, res, next);

      expect(facilityService.createReservation).toHaveBeenCalledWith({
        facility_id: '10',
        peminjam_user_id: 3,
        ...req.body
      });
      expect(createdResponse).toHaveBeenCalledWith(res, 'Pengajuan peminjaman fasilitas berhasil dikirim', mockReservation);
    });

    it('should return validation error if reservation dates conflict or incomplete (Negative Path)', async () => {
      req.params.id = '10';
      const error = new Error('Fasilitas sudah dibooking pada jam tersebut');
      facilityService.createReservation.mockRejectedValue(error);

      await facilitiesController.createReservation(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Fasilitas sudah dibooking pada jam tersebut');
    });

    it('should return notFoundResponse if facility not found (Negative Path)', async () => {
      req.params.id = '999';
      const error = new Error('Fasilitas tidak ditemukan');
      facilityService.createReservation.mockRejectedValue(error);

      await facilitiesController.createReservation(req, res, next);

      expect(notFoundResponse).toHaveBeenCalledWith(res, 'Fasilitas tidak ditemukan');
    });

    it('should call next on generic error during createReservation (Negative Path)', async () => {
      req.params.id = '10';
      const error = new Error('Booking error');
      facilityService.createReservation.mockRejectedValue(error);

      await facilitiesController.createReservation(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('getReservations', () => {
    it('should get reservations for RT (Success Path)', async () => {
      req.user = { id: 1, role: 'RT', rt_id: 5 };
      const mockReservations = [{ id: 1, facility_id: 10, status: 'PENDING' }];
      facilityService.getReservations.mockResolvedValue(mockReservations);

      await facilitiesController.getReservations(req, res, next);

      expect(facilityService.getReservations).toHaveBeenCalledWith(5);
      expect(successResponse).toHaveBeenCalledWith(res, 'Daftar pengajuan peminjaman', mockReservations);
    });

    it('should call next on generic error during getReservations (Negative Path)', async () => {
      const error = new Error('Fetch reservations error');
      facilityService.getReservations.mockRejectedValue(error);

      await facilitiesController.getReservations(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('verifyReservation', () => {
    it('should update reservation status to APPROVED (Success Path)', async () => {
      req.params.id = '100';
      req.body = { status: 'APPROVED' };
      const mockReservation = { id: 100, status: 'APPROVED' };
      facilityService.verifyReservation.mockResolvedValue(mockReservation);

      await facilitiesController.verifyReservation(req, res, next);

      expect(facilityService.verifyReservation).toHaveBeenCalledWith('100', 'APPROVED');
      expect(successResponse).toHaveBeenCalledWith(res, 'Status pengajuan berhasil diupdate', mockReservation);
    });

    it('should return validation error if status is invalid (Negative Path)', async () => {
      req.params.id = '100';
      req.body = { status: 'UNKNOWN' };
      const error = new Error('Status pengajuan tidak valid');
      facilityService.verifyReservation.mockRejectedValue(error);

      await facilitiesController.verifyReservation(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Status pengajuan tidak valid');
    });

    it('should return notFoundResponse if reservation not found (Negative Path)', async () => {
      req.params.id = '999';
      req.body = { status: 'APPROVED' };
      const error = new Error('Reservasi tidak ditemukan');
      facilityService.verifyReservation.mockRejectedValue(error);

      await facilitiesController.verifyReservation(req, res, next);

      expect(notFoundResponse).toHaveBeenCalledWith(res, 'Reservasi tidak ditemukan');
    });

    it('should call next on generic error during verifyReservation (Negative Path)', async () => {
      req.params.id = '100';
      const error = new Error('DB Error');
      facilityService.verifyReservation.mockRejectedValue(error);

      await facilitiesController.verifyReservation(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });
});
