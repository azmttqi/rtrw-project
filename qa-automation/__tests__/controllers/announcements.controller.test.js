const announcementsController = require('../../../backend/src/controllers/announcements.controller');
const announcementService = require('../../../backend/src/services/announcement.service');
const { successResponse, createdResponse, errorResponse, validationErrorResponse, notFoundResponse } = require('../../../backend/src/utils/response');
const { getPaginationMeta } = require('../../../backend/src/utils/pagination');

jest.mock('../../../backend/src/services/announcement.service');
jest.mock('../../../backend/src/utils/response');
jest.mock('../../../backend/src/utils/pagination');

describe('Announcements Controller', () => {
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

  describe('createAnnouncement', () => {
    it('should create an announcement and return 201 (Success Path)', async () => {
      req.user = { id: 1 };
      req.body = { judul: 'Test Pengumuman', konten: 'Test konten' };
      const mockAnnouncement = { id: 1, ...req.body, pembuat_user_id: 1 };
      announcementService.createAnnouncement.mockResolvedValue(mockAnnouncement);

      await announcementsController.createAnnouncement(req, res, next);

      expect(announcementService.createAnnouncement).toHaveBeenCalledWith({
        pembuat_user_id: 1,
        judul: 'Test Pengumuman',
        konten: 'Test konten',
        target: undefined, target_rt_id: undefined, foto_url: undefined, is_kegiatan: undefined, tanggal_kegiatan: undefined
      });
      expect(createdResponse).toHaveBeenCalledWith(res, 'Pengumuman dibuat', mockAnnouncement);
    });

    it('should return validation error if data is incomplete (Negative Path)', async () => {
      const error = new Error('Data tidak lengkap, judul dan konten wajib diisi');
      req.user = { id: 1 };
      announcementService.createAnnouncement.mockRejectedValue(error);

      await announcementsController.createAnnouncement(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Data tidak lengkap, judul dan konten wajib diisi');
    });

    it('should call next with generic error (Negative Path)', async () => {
      const error = new Error('Database Error');
      req.user = { id: 1 };
      announcementService.createAnnouncement.mockRejectedValue(error);

      await announcementsController.createAnnouncement(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('getAnnouncements', () => {
    it('should return announcements (Success Path)', async () => {
      req.query = { page: 1, limit: 10 };
      req.user = { role: 'WARGA', rw_id: 1 };
      const mockResult = { data: [{ id: 1, judul: 'Test' }], total: 1 };
      announcementService.getAnnouncements.mockResolvedValue(mockResult);
      getPaginationMeta.mockReturnValue({ page: 1, limit: 10, total: 1, totalPages: 1 });

      await announcementsController.getAnnouncements(req, res, next);

      expect(announcementService.getAnnouncements).toHaveBeenCalledWith({ rt_id: undefined, rw_id: 1 }, 1, 10);
      expect(successResponse).toHaveBeenCalledWith(res, 'Daftar pengumuman', {
        announcements: mockResult.data,
        pagination: { page: 1, limit: 10, total: 1, totalPages: 1 }
      });
    });

    it('should allow admin to see all via query (Success Path)', async () => {
      req.query = { page: 1, limit: 10, rw_id: 2 };
      req.user = { role: 'ADMIN' };
      const mockResult = { data: [{ id: 1, judul: 'Test' }], total: 1 };
      announcementService.getAnnouncements.mockResolvedValue(mockResult);
      getPaginationMeta.mockReturnValue({ page: 1, limit: 10, total: 1, totalPages: 1 });

      await announcementsController.getAnnouncements(req, res, next);

      expect(announcementService.getAnnouncements).toHaveBeenCalledWith({ rt_id: undefined, rw_id: 2 }, 1, 10);
    });

    it('should call next with generic error (Negative Path)', async () => {
      const error = new Error('Database Error');
      req.user = { role: 'WARGA', rw_id: 1 };
      announcementService.getAnnouncements.mockRejectedValue(error);

      await announcementsController.getAnnouncements(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('updateAnnouncement', () => {
    it('should update announcement and return 200 (Success Path)', async () => {
      req.params.id = '1';
      req.body = { judul: 'Updated', konten: 'Updated konten' };
      const mockAnnouncement = { id: 1, ...req.body };
      announcementService.updateAnnouncement.mockResolvedValue(mockAnnouncement);

      await announcementsController.updateAnnouncement(req, res, next);

      expect(announcementService.updateAnnouncement).toHaveBeenCalledWith('1', {
        judul: 'Updated', konten: 'Updated konten', is_kegiatan: undefined, tanggal_kegiatan: undefined
      });
      expect(successResponse).toHaveBeenCalledWith(res, 'Pengumuman diperbarui', mockAnnouncement);
    });

    it('should return not found if announcement not found (Negative Path)', async () => {
      const error = new Error('Pengumuman tidak ditemukan');
      req.params.id = '999';
      announcementService.updateAnnouncement.mockRejectedValue(error);

      await announcementsController.updateAnnouncement(req, res, next);

      expect(notFoundResponse).toHaveBeenCalledWith(res, 'Pengumuman tidak ditemukan');
    });

    it('should call next with generic error (Negative Path)', async () => {
      const error = new Error('Some error');
      announcementService.updateAnnouncement.mockRejectedValue(error);

      await announcementsController.updateAnnouncement(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('deleteAnnouncement', () => {
    it('should delete announcement and return 200 (Success Path)', async () => {
      req.params.id = '1';
      announcementService.deleteAnnouncement.mockResolvedValue(true);

      await announcementsController.deleteAnnouncement(req, res, next);

      expect(announcementService.deleteAnnouncement).toHaveBeenCalledWith('1');
      expect(successResponse).toHaveBeenCalledWith(res, 'Pengumuman dihapus', null);
    });

    it('should return not found if announcement not found (Negative Path)', async () => {
      const error = new Error('Pengumuman tidak ditemukan');
      req.params.id = '999';
      announcementService.deleteAnnouncement.mockRejectedValue(error);

      await announcementsController.deleteAnnouncement(req, res, next);

      expect(notFoundResponse).toHaveBeenCalledWith(res, 'Pengumuman tidak ditemukan');
    });

    it('should call next with generic error (Negative Path)', async () => {
      const error = new Error('Delete failed');
      announcementService.deleteAnnouncement.mockRejectedValue(error);

      await announcementsController.deleteAnnouncement(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });
});
