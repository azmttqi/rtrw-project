const pool = require('../backend/src/config/database');

// Clean database before each test
beforeEach(async () => {
  try {
    await pool.query(`
      TRUNCATE TABLE 
        users, families, residents, rws, rts, 
        dues_settings, dues_bills, dues_payments, 
        announcements, facilities, facility_reservations, 
        letters, notifications, invitations, complaints, cctvs, documents
      RESTART IDENTITY CASCADE;
    `);
    // Small delay to ensure DB is ready
    await new Promise(resolve => setTimeout(resolve, 50));
  } catch (error) {
    // Ignore errors during setup
  }
});

// Close database connection after all tests
afterAll(async () => {
  if (pool && typeof pool.end === 'function') {
    await pool.end();
  }
});

