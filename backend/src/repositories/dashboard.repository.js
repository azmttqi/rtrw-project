const pool = require('../config/database');

const dashboardRepository = {
  async getRWStats(rwId) {
    // 1. Count RTs
    const rtCountResult = await pool.query(
      'SELECT COUNT(*) FROM rts WHERE rw_id = $1',
      [rwId]
    );
    
    // 2. Count Warga (Include those linked via RT)
    const wargaCountResult = await pool.query(
      `SELECT COUNT(*) FROM users 
       WHERE role = 'WARGA' AND (rw_id = $1 OR rt_id IN (SELECT id FROM rts WHERE rw_id = $1))`,
      [rwId]
    );

    // 3. Sum verified dues (Include family payments and RT payments)
    const balanceResult = await pool.query(
      `SELECT SUM(nominal) FROM dues_payments 
       WHERE status = 'APPROVED' AND (
         pembayar_rt_id IN (SELECT id FROM rts WHERE rw_id = $1)
         OR 
         pembayar_family_id IN (SELECT id FROM families WHERE rt_id IN (SELECT id FROM rts WHERE rw_id = $1))
       )`,
      [rwId]
    );

    // 4. Announcements (Only from this RW)
    const announcementsResult = await pool.query(
      `SELECT a.*, r.nomor_rt 
       FROM announcements a
       JOIN users u ON a.pembuat_user_id = u.id
       LEFT JOIN rts r ON a.target_rt_id = r.id
       WHERE (a.target = 'SEMUA_RW' AND u.rw_id = $1)
          OR (a.target = 'WARGA_RT' AND a.target_rt_id IN (SELECT id FROM rts WHERE rw_id = $1))
       ORDER BY a.created_at DESC LIMIT 3`,
      [rwId]
    );

    // 5. RT Financial Status (Percentage of families paid this month)
    const currentMonth = new Date().getMonth() + 1;
    const currentYear = new Date().getFullYear();
    const financialStatusResult = await pool.query(
      `SELECT 
          r.nomor_rt,
          COUNT(DISTINCT f.id) as total_families,
          COUNT(DISTINCT dp.id) as paid_families
       FROM rts r
       LEFT JOIN families f ON r.id = f.rt_id
       LEFT JOIN dues_payments dp ON f.id = dp.pembayar_family_id 
          AND dp.bulan = $2 AND dp.tahun = $3 AND dp.status = 'APPROVED'
       WHERE r.rw_id = $1
       GROUP BY r.id, r.nomor_rt
       ORDER BY r.nomor_rt`,
      [rwId, currentMonth, currentYear]
    );

    // 6. Complaints (Aspirations)
    const complaintsResult = await pool.query(
      `SELECT c.*, u.nama as pelapor_nama, r.nomor_rt
       FROM complaints c
       JOIN users u ON c.pelapor_user_id = u.id
       JOIN rts r ON c.rt_id = r.id
       WHERE r.rw_id = $1
       ORDER BY c.created_at DESC LIMIT 3`,
      [rwId]
    );

    return {
      totalRT: parseInt(rtCountResult.rows[0].count),
      totalWarga: parseInt(wargaCountResult.rows[0].count),
      totalBalance: parseFloat(balanceResult.rows[0].sum || 0),
      latestAnnouncements: announcementsResult.rows,
      rtFinancialStatus: financialStatusResult.rows.map(row => ({
        rt: `RT ${row.nomor_rt}`,
        percentage: row.total_families > 0 ? parseInt(row.paid_families) / parseInt(row.total_families) : 0
      })),
      latestComplaints: complaintsResult.rows
    };
  },

  async getRTStats(rtId) {
    // 1. Count Warga
    const wargaCountResult = await pool.query(
      "SELECT COUNT(*) FROM users WHERE rt_id = $1 AND role = 'WARGA'",
      [rtId]
    );

    // 2. Sum verified dues
    const balanceResult = await pool.query(
      "SELECT SUM(nominal) FROM dues_payments WHERE status = 'APPROVED' AND pembayar_rt_id = $1",
      [rtId]
    );

    // 3. Count Pending Approvals (e.g. resident verifications)
    const pendingApprovalsResult = await pool.query(
      "SELECT COUNT(*) FROM users WHERE rt_id = $1 AND is_verified = false",
      [rtId]
    );

    return {
      totalWarga: parseInt(wargaCountResult.rows[0].count),
      totalBalance: parseFloat(balanceResult.rows[0].sum || 0),
      totalPendingApprovals: parseInt(pendingApprovalsResult.rows[0].count)
    };
  }
};

module.exports = dashboardRepository;
