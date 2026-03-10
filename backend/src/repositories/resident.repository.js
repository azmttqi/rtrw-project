const pool = require('../config/database');

const residentRepository = {
  async findById(id) {
    const result = await pool.query('SELECT * FROM residents WHERE id = $1', [id]);
    return result.rows[0];
  },

  async findByNik(nik) {
    const result = await pool.query('SELECT * FROM residents WHERE nik = $1', [nik]);
    return result.rows[0];
  },

  async findByFamilyId(familyId) {
    const result = await pool.query(
      'SELECT * FROM residents WHERE family_id = $1 ORDER BY hubungan_keluarga',
      [familyId]
    );
    return result.rows;
  },

  async create({ family_id, nik, nama_lengkap, jenis_kelamin, tanggal_lahir, hubungan_keluarga }) {
    const result = await pool.query(
      `INSERT INTO residents (family_id, nik, nama_lengkap, jenis_kelamin, tanggal_lahir, hubungan_keluarga) 
       VALUES ($1, $2, $3, $4, $5, $6) 
       RETURNING *`,
      [family_id, nik, nama_lengkap, jenis_kelamin, tanggal_lahir, hubungan_keluarga]
    );
    return result.rows[0];
  },

  async update(id, { nik, nama_lengkap, jenis_kelamin, tanggal_lahir, hubungan_keluarga }) {
    const fields = [];
    const values = [];
    let paramIndex = 1;

    if (nik !== undefined) {
      fields.push(`nik = $${paramIndex++}`);
      values.push(nik);
    }
    if (nama_lengkap !== undefined) {
      fields.push(`nama_lengkap = $${paramIndex++}`);
      values.push(nama_lengkap);
    }
    if (jenis_kelamin !== undefined) {
      fields.push(`jenis_kelamin = $${paramIndex++}`);
      values.push(jenis_kelamin);
    }
    if (tanggal_lahir !== undefined) {
      fields.push(`tanggal_lahir = $${paramIndex++}`);
      values.push(tanggal_lahir);
    }
    if (hubungan_keluarga !== undefined) {
      fields.push(`hubungan_keluarga = $${paramIndex++}`);
      values.push(hubungan_keluarga);
    }

    if (fields.length === 0) return null;

    values.push(id);
    const result = await pool.query(
      `UPDATE residents SET ${fields.join(', ')} WHERE id = $${paramIndex} RETURNING *`,
      values
    );
    return result.rows[0];
  },

  async delete(id) {
    const result = await pool.query('DELETE FROM residents WHERE id = $1 RETURNING *', [id]);
    return result.rows[0];
  },
};

module.exports = residentRepository;

