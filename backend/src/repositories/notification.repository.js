const pool = require('../config/database');

const notificationRepository = {
  async create({ user_id, title, message }) {
    const result = await pool.query(
      'INSERT INTO notifications (user_id, title, message) VALUES ($1, $2, $3) RETURNING *',
      [user_id, title, message]
    );
    return result.rows[0];
  },

  async findByUserId(userId, { limit = 10, offset = 0 } = {}) {
    const result = await pool.query(
      'SELECT * FROM notifications WHERE user_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3',
      [userId, limit, offset]
    );
    return result.rows;
  },

  async markAsRead(id) {
    const result = await pool.query(
      'UPDATE notifications SET is_read = TRUE WHERE id = $1 RETURNING *',
      [id]
    );
    return result.rows[0];
  },

  async markAllAsRead(userId) {
    const result = await pool.query(
      'UPDATE notifications SET is_read = TRUE WHERE user_id = $1 RETURNING *',
      [userId]
    );
    return result.rows;
  },

  async delete(id) {
    await pool.query('DELETE FROM notifications WHERE id = $1', [id]);
  },

  // ─── Untuk RW: Notifikasi status iuran per-RT bulan ini ──────────────────
  async getDuesNotificationsForRW(rwId) {
    const now = new Date();
    const bulan = now.getMonth() + 1;
    const tahun = now.getFullYear();

    const result = await pool.query(`
      SELECT
        r.id as rt_id,
        r.nomor_rt,
        ds.nominal,
        ds.tenggat_tanggal,
        dp.id as payment_id,
        dp.status as payment_status,
        dp.dibayar_pada,
        u.nama as nama_ketua_rt
      FROM rts r
      LEFT JOIN dues_settings ds ON ds.rt_id = r.id AND ds.tingkat = 'RT'
      LEFT JOIN dues_payments dp ON dp.pembayar_rt_id = r.id 
        AND dp.bulan = $2 AND dp.tahun = $3 AND dp.status = 'APPROVED'
      LEFT JOIN users u ON u.rt_id = r.id AND u.role = 'RT'
      WHERE r.rw_id = $1
      ORDER BY r.nomor_rt ASC
    `, [rwId, bulan, tahun]);

    return result.rows.map(row => {
      const hasPaid = row.payment_id !== null;
      const daysLeft = row.tenggat_tanggal ? row.tenggat_tanggal - now.getDate() : null;
      return {
        rt_id: row.rt_id,
        nomor_rt: row.nomor_rt,
        nama_ketua_rt: row.nama_ketua_rt || `Ketua RT ${row.nomor_rt}`,
        bulan, tahun,
        nominal: row.nominal,
        tenggat_tanggal: row.tenggat_tanggal,
        hari_tersisa: daysLeft,
        status: hasPaid ? 'LUNAS' : (daysLeft !== null && daysLeft <= 5 ? 'HAMPIR_JATUH_TEMPO' : 'BELUM_BAYAR'),
        dibayar_pada: row.dibayar_pada,
        type: 'KEUANGAN_RT',
      };
    });
  },

  // ─── Untuk RT: Notifikasi status iuran per-keluarga bulan ini ────────────
  async getDuesNotificationsForRT(rtId) {
    const now = new Date();
    const bulan = now.getMonth() + 1;
    const tahun = now.getFullYear();

    const result = await pool.query(`
      SELECT
        f.id as family_id,
        f.no_kk,
        u.nama as nama_kepala_keluarga,
        ds.nominal,
        ds.tenggat_tanggal,
        dp.id as payment_id,
        dp.dibayar_pada
      FROM families f
      JOIN users u ON f.user_id = u.id
      LEFT JOIN dues_settings ds ON ds.rt_id = f.rt_id AND ds.tingkat = 'WARGA'
      LEFT JOIN dues_payments dp ON dp.pembayar_family_id = f.id
        AND dp.bulan = $2 AND dp.tahun = $3 AND dp.status = 'APPROVED'
      WHERE f.rt_id = $1 AND f.status_verifikasi = 'APPROVED'
      ORDER BY u.nama ASC
    `, [rtId, bulan, tahun]);

    return result.rows.map(row => {
      const hasPaid = row.payment_id !== null;
      const daysLeft = row.tenggat_tanggal ? row.tenggat_tanggal - now.getDate() : null;
      return {
        family_id: row.family_id,
        no_kk: row.no_kk,
        nama_kepala_keluarga: row.nama_kepala_keluarga,
        bulan, tahun,
        nominal: row.nominal,
        tenggat_tanggal: row.tenggat_tanggal,
        hari_tersisa: daysLeft,
        status: hasPaid ? 'LUNAS' : (daysLeft !== null && daysLeft <= 5 ? 'HAMPIR_JATUH_TEMPO' : 'BELUM_BAYAR'),
        dibayar_pada: row.dibayar_pada,
        type: 'KEUANGAN_WARGA',
      };
    });
  },
};

module.exports = notificationRepository;
