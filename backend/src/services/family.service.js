const familyRepository = require('../repositories/family.repository');

const familyService = {
  async getMyFamily(userId) {
    const family = await familyRepository.findByUserId(userId);
    if (!family) {
      throw new Error('Keluarga tidak ditemukan');
    }
    return family;
  },

  async createFamily(userId, { rt_id, no_kk, tipe_warga, status_tinggal, status_pernikahan }) {
    if (!no_kk || !rt_id || !tipe_warga || !status_tinggal) {
      throw new Error('Data keluarga tidak lengkap');
    }

    const existing = await familyRepository.findByNoKK(no_kk);
    if (existing) {
      throw new Error('Nomor KK sudah terdaftar');
    }

    return await familyRepository.create({
      user_id: userId,
      rt_id,
      no_kk,
      tipe_warga,
      status_tinggal,
      status_pernikahan,
    });
  },

  async getFamiliesByRT(rtId, page, limit) {
    return await familyRepository.findAllByRT(rtId, { page: parseInt(page), limit: parseInt(limit) });
  },

  async verifyFamily(familyId, status) {
    if (!['APPROVED', 'REJECTED'].includes(status)) {
      throw new Error('Status tidak valid');
    }

    const family = await familyRepository.update(familyId, { status_verifikasi: status });
    if (!family) {
      throw new Error('Keluarga tidak ditemukan');
    }

    return family;
  }
};

module.exports = familyService;
