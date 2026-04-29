const pool = require('../backend/src/config/database');

// Clean database before each test
beforeEach(async () => {
  // Only truncate if we are NOT mocking the repository
  // We check if it's a repository test. If it's a service/api test, we don't need to truncate.
  // Actually, truncating is fast enough. We'll truncate all main tables.
  try {
    await pool.query(`
      TRUNCATE TABLE 
        users, families, residents, rws, rts, 
        dues_settings, dues_bills, dues_payments, 
        announcements, facilities, facility_reservations, 
        letters, notifications, invitations
      RESTART IDENTITY CASCADE;
    `);
  } catch (error) {
    // If table doesn't exist or pool is mocked, just ignore
  }
});

// Close database connection after all tests
afterAll(async () => {
  if (pool && typeof pool.end === 'function') {
    await pool.end();
  }
});
