const pool = require('../config/database');

const duesRepository = {
  // Settings
  async findSettingsByRT(rtId) {
    const result = await pool.query(
      "SELECT * FROM dues_settings WHERE tingkat = 'WARGA' AND rt_id = $1",
      [rtId]
    );
    return result.rows;
  },

  async findSettingsByRW(rwId) {
    const result = await pool.query(
      "SELECT * FROM dues_settings WHERE tingkat = 'RT' AND rw_id = $1",
      [rwId]
    );
    return result.rows;
  },

  async createSetting({ tingkat, rt_id, rw_id, nominal, tenggat_tanggal }) {
    const result = await pool.query(
      `INSERT INTO dues_settings (tingkat, rt_id, rw_id, nominal, tenggat_tanggal) 
       VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [tingkat, rt_id, rw_id, nominal, tenggat_tanggal]
    );
    return result.rows[0];
  },

  // Bills
  async findBillByFamilyAndPeriod(familyId, bulan, tahun) {
    const result = await pool.query(
      'SELECT * FROM dues_bills WHERE family_id = $1 AND bulan = $2 AND tahun = $3',
      [familyId, bulan, tahun]
    );
    return result.rows[0];
  },

  async createBill({ family_id, bulan, tahun, nominal }) {
    const result = await pool.query(
      `INSERT INTO dues_bills (family_id, bulan, tahun, nominal, status) 
       VALUES ($1, $2, $3, $4, 'PENDING') RETURNING *`,
      [family_id, bulan, tahun, nominal]
    );
    return result.rows[0];
  },

  async findBillById(id) {
    const result = await pool.query('SELECT * FROM dues_bills WHERE id = $1', [id]);
    return result.rows[0];
  },

  async findBillsByRT(rtId, { page = 1, limit = 10 }) {
    const offset = (page - 1) * limit;
    const result = await pool.query(
      `SELECT db.*, f.no_kk, u.nama as nama_kepala_keluarga
       FROM dues_bills db
       JOIN families f ON db.family_id = f.id
       JOIN users u ON f.user_id = u.id
       WHERE f.rt_id = $1
       ORDER BY db.tahun DESC, db.bulan DESC
       LIMIT $2 OFFSET $3`,
      [rtId, limit, offset]
    );
    const countResult = await pool.query(
      'SELECT COUNT(*) FROM dues_bills db JOIN families f ON db.family_id = f.id WHERE f.rt_id = $1',
      [rtId]
    );
    return { data: result.rows, total: parseInt(countResult.rows[0].count) };
  },

  async updateBillStatus(id, status) {
    const result = await pool.query(
      'UPDATE dues_bills SET status = $1 WHERE id = $2 RETURNING *',
      [status, id]
    );
    return result.rows[0];
  },

  // Payments
  async createPayment({ pembayar_family_id, pembayar_rt_id, bulan, tahun, nominal, metode_bayar, bukti_bayar_url }) {
    const result = await pool.query(
      `INSERT INTO dues_payments (pembayar_family_id, pembayar_rt_id, bulan, tahun, nominal, metode_bayar, bukti_bayar_url, status) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, 'PENDING') RETURNING *`,
      [pembayar_family_id, pembayar_rt_id, bulan, tahun, nominal, metode_bayar, bukti_bayar_url]
    );
    return result.rows[0];
  },

  async findPaymentById(id) {
    const result = await pool.query('SELECT * FROM dues_payments WHERE id = $1', [id]);
    return result.rows[0];
  },

  async verifyPayment(id, status) {
    const result = await pool.query(
      'UPDATE dues_payments SET status = $1 WHERE id = $2 RETURNING *',
      [status, id]
    );
    return result.rows[0];
  },

  async findPaymentsByRT(rtId, { page = 1, limit = 10 }) {
    const offset = (page - 1) * limit;
    const result = await pool.query(
      `SELECT dp.*, f.no_kk, u.nama as nama_pembayar
       FROM dues_payments dp
       LEFT JOIN families f ON dp.pembayar_family_id = f.id
       LEFT JOIN users u ON f.user_id = u.id
       WHERE f.rt_id = $1
       ORDER BY dp.dibayar_pada DESC
       LIMIT $2 OFFSET $3`,
      [rtId, limit, offset]
    );
    const countResult = await pool.query(
      'SELECT COUNT(*) FROM dues_payments dp JOIN families f ON dp.pembayar_family_id = f.id WHERE f.rt_id = $1',
      [rtId]
    );
    return { data: result.rows, total: parseInt(countResult.rows[0].count) };
  },
};

module.exports = duesRepository;

