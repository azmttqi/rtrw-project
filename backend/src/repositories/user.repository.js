const pool = require('../config/database');

const userRepository = {
  async findById(id) {
    const result = await pool.query(
      'SELECT id, nama, no_wa, email, google_id, role, rt_id, rw_id, is_verified, created_at FROM users WHERE id = $1',
      [id]
    );
    return result.rows[0];
  },

  async findByNoWa(no_wa) {
    const result = await pool.query('SELECT * FROM users WHERE no_wa = $1', [no_wa]);
    return result.rows[0];
  },

  async findByEmail(email) {
    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    return result.rows[0];
  },

  async findByGoogleId(google_id) {
    const result = await pool.query('SELECT * FROM users WHERE google_id = $1', [google_id]);
    return result.rows[0];
  },

  async create({ nama, no_wa = null, email = null, google_id = null, password_hash = null, role, rt_id = null, rw_id = null }) {
    const result = await pool.query(
      `INSERT INTO users (nama, no_wa, email, google_id, password_hash, role, rt_id, rw_id, is_verified) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) 
       RETURNING id, nama, no_wa, email, google_id, role, rt_id, rw_id, is_verified, created_at`,
      [nama, no_wa, email, google_id, password_hash, role, rt_id, rw_id, role === 'WARGA' ? false : (google_id ? false : true)]
    );
    return result.rows[0];
  },

  async update(id, data) {
    const fields = [];
    const values = [];
    let setQuery = '';
    let i = 1;

    for (const [key, value] of Object.entries(data)) {
      fields.push(`${key} = $${i}`);
      values.push(value);
      i++;
    }

    if (fields.length === 0) return null;

    values.push(id);
    const query = `UPDATE users SET ${fields.join(', ')} WHERE id = $${i} 
                   RETURNING id, nama, no_wa, email, google_id, role, rt_id, rw_id, is_verified, created_at`;

    const result = await pool.query(query, values);
    return result.rows[0];
  },

  async findAll({ rt_id, rw_id, page = 1, limit = 10 }) {
    const offset = (page - 1) * limit;
    let query = 'SELECT id, nama, no_wa, email, google_id, role, rt_id, rw_id, is_verified, created_at FROM users WHERE 1=1';
    const params = [];
    let paramIndex = 1;

    if (rt_id) {
      query += ` AND rt_id = $${paramIndex}`;
      params.push(rt_id);
      paramIndex++;
    }

    if (rw_id) {
      query += ` AND rw_id = $${paramIndex}`;
      params.push(rw_id);
      paramIndex++;
    }

    query += ` ORDER BY created_at DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(limit, offset);

    const result = await pool.query(query, params);

    const countResult = await pool.query('SELECT COUNT(*) FROM users');
    const total = parseInt(countResult.rows[0].count);

    return {
      data: result.rows,
      total,
    };
  },
};

module.exports = userRepository;

