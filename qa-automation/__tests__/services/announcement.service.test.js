jest.mock('../../../backend/src/repositories/announcement.repository', () => ({
  createAnnouncement: jest.fn(),
  getAnnouncementById: jest.fn(),
  updateAnnouncement: jest.fn(),
}));

const announcementService = require('../../../backend/src/services/announcement.service');
const mockAnnouncementRepository = require('../../../backend/src/repositories/announcement.repository');

describe('Announcement Service', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('createAnnouncement', () => {
    it('Success: membuat pengumuman valid', async () => {
      const payload = { judul: 'Test', konten: 'Test konten', target: 'RT', pembuat_user_id: 'u-1' };
      mockAnnouncementRepository.createAnnouncement.mockResolvedValue({ id: 1, ...payload });

      const result = await announcementService.createAnnouncement(payload);
      expect(result.judul).toBe('Test');
    });

    it('Negative: field wajib kosong', async () => {
      await expect(announcementService.createAnnouncement({ judul: 'Test' })).rejects.toThrow('tidak lengkap');
    });

  });

  describe('updateAnnouncement', () => {
    it('Success: update pengumuman', async () => {
      mockAnnouncementRepository.getAnnouncementById.mockResolvedValue({ id: 1 });
      mockAnnouncementRepository.updateAnnouncement.mockResolvedValue({ id: 1, judul: 'Updated' });

      const result = await announcementService.updateAnnouncement(1, { judul: 'Updated' });
      expect(result.judul).toBe('Updated');
    });

    it('Negative: pengumuman tidak ditemukan', async () => {
      mockAnnouncementRepository.getAnnouncementById.mockResolvedValue(null);
      await expect(announcementService.updateAnnouncement(1, { judul: 'Updated' })).rejects.toThrow('tidak ditemukan');
    });
  });
});
