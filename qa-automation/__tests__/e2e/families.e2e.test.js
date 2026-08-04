const request = require('supertest');
const app = require('../../../backend/src/app');
const { seedBaseData } = require('./utils/e2e-seeder');

describe('E2E: Manajemen Keluarga / KK (Families)', () => {
  let rtToken;
  let testData;

  beforeEach(async () => {
    testData = await seedBaseData();

    // Login RT
    const resRT = await request(app)
      .post('/api/auth/login')
      .send({ no_wa: '081200000001', password: 'password123' });
    rtToken = resRT.body.data.token;
  });

  it('1. Alur Lengkap: Warga Baru Daftar KK -> Cek Profil KK -> RT Verifikasi KK (201 & 200)', async () => {
    // === Tahap 1: Buat Warga Baru ===
    const newCitizen = {
      nama: 'Warga Baru KK',
      no_wa: '081288889999',
      email: 'wargabaru@test.com',
      password: 'password123',
      role: 'WARGA'
    };

    const resReg = await request(app)
      .post('/api/auth/register')
      .send(newCitizen);

    expect(resReg.status).toBe(201);
    const newCitizenToken = resReg.body.data.token;

    // === Tahap 2: Warga Baru Mendaftarkan Kartu Keluarga ===
    const familyPayload = {
      rt_id: testData.rtId,
      no_kk: '3201999988880001',
      tipe_warga: 'TETAP',
      status_tinggal: 'RUMAH_SENDIRI',
      status_pernikahan: 'MENIKAH'
    };

    const resCreateFamily = await request(app)
      .post('/api/families')
      .set('Authorization', `Bearer ${newCitizenToken}`)
      .send(familyPayload);

    expect(resCreateFamily.status).toBe(201);
    expect(resCreateFamily.body.success).toBe(true);
    expect(resCreateFamily.body.data.status_verifikasi).toBe('PENDING');
    const familyId = resCreateFamily.body.data.id;

    // === Tahap 3: Warga Mengecek Data Keluarganya Sendiri ===
    const resMyFamily = await request(app)
      .get('/api/families/me')
      .set('Authorization', `Bearer ${newCitizenToken}`);

    expect(resMyFamily.status).toBe(200);
    expect(resMyFamily.body.success).toBe(true);
    expect(resMyFamily.body.data.no_kk).toBe(familyPayload.no_kk);

    // === Tahap 4: RT Melihat Daftar Keluarga ===
    const resRTList = await request(app)
      .get('/api/families')
      .set('Authorization', `Bearer ${rtToken}`);

    expect(resRTList.status).toBe(200);
    const foundFamily = resRTList.body.data.families.find(f => f.id === familyId);
    expect(foundFamily).toBeDefined();

    // === Tahap 5: RT Menyetujui Pendaftaran KK ===
    const resVerify = await request(app)
      .patch(`/api/families/${familyId}/verify`)
      .set('Authorization', `Bearer ${rtToken}`)
      .send({ status: 'APPROVED' });

    expect(resVerify.status).toBe(200);
    expect(resVerify.body.success).toBe(true);
    expect(resVerify.body.data.status_verifikasi).toBe('APPROVED');
  });

  it('2. Negative Flow: Gagal Mendaftarkan KK dengan Nomor KK yang Sudah Ada (400)', async () => {
    // Buat warga baru lain
    const resReg = await request(app)
      .post('/api/auth/register')
      .send({
        nama: 'Warga Duplikat KK',
        no_wa: '081277776666',
        password: 'password123',
        role: 'WARGA'
      });

    const citizenToken = resReg.body.data.token;

    // Coba daftarkan KK dengan no_kk yang sudah ada di seeder (1234567890123456)
    const resDuplicate = await request(app)
      .post('/api/families')
      .set('Authorization', `Bearer ${citizenToken}`)
      .send({
        rt_id: testData.rtId,
        no_kk: '1234567890123456',
        tipe_warga: 'TETAP',
        status_tinggal: 'RUMAH_SENDIRI',
        status_pernikahan: 'MENIKAH'
      });

    expect(resDuplicate.status).toBe(400);
    expect(resDuplicate.body.success).toBe(false);
  });

  it('3. Negative Flow: Warga Tidak Memiliki Hak Akses Menyetujui KK (403 Forbidden)', async () => {
    // Login warga biasa
    const resWarga = await request(app)
      .post('/api/auth/login')
      .send({ no_wa: '081200000002', password: 'password123' });
    const wargaToken = resWarga.body.data.token;

    const resForbidden = await request(app)
      .patch(`/api/families/${testData.familyId}/verify`)
      .set('Authorization', `Bearer ${wargaToken}`)
      .send({ status: 'APPROVED' });

    expect(resForbidden.status).toBe(403);
    expect(resForbidden.body.success).toBe(false);
  });
});
