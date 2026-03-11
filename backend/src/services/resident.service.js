const residentRepository = require('../repositories/resident.repository');

const residentService = {
  async getResidentsByFamily(familyId) {
    if (!familyId) {
      throw new Error('Family ID diperlukan');
    }
    return await residentRepository.findByFamilyId(familyId);
  },

  async addResident({ family_id, nik, nama_lengkap, jenis_kelamin, tanggal_lahir, hubungan_keluarga }) {
    if (!family_id || !nik || !nama_lengkap || !jenis_kelamin || !tanggal_lahir || !hubungan_keluarga) {
      throw new Error('Data anggota keluarga tidak lengkap');
    }

    const existingNik = await residentRepository.findByNik(nik);
    if (existingNik) {
      throw new Error('NIK sudah terdaftar');
    }

    return await residentRepository.create({
      family_id,
      nik,
      nama_lengkap,
      jenis_kelamin,
      tanggal_lahir,
      hubungan_keluarga,
    });
  },

  async updateResident(id, { nik, nama_lengkap, jenis_kelamin, tanggal_lahir, hubungan_keluarga }) {
    const resident = await residentRepository.update(id, {
      nik,
      nama_lengkap,
      jenis_kelamin,
      tanggal_lahir,
      hubungan_keluarga,
    });

    if (!resident) {
      throw new Error('Anggota keluarga tidak ditemukan');
    }

    return resident;
  },

  async deleteResident(id) {
    const resident = await residentRepository.delete(id);
    if (!resident) {
      throw new Error('Anggota keluarga tidak ditemukan');
    }
    return resident;
  }
};

module.exports = residentService;
