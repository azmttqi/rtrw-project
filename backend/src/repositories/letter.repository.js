const pool = require('../config/database');

const letterRepository = {
  async createLetter(data) {
    const { family_id, jenis_surat, keterangan_keperluan } = data;
    const result = await pool.query(
      `INSERT INTO letters (family_id, jenis_surat, keterangan_keperluan) 
       VALUES ($1, $2, $3) RETURNING *`,
      [family_id, jenis_surat, keterangan_keperluan]
    );
    return result.rows[0];
  },

  async getLettersByFamily(family_id) {
    const result = await pool.query(
      `SELECT l.*, f.no_kk 
       FROM letters l
       JOIN families f ON l.family_id = f.id
       WHERE l.family_id = $1
       ORDER BY l.created_at DESC`,
      [family_id]
    );
    return result.rows;
  },

  async getLettersByRT(rt_id) {
    const result = await pool.query(
      `SELECT l.*, f.no_kk, u.nama as pemohon_nama
       FROM letters l
       JOIN families f ON l.family_id = f.id
       JOIN users u ON f.user_id = u.id
       WHERE f.rt_id = $1
       ORDER BY l.created_at DESC`,
      [rt_id]
    );
    return result.rows;
  },

  async getLettersByRW(rw_id) {
    const result = await pool.query(
      `SELECT l.*, f.no_kk, u.nama as pemohon_nama, rt.nomor_rt
       FROM letters l
       JOIN families f ON l.family_id = f.id
       JOIN rts rt ON f.rt_id = rt.id
       JOIN users u ON f.user_id = u.id
       WHERE rt.rw_id = $1 AND l.status IN ('APPROVED_RT_PENDING_RW', 'APPROVED_RW', 'REJECTED_RW')
       ORDER BY l.created_at DESC`,
      [rw_id]
    );
    return result.rows;
  },

  async getLetterById(id) {
    const result = await pool.query(
      `SELECT l.*, f.rt_id, rt.rw_id, rt.nomor_rt, rw.nomor_rw, f.no_kk
       FROM letters l
       JOIN families f ON l.family_id = f.id
       JOIN rts rt ON f.rt_id = rt.id
       JOIN rws rw ON rt.rw_id = rw.id
       WHERE l.id = $1`,
      [id]
    );
    return result.rows[0];
  },

  async updateLetterStatus(id, status, dokumen_hasil_url = null) {
    let query = 'UPDATE letters SET status = $1, updated_at = CURRENT_TIMESTAMP';
    const params = [status, id];
    
    if (dokumen_hasil_url) {
      query += ', dokumen_hasil_url = $3';
      params.push(dokumen_hasil_url);
    }
    
    query += ' WHERE id = $2 RETURNING *';
    
    const result = await pool.query(query, params);
    return result.rows[0];
  }
};

module.exports = letterRepository;
