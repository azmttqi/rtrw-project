const request = require('supertest');
const app = require('../../../backend/src/app');
const { seedBaseData } = require('./utils/e2e-seeder');

describe('E2E: Manajemen Fasilitas dan Reservasi (Facilities)', () => {
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

  it('1. Alur Lengkap: RT Tambah Fasilitas -> Warga Pinjam -> RT Setujui Peminjaman (201 & 200)', async () => {
    // === Tahap 1: RT Menambahkan Fasilitas ===
    const newFacility = {
      nama_fasilitas: 'Lapangan Badminton E2E',
      deskripsi: 'Fasilitas lapangan olahraga',
      foto_url: 'http://example.com/field.jpg',
      alamat: 'Blok C No. 1',
      koordinat_maps_url: 'http://maps.google.com',
      bisa_dipinjam: true
    };

    const resCreate = await request(app)
      .post('/api/facilities')
      .set('Authorization', `Bearer ${rtToken}`)
      .send(newFacility);

    expect(resCreate.status).toBe(201);
    expect(resCreate.body.success).toBe(true);
    expect(resCreate.body.data.nama_fasilitas).toBe(newFacility.nama_fasilitas);
    const facilityId = resCreate.body.data.id;

    // === Tahap 2: Warga Melihat Daftar Fasilitas ===
    const resList = await request(app)
      .get('/api/facilities')
      .set('Authorization', `Bearer ${wargaToken}`);

    expect(resList.status).toBe(200);
    const foundFacility = resList.body.data.find(f => f.id === facilityId);
    expect(foundFacility).toBeDefined();

    // === Tahap 3: Warga Mengajukan Reservasi / Peminjaman Fasilitas ===
    const reservationData = {
      tanggal_mulai: '2026-10-01 08:00:00',
      tanggal_selesai: '2026-10-01 11:00:00',
      keterangan: 'Latihan Bulutangkis Warga'
    };

    const resReserve = await request(app)
      .post(`/api/facilities/${facilityId}/reserve`)
      .set('Authorization', `Bearer ${wargaToken}`)
      .send(reservationData);

    expect(resReserve.status).toBe(201);
    expect(resReserve.body.success).toBe(true);
    const reservationId = resReserve.body.data.id;

    // === Tahap 4: RT Melihat Pengajuan Peminjaman ===
    const resReservations = await request(app)
      .get('/api/facilities/reservations/all')
      .set('Authorization', `Bearer ${rtToken}`);

    expect(resReservations.status).toBe(200);
    const foundReservation = resReservations.body.data.find(r => r.id === reservationId);
    expect(foundReservation).toBeDefined();

    // === Tahap 5: RT Menyetujui Reservasi ===
    const resVerify = await request(app)
      .patch(`/api/facilities/reservations/${reservationId}/verify`)
      .set('Authorization', `Bearer ${rtToken}`)
      .send({ status: 'APPROVED' });

    expect(resVerify.status).toBe(200);
    expect(resVerify.body.success).toBe(true);
    expect(resVerify.body.data.status).toBe('APPROVED');
  });

  it('2. Negative Flow: Warga Gagal Reservasi Fasilitas yang Tidak Terdaftar (404)', async () => {
    const resFail = await request(app)
      .post('/api/facilities/999999/reserve')
      .set('Authorization', `Bearer ${wargaToken}`)
      .send({
        tanggal_mulai: '2026-10-01 08:00:00',
        tanggal_selesai: '2026-10-01 11:00:00',
        keterangan: 'Booking'
      });

    expect(resFail.status).toBe(404);
    expect(resFail.body.success).toBe(false);
  });
});
