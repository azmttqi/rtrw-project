const request = require('supertest');
const app = require('../../../backend/src/app');
const { seedBaseData } = require('./utils/e2e-seeder');

describe('E2E: Manajemen Pengumuman (Announcements)', () => {
  let rtToken, wargaToken;
  let testData;

  beforeEach(async () => {
    testData = await seedBaseData();

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

  it('1. Alur Lengkap: RT Buat Pengumuman -> Warga Membaca -> RT Update -> RT Delete (201 & 200)', async () => {
    // === Tahap 1: RT Membuat Pengumuman ===
    const newAnnouncement = {
      target: 'WARGA_RT',
      target_rt_id: testData.rtId,
      judul: 'Kerja Bakti Minggu Ini',
      konten: 'Harap seluruh warga berkumpul di lapangan jam 7 pagi.',
      is_kegiatan: true,
      tanggal_kegiatan: '2026-09-10'
    };

    const resCreate = await request(app)
      .post('/api/announcements')
      .set('Authorization', `Bearer ${rtToken}`)
      .send(newAnnouncement);

    expect(resCreate.status).toBe(201);
    expect(resCreate.body.success).toBe(true);
    expect(resCreate.body.data.judul).toBe(newAnnouncement.judul);
    const announcementId = resCreate.body.data.id;

    // === Tahap 2: Warga Melihat Pengumuman ===
    const resList = await request(app)
      .get('/api/announcements')
      .set('Authorization', `Bearer ${wargaToken}`);

    expect(resList.status).toBe(200);
    const found = resList.body.data.announcements.find(a => a.id === announcementId);
    expect(found).toBeDefined();
    expect(found.judul).toBe(newAnnouncement.judul);

    // === Tahap 3: RT Mengubah Pengumuman ===
    const resUpdate = await request(app)
      .patch(`/api/announcements/${announcementId}`)
      .set('Authorization', `Bearer ${rtToken}`)
      .send({ judul: 'Kerja Bakti Dimulai Jam 08.00' });

    expect(resUpdate.status).toBe(200);
    expect(resUpdate.body.success).toBe(true);
    expect(resUpdate.body.data.judul).toBe('Kerja Bakti Dimulai Jam 08.00');

    // === Tahap 4: RT Menghapus Pengumuman ===
    const resDelete = await request(app)
      .delete(`/api/announcements/${announcementId}`)
      .set('Authorization', `Bearer ${rtToken}`);

    expect(resDelete.status).toBe(200);
    expect(resDelete.body.success).toBe(true);
  });

  it('2. Negative Flow: Warga Tidak Memiliki Akses Membuat Pengumuman (403 Forbidden)', async () => {
    const resForbidden = await request(app)
      .post('/api/announcements')
      .set('Authorization', `Bearer ${wargaToken}`)
      .send({
        target: 'WARGA_RT',
        judul: 'Pengumuman Ilegal',
        konten: 'Warga mencoba posting'
      });

    expect(resForbidden.status).toBe(403);
    expect(resForbidden.body.success).toBe(false);
  });

  it('3. Negative Flow: RT Gagal Membuat Pengumuman jika Judul Kosong (400 Bad Request)', async () => {
    const resFail = await request(app)
      .post('/api/announcements')
      .set('Authorization', `Bearer ${rtToken}`)
      .send({
        target: 'WARGA_RT',
        konten: 'Hanya ada konten'
      });

    expect(resFail.status).toBe(400);
    expect(resFail.body.success).toBe(false);
  });
});
