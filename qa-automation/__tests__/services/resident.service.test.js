const residentService = require('../../../backend/src/services/resident.service');
const residentRepository = require('../../../backend/src/repositories/resident.repository');

jest.mock('../../../backend/src/repositories/resident.repository');

describe('Resident Service', () => {
  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('getResidentsByFamily', () => {
    it('should throw Error if familyId is missing', async () => {
      await expect(residentService.getResidentsByFamily(null)).rejects.toThrow('Family ID diperlukan');
    });

    it('should return residents from repository', async () => {
      residentRepository.findByFamilyId.mockResolvedValue([{ id: 1 }]);
      const result = await residentService.getResidentsByFamily(1);
      expect(residentRepository.findByFamilyId).toHaveBeenCalledWith(1);
      expect(result).toEqual([{ id: 1 }]);
    });
  });

  describe('addResident', () => {
    const validData = {
      family_id: 1,
      nik: '1234567890',
      nama_lengkap: 'Budi',
      jenis_kelamin: 'L',
      tanggal_lahir: '1990-01-01',
      hubungan_keluarga: 'KEPALA KELUARGA'
    };

    it('should throw Error if data is incomplete', async () => {
      await expect(residentService.addResident({ family_id: 1 })).rejects.toThrow('Data anggota keluarga tidak lengkap');
    });

    it('should throw Error if NIK already exists', async () => {
      residentRepository.findByNik.mockResolvedValue({ id: 2 });
      await expect(residentService.addResident(validData)).rejects.toThrow('NIK sudah terdaftar');
    });

    it('should create resident if data is valid', async () => {
      residentRepository.findByNik.mockResolvedValue(null);
      residentRepository.create.mockResolvedValue({ id: 1, ...validData });
      
      const result = await residentService.addResident(validData);
      
      expect(residentRepository.create).toHaveBeenCalledWith(validData);
      expect(result.id).toBe(1);
    });
  });

  describe('updateResident', () => {
    it('should throw Error if resident not found', async () => {
      residentRepository.update.mockResolvedValue(null);
      await expect(residentService.updateResident(1, {})).rejects.toThrow('Anggota keluarga tidak ditemukan');
    });

    it('should update resident and return it', async () => {
      const data = { nik: '123' };
      residentRepository.update.mockResolvedValue({ id: 1, ...data });
      
      const result = await residentService.updateResident(1, data);
      
      expect(residentRepository.update).toHaveBeenCalledWith(1, data);
      expect(result.id).toBe(1);
    });
  });

  describe('deleteResident', () => {
    it('should throw Error if resident not found', async () => {
      residentRepository.delete.mockResolvedValue(null);
      await expect(residentService.deleteResident(1)).rejects.toThrow('Anggota keluarga tidak ditemukan');
    });

    it('should delete resident and return it', async () => {
      residentRepository.delete.mockResolvedValue({ id: 1 });
      const result = await residentService.deleteResident(1);
      expect(residentRepository.delete).toHaveBeenCalledWith(1);
      expect(result.id).toBe(1);
    });
  });
});
