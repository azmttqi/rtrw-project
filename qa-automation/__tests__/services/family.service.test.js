jest.mock('../../../backend/src/repositories/family.repository', () => ({
  findByNoKK: jest.fn(),
  create: jest.fn(),
  findById: jest.fn(),
  update: jest.fn(),
}));

jest.mock('../../../backend/src/repositories/user.repository', () => ({
  update: jest.fn(),
}));

const familyService = require('../../../backend/src/services/family.service');
const mockFamilyRepository = require('../../../backend/src/repositories/family.repository');
const mockUserRepository = require('../../../backend/src/repositories/user.repository');

describe('Family Service', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('createFamily', () => {
    const payload = { rt_id: 'rt-1', no_kk: '1234', tipe_warga: 'TETAP', status_tinggal: 'KONTRAK', status_pernikahan: 'MENIKAH', documents: [] };

    it('Success: membuat keluarga', async () => {
      mockFamilyRepository.findByNoKK.mockResolvedValue(null);
      mockFamilyRepository.create.mockResolvedValue({ id: 1, ...payload });

      const result = await familyService.createFamily('u-1', payload);
      expect(result.no_kk).toBe('1234');
    });

    it('Negative: field tidak lengkap', async () => {
      await expect(familyService.createFamily('u-1', { rt_id: 'rt-1' })).rejects.toThrow('tidak lengkap');
    });

    it('Negative: nomor KK sudah ada', async () => {
      mockFamilyRepository.findByNoKK.mockResolvedValue({ id: 1 });
      await expect(familyService.createFamily('u-1', payload)).rejects.toThrow('sudah terdaftar');
    });
  });

  describe('verifyFamily', () => {
    it('Success: RT verify APPROVED', async () => {
      const mockFamily = { id: 1, user_id: 'u-1', status_verifikasi: 'PENDING' };
      mockFamilyRepository.findById.mockResolvedValue(mockFamily);
      mockFamilyRepository.update.mockResolvedValue({ ...mockFamily, status_verifikasi: 'APPROVED' });
      mockUserRepository.update.mockResolvedValue();

      const result = await familyService.verifyFamily(1, 'APPROVED');
      expect(result.status_verifikasi).toBe('APPROVED');
      expect(mockUserRepository.update).toHaveBeenCalledWith('u-1', { is_verified: true });
    });

    it('Negative: status tidak valid', async () => {
      await expect(familyService.verifyFamily(1, 'INVALID')).rejects.toThrow('Status tidak valid');
    });
  });
});
