const request = require('supertest');

jest.mock('../../../backend/src/middleware/auth.middleware', () => ({
  authenticate: (req, _res, next) => {
    req.user = { id: 'user-1', role: 'RT', rt_id: 'rt-1', rw_id: 'rw-1' };
    next();
  },
}));

jest.mock('../../../backend/src/services/facility.service');
const facilityService = require('../../../backend/src/services/facility.service');

const app = require('../../../backend/src/app');

const MOCK_FACILITY    = { id: 'fac-1', nama_fasilitas: 'Aula RT', bisa_dipinjam: true };
const MOCK_RESERVATION = { id: 'res-1', facility_id: 'fac-1', status: 'PENDING' };

describe('Facilities API Integration Tests', () => {
  beforeEach(() => jest.clearAllMocks());

  // ── POST /api/facilities ────────────────────────────────────────────────
  describe('POST /api/facilities', () => {
    it('Success: menambahkan fasilitas baru', async () => {
      facilityService.createFacility.mockResolvedValue(MOCK_FACILITY);

      const res = await request(app).post('/api/facilities').send({
        nama_fasilitas: 'Aula RT', bisa_dipinjam: true,
      });
      expect(res.status).toBe(201);
      expect(res.body.data.nama_fasilitas).toBe('Aula RT');
    });

    it('Negative: nama fasilitas wajib diisi', async () => {
      facilityService.createFacility.mockRejectedValue(new Error('nama_fasilitas wajib diisi'));

      const res = await request(app).post('/api/facilities').send({});
      expect(res.status).toBe(400);
    });
  });

  // ── GET /api/facilities ─────────────────────────────────────────────────
  describe('GET /api/facilities', () => {
    it('Success: mendapatkan daftar fasilitas', async () => {
      facilityService.getFacilities.mockResolvedValue([MOCK_FACILITY]);

      const res = await request(app).get('/api/facilities');
      expect(res.status).toBe(200);
      expect(res.body.data).toHaveLength(1);
    });

    it('Negative: error dari service', async () => {
      facilityService.getFacilities.mockRejectedValue(new Error('DB Error'));

      const res = await request(app).get('/api/facilities');
      expect(res.status).toBe(500);
    });
  });

  // ── PATCH /api/facilities/:id ───────────────────────────────────────────
  describe('PATCH /api/facilities/:id', () => {
    it('Success: update fasilitas', async () => {
      const updated = { ...MOCK_FACILITY, nama_fasilitas: 'Gedung Serbaguna' };
      facilityService.updateFacility.mockResolvedValue(updated);

      const res = await request(app)
        .patch('/api/facilities/fac-1')
        .send({ nama_fasilitas: 'Gedung Serbaguna' });

      expect(res.status).toBe(200);
      expect(res.body.data.nama_fasilitas).toBe('Gedung Serbaguna');
    });

    it('Negative: fasilitas tidak ditemukan', async () => {
      facilityService.updateFacility.mockRejectedValue(new Error('Fasilitas tidak ditemukan'));

      const res = await request(app).patch('/api/facilities/not-exist').send({ nama_fasilitas: 'x' });
      expect(res.status).toBe(404);
    });
  });

  // ── DELETE /api/facilities/:id ──────────────────────────────────────────
  describe('DELETE /api/facilities/:id', () => {
    it('Success: menghapus fasilitas', async () => {
      facilityService.deleteFacility.mockResolvedValue(undefined);

      const res = await request(app).delete('/api/facilities/fac-1');
      expect(res.status).toBe(200);
    });

    it('Negative: fasilitas tidak ditemukan', async () => {
      facilityService.deleteFacility.mockRejectedValue(new Error('Fasilitas tidak ditemukan'));

      const res = await request(app).delete('/api/facilities/not-exist');
      expect(res.status).toBe(404);
    });
  });

  // ── POST /api/facilities/:id/reserve ────────────────────────────────────
  describe('POST /api/facilities/:id/reserve', () => {
    it('Success: membuat pengajuan peminjaman', async () => {
      facilityService.createReservation.mockResolvedValue(MOCK_RESERVATION);

      const res = await request(app)
        .post('/api/facilities/fac-1/reserve')
        .send({ tanggal_mulai: '2026-05-01', tanggal_selesai: '2026-05-01' });

      expect(res.status).toBe(201);
    });

    it('Negative: data tidak lengkap', async () => {
      facilityService.createReservation.mockRejectedValue(new Error('Data tidak lengkap'));

      const res = await request(app).post('/api/facilities/fac-1/reserve').send({});
      expect(res.status).toBe(400);
    });

    it('Negative: fasilitas sudah dibooking', async () => {
      facilityService.createReservation.mockRejectedValue(new Error('Fasilitas sudah dibooking pada tanggal tersebut'));

      const res = await request(app)
        .post('/api/facilities/fac-1/reserve')
        .send({ tanggal_mulai: '2026-05-01', tanggal_selesai: '2026-05-01' });

      expect(res.status).toBe(400);
    });
  });

  // ── GET /api/facilities/reservations/all ────────────────────────────────
  describe('GET /api/facilities/reservations/all', () => {
    it('Success: mendapatkan daftar pengajuan peminjaman', async () => {
      facilityService.getReservations.mockResolvedValue([MOCK_RESERVATION]);

      const res = await request(app).get('/api/facilities/reservations/all');
      expect(res.status).toBe(200);
      expect(res.body.data).toHaveLength(1);
    });
  });

  // ── PATCH /api/facilities/reservations/:id/verify ──────────────────────
  describe('PATCH /api/facilities/reservations/:id/verify', () => {
    it('Success: pengajuan disetujui', async () => {
      facilityService.verifyReservation.mockResolvedValue({ ...MOCK_RESERVATION, status: 'APPROVED' });

      const res = await request(app)
        .patch('/api/facilities/reservations/res-1/verify')
        .send({ status: 'APPROVED' });

      expect(res.status).toBe(200);
    });

    it('Negative: status tidak valid', async () => {
      facilityService.verifyReservation.mockRejectedValue(new Error('Status tidak valid'));

      const res = await request(app)
        .patch('/api/facilities/reservations/res-1/verify')
        .send({ status: 'WRONG' });

      expect(res.status).toBe(400);
    });

    it('Negative: pengajuan tidak ditemukan', async () => {
      facilityService.verifyReservation.mockRejectedValue(new Error('Pengajuan tidak ditemukan'));

      const res = await request(app)
        .patch('/api/facilities/reservations/not-exist/verify')
        .send({ status: 'APPROVED' });

      expect(res.status).toBe(404);
    });
  });
});
