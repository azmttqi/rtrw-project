const request = require('supertest');
const app = require('../../../backend/src/app');
const { seedBaseData } = require('./utils/e2e-seeder');

describe('E2E: Dashboard & Keuangan Terintegrasi (Dashboard)', () => {
  let rwToken, rtToken, wargaToken;
  let testData;

  beforeEach(async () => {
    testData = await seedBaseData();

    // Login RW
    const resRW = await request(app)
      .post('/api/auth/login')
      .send({ no_wa: '081200000000', password: 'password123' });
    rwToken = resRW.body.data.token;

    // Login RT
    const resRT = await request(app)
      .post('/api/auth/login')
      .send({ no_wa: '081200000001', password: 'password123' });
    rtToken = resRT.body.data.token;

    // Login Warga
    const resWarga = await request(app)
      .post('/api/auth/login')
      .send({ no_wa: '081200000002', password: 'password123' });
    wargaToken = resWarga.body.data.token;
  });

  it('1. RT Dapat Mengakses Statistik Dashboard & Ringkasan Keuangan (200)', async () => {
    // === Tahap 1: RT Akses Statistik ===
    const resStats = await request(app)
      .get('/api/dashboard/stats')
      .set('Authorization', `Bearer ${rtToken}`);

    expect(resStats.status).toBe(200);
    expect(resStats.body.success).toBe(true);
    expect(resStats.body.data).toBeDefined();

    // === Tahap 2: RT Akses Ringkasan Keuangan ===
    const resFinance = await request(app)
      .get('/api/dashboard/finance')
      .set('Authorization', `Bearer ${rtToken}`);

    expect(resFinance.status).toBe(200);
    expect(resFinance.body.success).toBe(true);
    expect(resFinance.body.data).toBeDefined();
  });

  it('2. RW Dapat Mengakses Statistik Lingkup RW (200)', async () => {
    const resRWStats = await request(app)
      .get('/api/dashboard/stats')
      .set('Authorization', `Bearer ${rwToken}`);

    expect(resRWStats.status).toBe(200);
    expect(resRWStats.body.success).toBe(true);
    expect(resRWStats.body.data).toBeDefined();
  });

  it('3. Warga Dapat Mengakses Dashboard Pribadi (200)', async () => {
    const resWargaStats = await request(app)
      .get('/api/dashboard/stats')
      .set('Authorization', `Bearer ${wargaToken}`);

    expect(resWargaStats.status).toBe(200);
    expect(resWargaStats.body.success).toBe(true);
    expect(resWargaStats.body.data).toBeDefined();
  });

  it('4. Negative Flow: Akses Dashboard Ditolak Tanpa Token Otentikasi (401 Unauthorized)', async () => {
    const resUnauthorized = await request(app)
      .get('/api/dashboard/stats');

    expect(resUnauthorized.status).toBe(401);
    expect(resUnauthorized.body.success).toBe(false);
  });
});
