const announcementRepository = require('../repositories/announcement.repository');

const announcementService = {
  async createAnnouncement(data) {
    if (!data.target || !data.judul || !data.konten) {
      throw new Error('Data pengumuman tidak lengkap');
    }
    
    // Validasi target WARGA_RT harus menyertakan target_rt_id
    if (data.target === 'WARGA_RT' && !data.target_rt_id) {
        throw new Error('Target RT ID harus diisi jika target adalah WARGA_RT');
    }

    return await announcementRepository.createAnnouncement(data);
  },

  async getAnnouncements(filters, page, limit) {
    // Ensuring basic types
    const parsedPage = parseInt(page) || 1;
    const parsedLimit = parseInt(limit) || 10;
    
    return await announcementRepository.getAnnouncements(filters, parsedPage, parsedLimit);
  },

  async updateAnnouncement(id, data) {
    const existing = await announcementRepository.getAnnouncementById(id);
    if (!existing) {
        throw new Error('Pengumuman tidak ditemukan');
    }

    // Only update fields that exist, fallback to existing ones
    const updateData = {
        judul: data.judul !== undefined ? data.judul : existing.judul,
        konten: data.konten !== undefined ? data.konten : existing.konten,
        is_kegiatan: data.is_kegiatan !== undefined ? data.is_kegiatan : existing.is_kegiatan,
        tanggal_kegiatan: data.tanggal_kegiatan !== undefined ? data.tanggal_kegiatan : existing.tanggal_kegiatan
    };

    return await announcementRepository.updateAnnouncement(id, updateData);
  },

  async deleteAnnouncement(id) {
    const existing = await announcementRepository.getAnnouncementById(id);
    if (!existing) {
        throw new Error('Pengumuman tidak ditemukan');
    }

    return await announcementRepository.deleteAnnouncement(id);
  }
};

module.exports = announcementService;
