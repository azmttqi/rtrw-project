const announcementsController = require('../../../backend/src/controllers/announcements.controller');
const announcementService = require('../../../backend/src/services/announcement.service');
const { successResponse, createdResponse, validationErrorResponse, notFoundResponse } = require('../../../backend/src/utils/response');

jest.mock('../../../backend/src/services/announcement.service');
jest.mock('../../../backend/src/utils/response');

describe('Announcements Controller', () => {
  let req, res, next;

  beforeEach(() => {
    req = {
      user: { id: 1, role: 'RT', rw_id: 10, rt_id: 5 },
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

  describe('createAnnouncement', () => {
    it('should create an announcement and return 201 (Success Path)', async () => {
      req.body = {
        target: 'RT',
        target_rt_id: 5,
        judul: 'Kerja Bakti',
        konten: 'Kerja bakti hari Minggu',
        foto_url: 'http://example.com/photo.jpg',
        is_kegiatan: true,
        tanggal_kegiatan: '2026-08-10'
      };
      const mockCreated = { id: 100, ...req.body, pembuat_user_id: 1 };
      announcementService.createAnnouncement.mockResolvedValue(mockCreated);

      await announcementsController.createAnnouncement(req, res, next);

      expect(announcementService.createAnnouncement).toHaveBeenCalledWith({
        pembuat_user_id: 1,
        ...req.body
      });
      expect(createdResponse).toHaveBeenCalledWith(res, 'Pengumuman dibuat', mockCreated);
    });

    it('should return validation error if required fields are missing (Negative Path)', async () => {
      const error = new Error('Judul dan konten wajib diisi');
      announcementService.createAnnouncement.mockRejectedValue(error);

      await announcementsController.createAnnouncement(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Judul dan konten wajib diisi');
      expect(next).not.toHaveBeenCalled();
    });

    it('should call next with generic error if service throws unexpected error (Negative Path)', async () => {
      const error = new Error('Database connection lost');
      announcementService.createAnnouncement.mockRejectedValue(error);

      await announcementsController.createAnnouncement(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('getAnnouncements', () => {
    it('should return announcements filtered by user rw_id for non-admin (Success Path)', async () => {
      req.user = { id: 2, role: 'WARGA', rw_id: 10 };
      req.query = { rt_id: '5', page: '1', limit: '10' };
      const mockResult = {
        data: [{ id: 1, judul: 'Pengumuman 1' }],
        total: 1
      };
      announcementService.getAnnouncements.mockResolvedValue(mockResult);

      await announcementsController.getAnnouncements(req, res, next);

      expect(announcementService.getAnnouncements).toHaveBeenCalledWith(
        { rt_id: '5', rw_id: 10 },
        '1',
        '10'
      );
      expect(successResponse).toHaveBeenCalledWith(
        res,
        'Daftar pengumuman',
        expect.objectContaining({
          announcements: mockResult.data,
          pagination: expect.any(Object)
        })
      );
    });

    it('should allow admin to filter by query rw_id or view all (Success Path)', async () => {
      req.user = { id: 99, role: 'ADMIN' };
      req.query = { rw_id: '15', page: '1', limit: '10' };
      const mockResult = {
        data: [{ id: 2, judul: 'Pengumuman Admin' }],
        total: 1
      };
      announcementService.getAnnouncements.mockResolvedValue(mockResult);

      await announcementsController.getAnnouncements(req, res, next);

      expect(announcementService.getAnnouncements).toHaveBeenCalledWith(
        { rt_id: undefined, rw_id: '15' },
        '1',
        '10'
      );
      expect(successResponse).toHaveBeenCalledWith(
        res,
        'Daftar pengumuman',
        expect.objectContaining({
          announcements: mockResult.data
        })
      );
    });

    it('should call next if service throws an error (Negative Path)', async () => {
      const error = new Error('Query error');
      announcementService.getAnnouncements.mockRejectedValue(error);

      await announcementsController.getAnnouncements(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('updateAnnouncement', () => {
    it('should update announcement and return 200 (Success Path)', async () => {
      req.params.id = '100';
      req.body = {
        judul: 'Judul Baru',
        konten: 'Konten Baru',
        is_kegiatan: false,
        tanggal_kegiatan: null
      };
      const mockUpdated = { id: 100, ...req.body };
      announcementService.updateAnnouncement.mockResolvedValue(mockUpdated);

      await announcementsController.updateAnnouncement(req, res, next);

      expect(announcementService.updateAnnouncement).toHaveBeenCalledWith('100', req.body);
      expect(successResponse).toHaveBeenCalledWith(res, 'Pengumuman diperbarui', mockUpdated);
    });

    it('should return notFoundResponse if announcement is not found (Negative Path)', async () => {
      req.params.id = '999';
      const error = new Error('Pengumuman tidak ditemukan');
      announcementService.updateAnnouncement.mockRejectedValue(error);

      await announcementsController.updateAnnouncement(req, res, next);

      expect(notFoundResponse).toHaveBeenCalledWith(res, 'Pengumuman tidak ditemukan');
    });

    it('should call next on generic error during update (Negative Path)', async () => {
      req.params.id = '100';
      const error = new Error('Database error');
      announcementService.updateAnnouncement.mockRejectedValue(error);

      await announcementsController.updateAnnouncement(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('deleteAnnouncement', () => {
    it('should delete announcement and return 200 (Success Path)', async () => {
      req.params.id = '100';
      announcementService.deleteAnnouncement.mockResolvedValue(true);

      await announcementsController.deleteAnnouncement(req, res, next);

      expect(announcementService.deleteAnnouncement).toHaveBeenCalledWith('100');
      expect(successResponse).toHaveBeenCalledWith(res, 'Pengumuman dihapus', null);
    });

    it('should return notFoundResponse if announcement to delete does not exist (Negative Path)', async () => {
      req.params.id = '999';
      const error = new Error('Pengumuman tidak ditemukan');
      announcementService.deleteAnnouncement.mockRejectedValue(error);

      await announcementsController.deleteAnnouncement(req, res, next);

      expect(notFoundResponse).toHaveBeenCalledWith(res, 'Pengumuman tidak ditemukan');
    });

    it('should call next on generic error during delete (Negative Path)', async () => {
      req.params.id = '100';
      const error = new Error('Foreign key error');
      announcementService.deleteAnnouncement.mockRejectedValue(error);

      await announcementsController.deleteAnnouncement(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });
});
