const pool = require('../config/database');

const familyRepository = {
  async findById(id) {
    const result = await pool.query(
      `SELECT f.*, u.nama, u.no_wa, u.role,
        (SELECT json_agg(d.*) FROM documents d WHERE d.family_id = f.id) as documents
       FROM families f 
       JOIN users u ON f.user_id = u.id 
       WHERE f.id = $1`,
      [id]
    );
    return result.rows[0];
  },

  async findByUserId(userId) {
    const result = await pool.query(
      `SELECT f.*, u.nama, u.no_wa, u.role,
        (SELECT json_agg(d.*) FROM documents d WHERE d.family_id = f.id) as documents
       FROM families f 
       JOIN users u ON f.user_id = u.id 
       WHERE f.user_id = $1`,
      [userId]
    );
    return result.rows[0];
  },

  async findByNoKK(no_kk) {
    const result = await pool.query('SELECT * FROM families WHERE no_kk = $1', [no_kk]);
    return result.rows[0];
  },

  async create({ user_id, rt_id, no_kk, tipe_warga, status_tinggal, status_pernikahan, documents = [] }) {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      const resFamily = await client.query(
        `INSERT INTO families (user_id, rt_id, no_kk, tipe_warga, status_tinggal, status_pernikahan, status_verifikasi) 
         VALUES ($1, $2, $3, $4, $5, $6, 'PENDING') 
         RETURNING *`,
        [user_id, rt_id, no_kk, tipe_warga, status_tinggal, status_pernikahan]
      );
      const family = resFamily.rows[0];

      if (documents.length > 0) {
        for (const doc of documents) {
          await client.query(
            `INSERT INTO documents (family_id, jenis_dokumen, file_url) VALUES ($1, $2, $3)`,
            [family.id, doc.jenis_dokumen, doc.file_url]
          );
        }
      }

      await client.query('COMMIT');
      return family;
    } catch (e) {
      await client.query('ROLLBACK');
      throw e;
    } finally {
      client.release();
    }
  },

  async update(id, { rt_id, no_kk, tipe_warga, status_tinggal, status_pernikahan, status_verifikasi }) {
    const fields = [];
    const values = [];
    let paramIndex = 1;

    if (rt_id !== undefined) {
      fields.push(`rt_id = $${paramIndex++}`);
      values.push(rt_id);
    }
    if (no_kk !== undefined) {
      fields.push(`no_kk = $${paramIndex++}`);
      values.push(no_kk);
    }
    if (tipe_warga !== undefined) {
      fields.push(`tipe_warga = $${paramIndex++}`);
      values.push(tipe_warga);
    }
    if (status_tinggal !== undefined) {
      fields.push(`status_tinggal = $${paramIndex++}`);
      values.push(status_tinggal);
    }
    if (status_pernikahan !== undefined) {
      fields.push(`status_pernikahan = $${paramIndex++}`);
      values.push(status_pernikahan);
    }
    if (status_verifikasi !== undefined) {
      fields.push(`status_verifikasi = $${paramIndex++}`);
      values.push(status_verifikasi);
    }

    if (fields.length === 0) return null;

    values.push(id);
    const result = await pool.query(
      `UPDATE families SET ${fields.join(', ')} WHERE id = $${paramIndex} RETURNING *`,
      values
    );
    return result.rows[0];
  },

  async findAllByRT(rt_id, { page = 1, limit = 10 }) {
    const offset = (page - 1) * limit;
    const result = await pool.query(
      `SELECT f.*, u.nama, u.no_wa 
       FROM families f 
       JOIN users u ON f.user_id = u.id 
       WHERE f.rt_id = $1 
       ORDER BY f.created_at DESC 
       LIMIT $2 OFFSET $3`,
      [rt_id, limit, offset]
    );
    const countResult = await pool.query('SELECT COUNT(*) FROM families WHERE rt_id = $1', [rt_id]);
    const total = parseInt(countResult.rows[0].count);
    return { data: result.rows, total };
  },
};

module.exports = familyRepository;

