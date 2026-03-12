const pool = require('../config/database');

const facilityRepository = {
  // --- Catalog ---
  async createFacility(data) {
    const { rt_id, nama_fasilitas, deskripsi, foto_url, alamat, koordinat_maps_url, bisa_dipinjam } = data;
    const result = await pool.query(
      `INSERT INTO facilities (rt_id, nama_fasilitas, deskripsi, foto_url, alamat, koordinat_maps_url, bisa_dipinjam) 
       VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
      [rt_id, nama_fasilitas, deskripsi, foto_url, alamat, koordinat_maps_url, bisa_dipinjam || false]
    );
    return result.rows[0];
  },

  async getFacilitiesByRT(rt_id) {
    let query = 'SELECT * FROM facilities WHERE 1=1';
    const params = [];

    if (rt_id) {
      query += ' AND rt_id = $1';
      params.push(rt_id);
    }

    query += ' ORDER BY created_at DESC';
    const result = await pool.query(query, params);
    return result.rows;
  },

  async getFacilityById(id) {
      const result = await pool.query('SELECT * FROM facilities WHERE id = $1', [id]);
      return result.rows[0];
  },

  async updateFacility(id, data) {
    const { nama_fasilitas, deskripsi, foto_url, alamat, koordinat_maps_url, bisa_dipinjam } = data;
    const result = await pool.query(
      `UPDATE facilities 
       SET nama_fasilitas = $1, deskripsi = $2, foto_url = $3, alamat = $4, koordinat_maps_url = $5, bisa_dipinjam = $6 
       WHERE id = $7 RETURNING *`,
      [nama_fasilitas, deskripsi, foto_url, alamat, koordinat_maps_url, bisa_dipinjam, id]
    );
    return result.rows[0];
  },

  async deleteFacility(id) {
    const result = await pool.query('DELETE FROM facilities WHERE id = $1 RETURNING *', [id]);
    return result.rows[0];
  },

  // --- Reservations ---
  async createReservation(data) {
      const { facility_id, peminjam_user_id, tanggal_mulai, tanggal_selesai, keterangan } = data;
      const result = await pool.query(
          `INSERT INTO facility_reservations (facility_id, peminjam_user_id, tanggal_mulai, tanggal_selesai, keterangan, status)
           VALUES ($1, $2, $3, $4, $5, 'PENDING') RETURNING *`,
           [facility_id, peminjam_user_id, tanggal_mulai, tanggal_selesai, keterangan]
      );
      return result.rows[0];
  },

  async checkReservationConflict(facility_id, tanggal_mulai, tanggal_selesai) {
      // Find ANY reservation for this facility that overlaps with the requested dates and is NOT rejected/selesai
      const query = `
          SELECT * FROM facility_reservations 
          WHERE facility_id = $1 
            AND status IN ('PENDING', 'APPROVED')
            AND (
                (tanggal_mulai <= $2 AND tanggal_selesai >= $2) OR  -- starts within existing
                (tanggal_mulai <= $3 AND tanggal_selesai >= $3) OR  -- ends within existing
                (tanggal_mulai >= $2 AND tanggal_selesai <= $3)     -- encompasses existing
            )
          LIMIT 1
      `;
      const result = await pool.query(query, [facility_id, tanggal_mulai, tanggal_selesai]);
      return result.rows.length > 0; // True if conflict exists
  },

  async getReservationsByRT(rt_id) {
      // Get all reservations for facilities belonging to this RT
      const query = `
          SELECT fr.*, f.nama_fasilitas, u.nama as peminjam_nama
          FROM facility_reservations fr
          JOIN facilities f ON fr.facility_id = f.id
          JOIN users u ON fr.peminjam_user_id = u.id
          WHERE f.rt_id = $1
          ORDER BY fr.tanggal_mulai DESC
      `;
      const result = await pool.query(query, [rt_id]);
      return result.rows;
  },

  async getReservationById(id) {
      const result = await pool.query('SELECT * FROM facility_reservations WHERE id = $1', [id]);
      return result.rows[0];
  },

  async updateReservationStatus(id, status) {
      const result = await pool.query(
          `UPDATE facility_reservations SET status = $1 WHERE id = $2 RETURNING *`,
          [status, id]
      );
      return result.rows[0];
  }
};

module.exports = facilityRepository;
