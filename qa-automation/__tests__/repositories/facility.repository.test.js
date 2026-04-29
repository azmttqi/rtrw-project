const facilityRepository = require('../../../backend/src/repositories/facility.repository');
const userRepository = require('../../../backend/src/repositories/user.repository');
const pool = require('../../../backend/src/config/database');

describe('Facility Repository', () => {
  let rtId, rwId, userId;

  beforeEach(async () => {
    // Setup RT and RW data
    const rwRes = await pool.query(`INSERT INTO rws (nomor_rw, nama_wilayah, alamat) VALUES ('01', 'Test RW', 'Test Alamat') RETURNING id`);
    rwId = rwRes.rows[0].id;

    const rtRes = await pool.query(`INSERT INTO rts (rw_id, nomor_rt) VALUES ($1, '01') RETURNING id`, [rwId]);
    rtId = rtRes.rows[0].id;

    // Setup User
    const user = await userRepository.create({
      nama: 'Facility User',
      no_wa: '08123456783',
      role: 'WARGA',
      rt_id: rtId,
    });
    userId = user.id;
  });

  describe('createFacility', () => {
    it('Success: membuat fasilitas baru', async () => {
      const data = {
        rt_id: rtId,
        nama_fasilitas: 'Lapangan Basket',
        deskripsi: 'Lapangan basket outdoor',
        bisa_dipinjam: true
      };

      const facility = await facilityRepository.createFacility(data);

      expect(facility).toBeDefined();
      expect(facility.nama_fasilitas).toBe('Lapangan Basket');
      expect(facility.bisa_dipinjam).toBe(true);
    });
  });

  describe('createReservation', () => {
    it('Success: membuat reservasi fasilitas', async () => {
      const facility = await facilityRepository.createFacility({
        rt_id: rtId,
        nama_fasilitas: 'Aula',
        bisa_dipinjam: true
      });

      const reservationData = {
        facility_id: facility.id,
        peminjam_user_id: userId,
        tanggal_mulai: '2026-06-01',
        tanggal_selesai: '2026-06-01',
        keterangan: 'Rapat warga'
      };

      const reservation = await facilityRepository.createReservation(reservationData);

      expect(reservation).toBeDefined();
      expect(reservation.status).toBe('PENDING');
      expect(reservation.facility_id).toBe(facility.id);
    });
  });

  describe('checkReservationConflict', () => {
    it('Success: mendeteksi konflik reservasi', async () => {
      const facility = await facilityRepository.createFacility({
        rt_id: rtId,
        nama_fasilitas: 'Aula',
        bisa_dipinjam: true
      });

      await facilityRepository.createReservation({
        facility_id: facility.id,
        peminjam_user_id: userId,
        tanggal_mulai: '2026-06-01',
        tanggal_selesai: '2026-06-05',
        keterangan: 'Booking 1'
      });

      // Conflict: Starts inside
      const conflict1 = await facilityRepository.checkReservationConflict(facility.id, '2026-06-02', '2026-06-03');
      expect(conflict1).toBe(true);

      // No Conflict: Different dates
      const noConflict = await facilityRepository.checkReservationConflict(facility.id, '2026-06-10', '2026-06-15');
      expect(noConflict).toBe(false);
    });
  });
});
