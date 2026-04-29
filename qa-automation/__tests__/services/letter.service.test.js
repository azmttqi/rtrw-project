jest.mock('../../../backend/src/repositories/letter.repository', () => ({
  createLetter: jest.fn(),
  getLetterById: jest.fn(),
  updateLetterStatus: jest.fn(),
}));

const letterService = require('../../../backend/src/services/letter.service');
const mockLetterRepository = require('../../../backend/src/repositories/letter.repository');

describe('Letter Service', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('createLetter', () => {
    it('Success: membuat pengajuan surat', async () => {
      const payload = { family_id: 'fam-1', jenis_surat: 'DOMISILI', keterangan_keperluan: 'Test' };
      mockLetterRepository.createLetter.mockResolvedValue({ id: 1, ...payload });
      
      const result = await letterService.createLetter(payload);
      expect(result.jenis_surat).toBe('DOMISILI');
    });

    it('Negative: field kosong', async () => {
      await expect(letterService.createLetter({ family_id: 'fam-1' }))
        .rejects.toThrow('wajib diisi');
    });
  });

  describe('verifyLetter', () => {
    it('Success: RT menyetujui surat warga', async () => {
      const mockLetter = { id: 1, rt_id: 'rt-1', status: 'PENDING_RT' };
      const mockUser = { role: 'RT', rt_id: 'rt-1' };
      
      mockLetterRepository.getLetterById.mockResolvedValue(mockLetter);
      mockLetterRepository.updateLetterStatus.mockResolvedValue({ ...mockLetter, status: 'APPROVED_RT_PENDING_RW' });

      const result = await letterService.verifyLetter(1, mockUser, 'APPROVED');
      expect(result.status).toBe('APPROVED_RT_PENDING_RW');
    });

    it('Negative: RT memverifikasi surat dari RT lain', async () => {
      const mockLetter = { id: 1, rt_id: 'rt-2', status: 'PENDING_RT' };
      const mockUser = { role: 'RT', rt_id: 'rt-1' };
      
      mockLetterRepository.getLetterById.mockResolvedValue(mockLetter);
      await expect(letterService.verifyLetter(1, mockUser, 'APPROVED'))
        .rejects.toThrow('wewenang');
    });

    it('Negative: RW memverifikasi surat yang belum disetujui RT', async () => {
      const mockLetter = { id: 1, rt_id: 'rt-1', rw_id: 'rw-1', status: 'PENDING_RT' };
      const mockUser = { role: 'RW', rw_id: 'rw-1' };
      
      mockLetterRepository.getLetterById.mockResolvedValue(mockLetter);
      await expect(letterService.verifyLetter(1, mockUser, 'APPROVED'))
        .rejects.toThrow('disetujui RT terlebih dahulu');
    });
  });
});
