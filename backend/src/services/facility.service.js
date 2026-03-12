const facilityRepository = require('../repositories/facility.repository');

const facilityService = {
  // --- Catalog ---
  async createFacility(data) {
    if (!data.nama_fasilitas) {
      throw new Error('Nama fasilitas wajib diisi');
    }
    
    // Convert string 'true'/'false' or truthy/falsy to boolean properly
    data.bisa_dipinjam = data.bisa_dipinjam === true || data.bisa_dipinjam === 'true' || data.bisa_dipinjam === 1;

    return await facilityRepository.createFacility(data);
  },

  async getFacilities(rt_id) {
    return await facilityRepository.getFacilitiesByRT(rt_id);
  },

  async updateFacility(id, data) {
    const existing = await facilityRepository.getFacilityById(id);
    if (!existing) {
        throw new Error('Fasilitas tidak ditemukan');
    }

    const updateData = {
        nama_fasilitas: data.nama_fasilitas !== undefined ? data.nama_fasilitas : existing.nama_fasilitas,
        deskripsi: data.deskripsi !== undefined ? data.deskripsi : existing.deskripsi,
        foto_url: data.foto_url !== undefined ? data.foto_url : existing.foto_url,
        alamat: data.alamat !== undefined ? data.alamat : existing.alamat,
        koordinat_maps_url: data.koordinat_maps_url !== undefined ? data.koordinat_maps_url : existing.koordinat_maps_url,
        bisa_dipinjam: data.bisa_dipinjam !== undefined ? (data.bisa_dipinjam === 'true' || data.bisa_dipinjam === true) : existing.bisa_dipinjam
    };

    return await facilityRepository.updateFacility(id, updateData);
  },

  async deleteFacility(id) {
    const existing = await facilityRepository.getFacilityById(id);
    if (!existing) {
        throw new Error('Fasilitas tidak ditemukan');
    }
    return await facilityRepository.deleteFacility(id);
  },

  // --- Reservations ---
  async createReservation(data) {
      const { facility_id, peminjam_user_id, tanggal_mulai, tanggal_selesai } = data;

      if (!facility_id || !tanggal_mulai || !tanggal_selesai) {
          throw new Error('Data reservasi tidak lengkap');
      }

      if (new Date(tanggal_selesai) < new Date(tanggal_mulai)) {
          throw new Error('Tanggal selesai tidak boleh sebelum tanggal mulai');
      }

      const facility = await facilityRepository.getFacilityById(facility_id);
      if (!facility) {
          throw new Error('Fasilitas tidak ditemukan');
      }

      if (!facility.bisa_dipinjam) {
          throw new Error('Fasilitas ini (cth: Masjid/Taman) tidak diperuntukkan untuk dipinjam/dibooking secara eksklusif');
      }

      const hasConflict = await facilityRepository.checkReservationConflict(facility_id, tanggal_mulai, tanggal_selesai);
      if (hasConflict) {
          throw new Error('Fasilitas sudah dibooking oleh orang lain pada rentang tanggal tersebut');
      }

      return await facilityRepository.createReservation(data);
  },

  async getReservations(rt_id) {
      if (!rt_id) throw new Error('RT ID diperlukan');
      return await facilityRepository.getReservationsByRT(rt_id);
  },

  async verifyReservation(id, status) {
      if (!['APPROVED', 'REJECTED'].includes(status)) {
          throw new Error('Status verifikasi reservasi tidak valid');
      }

      const reservation = await facilityRepository.getReservationById(id);
      if (!reservation) {
          throw new Error('Reservasi tidak ditemukan');
      }

      return await facilityRepository.updateReservationStatus(id, status);
  }
};

module.exports = facilityService;
