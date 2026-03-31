const pool = require('../config/database');

const financeRepository = {

  // ─── Untuk RW: Total kas dari iuran RT ───────────────────────────────────
  async getFinanceSummaryForRW(rwId) {
    const now = new Date();
    const bulan = now.getMonth() + 1;
    const tahun = now.getFullYear();

    const [totalRes, bulananRes, txRes, rtStatusRes] = await Promise.all([
      // Total kas keseluruhan (semua waktu)
      pool.query(`
        SELECT COALESCE(SUM(dp.nominal), 0) as total
        FROM dues_payments dp
        WHERE dp.status = 'APPROVED'
          AND dp.pembayar_rt_id IN (SELECT id FROM rts WHERE rw_id = $1)
      `, [rwId]),

      // Pemasukan bulan ini saja
      pool.query(`
        SELECT COALESCE(SUM(dp.nominal), 0) as bulan_ini
        FROM dues_payments dp
        WHERE dp.status = 'APPROVED'
          AND dp.bulan = $2 AND dp.tahun = $3
          AND dp.pembayar_rt_id IN (SELECT id FROM rts WHERE rw_id = $1)
      `, [rwId, bulan, tahun]),

      // 10 transaksi terbaru
      pool.query(`
        SELECT dp.id, dp.nominal, dp.dibayar_pada, dp.bulan, dp.tahun,
               r.nomor_rt, 'RT' as tipe
        FROM dues_payments dp
        JOIN rts r ON dp.pembayar_rt_id = r.id
        WHERE dp.status = 'APPROVED' AND r.rw_id = $1
        ORDER BY dp.dibayar_pada DESC NULLS LAST
        LIMIT 10
      `, [rwId]),

      // Status iuran per-RT bulan ini
      pool.query(`
        SELECT r.id as rt_id, r.nomor_rt,
               u.nama as nama_ketua,
               dp.id as payment_id,
               ds.tenggat_tanggal
        FROM rts r
        LEFT JOIN users u ON u.rt_id = r.id AND u.role = 'RT'
        LEFT JOIN dues_settings ds ON ds.rt_id = r.id AND ds.tingkat = 'RT'
        LEFT JOIN dues_payments dp ON dp.pembayar_rt_id = r.id
          AND dp.bulan = $2 AND dp.tahun = $3 AND dp.status = 'APPROVED'
        WHERE r.rw_id = $1
        ORDER BY r.nomor_rt ASC
      `, [rwId, bulan, tahun]),
    ]);

    return {
      total_kas: parseFloat(totalRes.rows[0].total),
      pemasukan_bulan_ini: parseFloat(bulananRes.rows[0].bulan_ini),
      bulan: bulan,
      tahun: tahun,
      transaksi_terbaru: txRes.rows,
      rt_dues_status: rtStatusRes.rows.map(row => {
        const hasPaid = row.payment_id !== null;
        const daysLeft = row.tenggat_tanggal ? row.tenggat_tanggal - now.getDate() : null;
        return {
          nomor_rt: row.nomor_rt,
          nama_ketua: row.nama_ketua || `Ketua RT ${row.nomor_rt}`,
          status: hasPaid ? 'LUNAS' : (daysLeft !== null && daysLeft <= 5 ? 'HAMPIR_JATUH_TEMPO' : 'BELUM_BAYAR'),
        };
      }),
    };
  },

  // ─── Untuk RT: Total kas dari iuran warga ────────────────────────────────
  async getFinanceSummaryForRT(rtId) {
    const now = new Date();
    const bulan = now.getMonth() + 1;
    const tahun = now.getFullYear();

    const [totalFamilyRes, totalRTRes, bulananRes, txRes, wargaStatusRes] = await Promise.all([
      // Total dari warga (family)
      pool.query(`
        SELECT COALESCE(SUM(dp.nominal), 0) as total
        FROM dues_payments dp
        WHERE dp.status = 'APPROVED'
          AND dp.pembayar_family_id IN (SELECT id FROM families WHERE rt_id = $1)
      `, [rtId]),

      // Total dari RT ke RW
      pool.query(`
        SELECT COALESCE(SUM(dp.nominal), 0) as total
        FROM dues_payments dp
        WHERE dp.status = 'APPROVED'
          AND dp.pembayar_rt_id = $1
      `, [rtId]),

      // Pemasukan bulan ini (dari warga)
      pool.query(`
        SELECT COALESCE(SUM(dp.nominal), 0) as bulan_ini
        FROM dues_payments dp
        WHERE dp.status = 'APPROVED'
          AND dp.bulan = $2 AND dp.tahun = $3
          AND dp.pembayar_family_id IN (SELECT id FROM families WHERE rt_id = $1)
      `, [rtId, bulan, tahun]),

      // 10 transaksi terbaru (dari warga)
      pool.query(`
        SELECT dp.id, dp.nominal, dp.dibayar_pada, dp.bulan, dp.tahun,
               u.nama as nama_pembayar, f.no_kk, 'WARGA' as tipe
        FROM dues_payments dp
        JOIN families f ON dp.pembayar_family_id = f.id
        JOIN users u ON f.user_id = u.id
        WHERE dp.status = 'APPROVED' AND f.rt_id = $1
        ORDER BY dp.dibayar_pada DESC NULLS LAST
        LIMIT 10
      `, [rtId]),

      // Status bayar warga bulan ini
      pool.query(`
        SELECT
          COUNT(f.id) FILTER (WHERE dp.id IS NOT NULL) as sudah_bayar,
          COUNT(f.id) as total_kk
        FROM families f
        LEFT JOIN dues_payments dp ON dp.pembayar_family_id = f.id
          AND dp.bulan = $2 AND dp.tahun = $3 AND dp.status = 'APPROVED'
        WHERE f.rt_id = $1 AND f.status_verifikasi = 'APPROVED'
      `, [rtId, bulan, tahun]),
    ]);

    const ws = wargaStatusRes.rows[0];
    return {
      total_kas: parseFloat(totalFamilyRes.rows[0].total),
      total_disetor_ke_rw: parseFloat(totalRTRes.rows[0].total),
      pemasukan_bulan_ini: parseFloat(bulananRes.rows[0].bulan_ini),
      bulan: bulan,
      tahun: tahun,
      sudah_bayar: parseInt(ws.sudah_bayar || 0),
      total_kk: parseInt(ws.total_kk || 0),
      transaksi_terbaru: txRes.rows,
    };
  },

  // ─── Untuk Warga: Total iuran pribadi/keluarga ─────────────────────────────
  async getFinanceSummaryForWarga(userId) {
    const now = new Date();
    const bulan = now.getMonth() + 1;
    const tahun = now.getFullYear();

    // Dapatkan family_id dulu
    const familyRes = await pool.query('SELECT id FROM families WHERE user_id = $1', [userId]);
    if (!familyRes || familyRes.rows.length === 0) return { total_kas: 0, pemasukan_bulan_ini: 0, transaksi_terbaru: [], bulan, tahun };
    
    const familyId = familyRes.rows[0].id;

    const [totalRes, bulananRes, txRes] = await Promise.all([
      // Total terbayar
      pool.query(`
        SELECT COALESCE(SUM(nominal), 0) as total
        FROM dues_payments
        WHERE pembayar_family_id = $1 AND status = 'APPROVED'
      `, [familyId]),

      // Terbayar bulan ini
      pool.query(`
        SELECT COALESCE(SUM(nominal), 0) as bulan_ini
        FROM dues_payments
        WHERE pembayar_family_id = $1 AND status = 'APPROVED'
          AND bulan = $2 AND tahun = $3
      `, [familyId, bulan, tahun]),

      // Riwayat transaksi keluarga
      pool.query(`
        SELECT id, nominal, dibayar_pada, bulan, tahun,
               'Iuran Pribadi' as nama_pembayar, 'WARGA' as tipe
        FROM dues_payments
        WHERE pembayar_family_id = $1 AND status = 'APPROVED'
        ORDER BY dibayar_pada DESC NULLS LAST
        LIMIT 10
      `, [familyId]),
    ]);

    return {
      total_kas: parseFloat(totalRes?.rows?.[0]?.total || 0),
      pemasukan_bulan_ini: parseFloat(bulananRes?.rows?.[0]?.bulan_ini || 0),
      bulan,
      tahun,
      transaksi_terbaru: txRes?.rows || [],
    };
  },
};

module.exports = financeRepository;
