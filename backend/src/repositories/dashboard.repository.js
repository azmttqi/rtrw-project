const pool = require('../config/database');

const dashboardRepository = {
  async getRWStats(rwId) {
    // 1. Count RTs (Only Verified RT Users)
    const rtCountResult = await pool.query(
      `SELECT COUNT(*) FROM users 
       WHERE role = 'RT' AND is_verified = true 
       AND rt_id IN (SELECT id FROM rts WHERE rw_id = $1)`,
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

    // 4. Announcements (Only from this RW & Active ones)
    // Rule: Kegiatan disappears after its date, Pengumuman disappears after 24h
    const announcementsResult = await pool.query(
      `SELECT a.*, r.nomor_rt 
       FROM announcements a
       JOIN users u ON a.pembuat_user_id = u.id
       LEFT JOIN rts r ON a.target_rt_id = r.id
       WHERE u.rw_id = $1
         AND (
           (a.is_kegiatan = true AND a.tanggal_kegiatan >= CURRENT_DATE)
           OR 
           (a.is_kegiatan = false AND a.created_at >= NOW() - INTERVAL '24 hours')
         )
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

    // 7. Age Distribution
    const ageDistributionResult = await pool.query(
      `SELECT 
        COUNT(*) FILTER (WHERE EXTRACT(YEAR FROM age(CURRENT_DATE, r.tanggal_lahir)) < 18) as under_18,
        COUNT(*) FILTER (WHERE EXTRACT(YEAR FROM age(CURRENT_DATE, r.tanggal_lahir)) >= 18 AND EXTRACT(YEAR FROM age(CURRENT_DATE, r.tanggal_lahir)) <= 60) as adult,
        COUNT(*) FILTER (WHERE EXTRACT(YEAR FROM age(CURRENT_DATE, r.tanggal_lahir)) > 60) as senior,
        COUNT(r.id) as total
       FROM residents r
       JOIN families f ON r.family_id = f.id
       JOIN rts rt ON f.rt_id = rt.id
       WHERE rt.rw_id = $1 AND r.tanggal_lahir IS NOT NULL`,
      [rwId]
    );

    const ageData = ageDistributionResult.rows[0];
    const totalAge = parseInt(ageData.total) || 1; // avoid division by zero
    const ageDistribution = {
      under_18: Math.round((parseInt(ageData.under_18) / totalAge) * 100) || 0,
      adult: Math.round((parseInt(ageData.adult) / totalAge) * 100) || 0,
      senior: Math.round((parseInt(ageData.senior) / totalAge) * 100) || 0
    };

    return {
      totalRT: parseInt(rtCountResult.rows[0].count),
      totalWarga: parseInt(wargaCountResult.rows[0].count),
      totalBalance: parseFloat(balanceResult.rows[0].sum || 0),
      latestAnnouncements: announcementsResult.rows,
      rtFinancialStatus: financialStatusResult.rows.map(row => ({
        rt: `RT ${row.nomor_rt}`,
        percentage: row.total_families > 0 ? parseInt(row.paid_families) / parseInt(row.total_families) : 0
      })),
      latestComplaints: complaintsResult.rows,
      ageDistribution,
      totalPendingApprovals: parseInt(rtCountResult.rows[0].count), // RW has no direct totalPendingApprovals var, but we'll add the list
      pendingApprovalsList: pendingApprovalsListResult.rows
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
      "SELECT COUNT(*) FROM families WHERE rt_id = $1 AND status_verifikasi = 'PENDING'",
      [rtId]
    );

    // 4. Announcements (From RW and this specific RT & Active ones)
    // Rule: Kegiatan disappears after its date, Pengumuman disappears after 24h
    const announcementsResult = await pool.query(
      `SELECT a.*, r.nomor_rt 
       FROM announcements a
       JOIN users u ON a.pembuat_user_id = u.id
       LEFT JOIN rts r ON a.target_rt_id = r.id
       WHERE (
          (a.target = 'SEMUA_RW' AND u.rw_id = (SELECT rw_id FROM rts WHERE id = $1))
          OR (a.target = 'SEMUA_RT' AND u.rw_id = (SELECT rw_id FROM rts WHERE id = $1))
          OR (a.target = 'WARGA_RT' AND a.target_rt_id = $1)
       )
       AND (
           (a.is_kegiatan = true AND a.tanggal_kegiatan >= CURRENT_DATE)
           OR 
           (a.is_kegiatan = false AND a.created_at >= NOW() - INTERVAL '24 hours')
       )
       ORDER BY a.created_at DESC LIMIT 3`,
      [rtId]
    );

    // 5. Age Distribution
    const ageDistributionResult = await pool.query(
      `SELECT 
        COUNT(*) FILTER (WHERE EXTRACT(YEAR FROM age(CURRENT_DATE, r.tanggal_lahir)) < 18) as under_18,
        COUNT(*) FILTER (WHERE EXTRACT(YEAR FROM age(CURRENT_DATE, r.tanggal_lahir)) >= 18 AND EXTRACT(YEAR FROM age(CURRENT_DATE, r.tanggal_lahir)) <= 60) as adult,
        COUNT(*) FILTER (WHERE EXTRACT(YEAR FROM age(CURRENT_DATE, r.tanggal_lahir)) > 60) as senior,
        COUNT(r.id) as total
       FROM residents r
       JOIN families f ON r.family_id = f.id
       WHERE f.rt_id = $1 AND r.tanggal_lahir IS NOT NULL`,
      [rtId]
    );

    const ageData = ageDistributionResult.rows[0];
    const totalAge = parseInt(ageData.total) || 1; // avoid division by zero
    const ageDistribution = {
      under_18: Math.round((parseInt(ageData.under_18) / totalAge) * 100) || 0,
      adult: Math.round((parseInt(ageData.adult) / totalAge) * 100) || 0,
      senior: Math.round((parseInt(ageData.senior) / totalAge) * 100) || 0
    };

    // 6. Pending Approvals List (Family Verification)
    const pendingApprovalsListResult = await pool.query(
      `SELECT f.id as family_id, u.nama as name, f.no_kk, 'FAMILY_VERIFICATION' as type
       FROM families f
       JOIN users u ON f.user_id = u.id
       WHERE f.rt_id = $1 AND f.status_verifikasi = 'PENDING'
       ORDER BY f.created_at DESC
       LIMIT 3`,
      [rtId]
    );

    return {
      totalWarga: parseInt(wargaCountResult.rows[0].count),
      totalBalance: parseFloat(balanceResult.rows[0].sum || 0),
      totalPendingApprovals: parseInt(pendingApprovalsResult.rows[0].count),
      latestAnnouncements: announcementsResult.rows,
      ageDistribution,
      pendingApprovalsList: pendingApprovalsListResult.rows
    };
  },

  async getWargaStats(userId, rtId) {
    if (!rtId) {
      return { totalWarga: 0, totalBalance: 0, latestAnnouncements: [] };
    }
    // 1. Total Warga in their RT
    const wargaCountResult = await pool.query(
      "SELECT COUNT(*) FROM users WHERE rt_id = $1 AND role = 'WARGA'",
      [rtId]
    );

    // 2. RT's Balance (Community Fund)
    const balanceResult = await pool.query(
      "SELECT SUM(nominal) FROM dues_payments WHERE status = 'APPROVED' AND pembayar_rt_id = $1",
      [rtId]
    );

    // 3. Latest Announcements
    const announcementsResult = await pool.query(
      `SELECT a.*, r.nomor_rt 
       FROM announcements a
       JOIN users u ON a.pembuat_user_id = u.id
       LEFT JOIN rts r ON a.target_rt_id = r.id
       WHERE (
          (a.target = 'SEMUA_RW' AND u.rw_id = (SELECT rw_id FROM rts WHERE id = $1))
          OR (a.target = 'SEMUA_RT' AND u.rw_id = (SELECT rw_id FROM rts WHERE id = $1))
          OR (a.target = 'WARGA_RT' AND a.target_rt_id = $1)
       )
       AND (
           (a.is_kegiatan = true AND a.tanggal_kegiatan >= CURRENT_DATE)
           OR 
           (a.is_kegiatan = false AND a.created_at >= NOW() - INTERVAL '24 hours')
       )
       ORDER BY a.created_at DESC LIMIT 3`,
      [rtId]
    );

    return {
      totalWarga: parseInt(wargaCountResult?.rows?.[0]?.count || 0),
      totalBalance: parseFloat(balanceResult?.rows?.[0]?.sum || 0),
      latestAnnouncements: announcementsResult?.rows || []
    };
  }
};

module.exports = dashboardRepository;
