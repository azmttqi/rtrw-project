const request = require('supertest');
const app = require('../../../backend/src/app');
const { seedBaseData } = require('./utils/e2e-seeder');

describe('E2E: Manajemen Pengajuan Surat (Letters)', () => {
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

  it('1. Alur Lengkap: Warga Request Surat -> RT Verifikasi -> RW Verifikasi & Terbit PDF (201, 200)', async () => {
    // === Tahap 1: Warga Mengajukan Surat ===
    const letterPayload = {
      jenis_surat: 'SURAT_PENGANTAR_KTP',
      keterangan_keperluan: 'Pembuatan KTP Baru Warga'
    };

    const resCreate = await request(app)
      .post('/api/letters')
      .set('Authorization', `Bearer ${wargaToken}`)
      .send(letterPayload);

    expect(resCreate.status).toBe(201);
    expect(resCreate.body.success).toBe(true);
    expect(resCreate.body.data.status).toBe('PENDING_RT');
    const letterId = resCreate.body.data.id;

    // === Tahap 2: Warga Melihat Pengajuan di Riwayat Suratnya ===
    const resWargaList = await request(app)
      .get('/api/letters')
      .set('Authorization', `Bearer ${wargaToken}`);

    expect(resWargaList.status).toBe(200);
    const foundLetter = resWargaList.body.data.find(l => l.id === letterId);
    expect(foundLetter).toBeDefined();
    expect(foundLetter.jenis_surat).toBe(letterPayload.jenis_surat);

    // === Tahap 3: RT Menyetujui Surat ===
    const resRTVerify = await request(app)
      .patch(`/api/letters/${letterId}/verify`)
      .set('Authorization', `Bearer ${rtToken}`)
      .send({ status: 'APPROVED' });

    expect(resRTVerify.status).toBe(200);
    expect(resRTVerify.body.success).toBe(true);
    expect(resRTVerify.body.data.status).toBe('APPROVED_RT_PENDING_RW');

    // === Tahap 4: RW Menyetujui Surat & PDF Terbit ===
    const resRWVerify = await request(app)
      .patch(`/api/letters/${letterId}/verify`)
      .set('Authorization', `Bearer ${rwToken}`)
      .send({ status: 'APPROVED' });

    expect(resRWVerify.status).toBe(200);
    expect(resRWVerify.body.success).toBe(true);
    expect(resRWVerify.body.data.status).toBe('APPROVED_RW');
    expect(resRWVerify.body.data.dokumen_hasil_url).toBeDefined();
  });

  it('2. Negative Flow: Warga Gagal Mengajukan Surat jika Data Tidak Lengkap (400)', async () => {
    const invalidPayload = {
      jenis_surat: 'SURAT_PENGANTAR_KTP'
      // keterangan_keperluan missing
    };

    const resFail = await request(app)
      .post('/api/letters')
      .set('Authorization', `Bearer ${wargaToken}`)
      .send(invalidPayload);

    expect(resFail.status).toBe(400);
    expect(resFail.body.success).toBe(false);
  });

  it('3. Negative Flow: RW Gagal Menyetujui Surat yang Belum Disetujui RT (400)', async () => {
    // Buat surat baru yang statusnya PENDING_RT
    const resCreate = await request(app)
      .post('/api/letters')
      .set('Authorization', `Bearer ${wargaToken}`)
      .send({
        jenis_surat: 'SURAT_DOMISILI',
        keterangan_keperluan: 'Buka Rekening Bank'
      });

    const letterId = resCreate.body.data.id;

    // Langsung verifikasi via RW (melompati RT)
    const resRWDirect = await request(app)
      .patch(`/api/letters/${letterId}/verify`)
      .set('Authorization', `Bearer ${rwToken}`)
      .send({ status: 'APPROVED' });

    expect(resRWDirect.status).toBe(400);
    expect(resRWDirect.body.success).toBe(false);
  });
});
