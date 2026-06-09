const request = require('supertest');
const app = require('../../../backend/src/app');
const { seedBaseData } = require('./utils/e2e-seeder');

describe('E2E: Manajemen Iuran (Dues)', () => {
  let rtToken;
  let wargaToken;
  let testData;

  beforeEach(async () => {
    // 1. Siapkan data pondasi
    testData = await seedBaseData();

    // 2. Login RT
    const resRT = await request(app)
      .post('/api/auth/login')
      .send({ no_wa: '081200000001', password: 'password123' });
    rtToken = resRT.body.data.token;

    // 3. Login Warga
    const resWarga = await request(app)
      .post('/api/auth/login')
      .send({ no_wa: '081200000002', password: 'password123' });
    wargaToken = resWarga.body.data.token;
  });

  it('1. RT Berhasil Membuat Tagihan & Mengeceknya (201 & 200)', async () => {
    // === Tahap 1: RT Membuat Tagihan ===
    const newBill = {
      family_id: testData.familyId,
      bulan: 5,
      tahun: 2026,
      nominal: 50000
    };

    const resCreate = await request(app)
      .post('/api/dues/bills')
      .set('Authorization', `Bearer ${rtToken}`)
      .send(newBill);

    expect(resCreate.status).toBe(201);
    expect(resCreate.body.success).toBe(true);
    expect(resCreate.body.data.status).toBe('PENDING');
    
    const billId = resCreate.body.data.id;

    // === Tahap 2: RT Mengecek Tagihan ===
    const resCheck = await request(app)
      .get('/api/dues/bills')
      .set('Authorization', `Bearer ${rtToken}`);

    expect(resCheck.status).toBe(200);
    expect(resCheck.body.success).toBe(true);
    
    // Pastikan tagihan yang dibuat RT muncul di daftar tagihan
    const foundBill = resCheck.body.data.bills.find(b => b.id === billId);
    expect(foundBill).toBeDefined();
    expect(Number(foundBill.nominal)).toBe(newBill.nominal);
    expect(foundBill.status).toBe('PENDING');
  });

  it('2. BVA: RT Gagal Membuat Tagihan jika Data Tidak Lengkap (400)', async () => {
    const invalidBill = {
      family_id: testData.familyId,
      bulan: 6,
      tahun: 2026
      // nominal tidak diisi
    };

    const resFail = await request(app)
      .post('/api/dues/bills')
      .set('Authorization', `Bearer ${rtToken}`)
      .send(invalidBill);

    expect(resFail.status).toBe(400); // Bad Request karena validasi gagal
    expect(resFail.body.success).toBe(false);
  });
});
