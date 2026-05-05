jest.mock('../../../backend/src/repositories/dues.repository', () => ({
  createSetting: jest.fn(),
  findBillByFamilyAndPeriod: jest.fn(),
  createBill: jest.fn(),
  findPaymentById: jest.fn(),
  verifyPayment: jest.fn(),
  updateBillStatus: jest.fn()
}));
jest.mock('../../../backend/src/repositories/family.repository', () => ({
  findAll: jest.fn().mockResolvedValue({ data: [{ id: 'fam-1' }] }),
  findById: jest.fn().mockResolvedValue({ id: 'fam-1', rt_id: 'rt-1' }),
}));
jest.mock('../../../backend/src/services/notification.service', () => ({
  notifyUser: jest.fn().mockResolvedValue(),
}));


const dueService = require('../../../backend/src/services/due.service');
const mockDueRepository = require('../../../backend/src/repositories/dues.repository');

describe('Due Service', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('createSetting', () => {
    it('Success: membuat setting', async () => {
      mockDueRepository.createSetting.mockResolvedValue({ id: 1, nominal: 50000 });
      const result = await dueService.createSetting({ tingkat: 'WARGA', rt_id: 'rt-1', nominal: 50000, tenggat_tanggal: 10 });
      expect(result.nominal).toBe(50000);
    });

    it('Boundary: nominal iuran tidak boleh 0', async () => {
      try {
        await dueService.createSetting({ tingkat: 'WARGA', rt_id: 'rt-1', nominal: 0, tenggat_tanggal: 10 });
        fail('Should have thrown an error');
      } catch (e) {
        expect(e.message).toBe('Nominal harus lebih besar dari 0');
      }
    });

    it('Negative: nominal iuran tidak boleh negatif', async () => {
      try {
        await dueService.createSetting({ tingkat: 'WARGA', rt_id: 'rt-1', nominal: -1000, tenggat_tanggal: 10 });
        fail('Should have thrown an error');
      } catch (e) {
        expect(e.message).toBe('Nominal harus lebih besar dari 0');
      }
    });

    it('Boundary: tenggat tanggal tidak valid (melebihi 28)', async () => {
      try {
        await dueService.createSetting({ tingkat: 'WARGA', rt_id: 'rt-1', nominal: 50000, tenggat_tanggal: 32 });
        fail('Should have thrown an error');
      } catch (e) {
        expect(e.message).toBe('Tenggat tanggal harus antara 1-28');
      }
    });

  });

  describe('createBill', () => {
    it('Success: membuat tagihan', async () => {
      mockDueRepository.findBillByFamilyAndPeriod.mockResolvedValue(null);
      mockDueRepository.createBill.mockResolvedValue({ id: 1, nominal: 50000 });
      const result = await dueService.createBill({ family_id: 'fam-1', bulan: 5, tahun: 2026, nominal: 50000 });
      expect(result.id).toBe(1);
    });

    it('Negative: tagihan sudah ada', async () => {
      mockDueRepository.findBillByFamilyAndPeriod.mockResolvedValue({ id: 1 });
      await expect(dueService.createBill({ family_id: 'fam-1', bulan: 5, tahun: 2026, nominal: 50000 }))
        .rejects.toThrow('sudah ada');
    });
  });

  describe('verifyPayment', () => {
    it('Success: approve pembayaran', async () => {
      const mockPayment = { id: 'pay-1', status: 'PENDING', due_bills: [{ id: 'bill-1' }] };
      mockDueRepository.findPaymentById.mockResolvedValue(mockPayment);
      mockDueRepository.verifyPayment.mockResolvedValue({ ...mockPayment, status: 'APPROVED' });
      mockDueRepository.updateBillStatus.mockResolvedValue();

      const result = await dueService.verifyPayment('pay-1', 'APPROVED');
      expect(result.status).toBe('APPROVED');
    });
  });
});
