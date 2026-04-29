jest.mock('../../../backend/src/repositories/facility.repository', () => ({
  createFacility: jest.fn(),
  getFacilityById: jest.fn(),
  checkReservationConflict: jest.fn(),
  createReservation: jest.fn()
}));

const facilityService = require('../../../backend/src/services/facility.service');
const mockFacilityRepository = require('../../../backend/src/repositories/facility.repository');

describe('Facility Service', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('createFacility', () => {
    it('Success: membuat fasilitas', async () => {
      const payload = { nama_fasilitas: 'Aula', rt_id: 'rt-1', bisa_dipinjam: true };
      mockFacilityRepository.createFacility.mockResolvedValue({ id: 1, ...payload });
      const result = await facilityService.createFacility(payload);
      expect(result.nama_fasilitas).toBe('Aula');
    });

    it('Negative: nama kosong', async () => {
      await expect(facilityService.createFacility({ rt_id: 'rt-1' })).rejects.toThrow('wajib diisi');
    });
  });

  describe('createReservation', () => {
    it('Success: membuat reservasi', async () => {
      mockFacilityRepository.getFacilityById.mockResolvedValue({ id: 1, bisa_dipinjam: true });
      mockFacilityRepository.checkReservationConflict.mockResolvedValue(false);
      mockFacilityRepository.createReservation.mockResolvedValue({ id: 'res-1' });

      const result = await facilityService.createReservation({
        facility_id: 1, peminjam_user_id: 'u-1', tanggal_mulai: '2026-05-01', tanggal_selesai: '2026-05-02'
      });
      expect(result.id).toBe('res-1');
    });

    it('Negative: fasilitas tidak bisa dipinjam', async () => {
      mockFacilityRepository.getFacilityById.mockResolvedValue({ id: 1, bisa_dipinjam: false });
      await expect(facilityService.createReservation({
        facility_id: 1, peminjam_user_id: 'u-1', tanggal_mulai: '2026-05-01', tanggal_selesai: '2026-05-02'
      })).rejects.toThrow('tidak diperuntukkan');
    });

    it('Negative: fasilitas sudah dibooking', async () => {
      mockFacilityRepository.getFacilityById.mockResolvedValue({ id: 1, bisa_dipinjam: true });
      mockFacilityRepository.checkReservationConflict.mockResolvedValue(true);
      await expect(facilityService.createReservation({
        facility_id: 1, peminjam_user_id: 'u-1', tanggal_mulai: '2026-05-01', tanggal_selesai: '2026-05-02'
      })).rejects.toThrow('sudah dibooking');
    });
  });
});
