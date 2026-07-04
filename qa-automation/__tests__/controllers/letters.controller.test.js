const lettersController = require('../../../backend/src/controllers/letters.controller');
const letterService = require('../../../backend/src/services/letter.service');
const pool = require('../../../backend/src/config/database');
const fs = require('fs');
const { successResponse, createdResponse, validationErrorResponse, notFoundResponse } = require('../../../backend/src/utils/response');

jest.mock('../../../backend/src/services/letter.service');
jest.mock('../../../backend/src/config/database');
jest.mock('fs');
jest.mock('../../../backend/src/utils/response');

describe('Letters Controller', () => {
  let req, res, next;

  beforeEach(() => {
    req = {
      body: {},
      params: {},
      user: {}
    };
    res = {
      download: jest.fn()
    };
    next = jest.fn();
    jest.clearAllMocks();
  });

  describe('createLetter', () => {
    it('should create letter and return 201 (Success Path)', async () => {
      req.user = { id: 1, is_verified: true };
      req.body = { jenis_surat: 'PENGANTAR', keterangan_keperluan: 'KTP' };
      
      const mockFamily = { id: 1, status_verifikasi: 'APPROVED' };
      pool.query.mockResolvedValue({ rows: [mockFamily] });
      
      const mockLetter = { id: 1 };
      letterService.createLetter.mockResolvedValue(mockLetter);

      await lettersController.createLetter(req, res, next);

      expect(letterService.createLetter).toHaveBeenCalledWith({
        family_id: 1, jenis_surat: 'PENGANTAR', keterangan_keperluan: 'KTP'
      });
      expect(createdResponse).toHaveBeenCalledWith(res, 'Pengajuan surat berhasil dikirim', mockLetter);
    });

    it('should return validation error if user not verified (Negative Path)', async () => {
      req.user = { is_verified: false };

      await lettersController.createLetter(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Akun Anda belum diverifikasi oleh RT');
    });

    it('should return validation error if family not found (Negative Path)', async () => {
      req.user = { id: 1, is_verified: true };
      pool.query.mockResolvedValue({ rows: [] });

      await lettersController.createLetter(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Anda belum terdaftar dalam KK manapun');
    });

    it('should return validation error if family not approved (Negative Path)', async () => {
      req.user = { id: 1, is_verified: true };
      pool.query.mockResolvedValue({ rows: [{ id: 1, status_verifikasi: 'PENDING' }] });

      await lettersController.createLetter(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Data Keluarga (KK) Anda belum disetujui oleh RT');
    });
    
    it('should handle service validation errors (Negative Path)', async () => {
      req.user = { id: 1, is_verified: true };
      pool.query.mockResolvedValue({ rows: [{ id: 1, status_verifikasi: 'APPROVED' }] });
      letterService.createLetter.mockRejectedValue(new Error('Jenis surat wajib diisi'));

      await lettersController.createLetter(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Jenis surat wajib diisi');
    });
  });

  describe('getLetters', () => {
    it('should return letters (Success Path)', async () => {
      req.user = { id: 1 };
      const mockLetters = [{ id: 1 }];
      letterService.getLetters.mockResolvedValue(mockLetters);

      await lettersController.getLetters(req, res, next);

      expect(letterService.getLetters).toHaveBeenCalledWith(req.user);
      expect(successResponse).toHaveBeenCalledWith(res, 'Daftar pengajuan surat', mockLetters);
    });
  });

  describe('verifyLetter', () => {
    it('should verify letter and return 200 (Success Path)', async () => {
      req.params.id = '1';
      req.user = { role: 'RT' };
      req.body = { status: 'APPROVED' };
      const mockLetter = { id: 1 };
      letterService.verifyLetter.mockResolvedValue(mockLetter);

      await lettersController.verifyLetter(req, res, next);

      expect(letterService.verifyLetter).toHaveBeenCalledWith('1', req.user, 'APPROVED');
      expect(successResponse).toHaveBeenCalledWith(res, 'Verifikasi surat berhasil', mockLetter);
    });
    
    it('should handle not found error (Negative Path)', async () => {
      req.params.id = '1';
      letterService.verifyLetter.mockRejectedValue(new Error('tidak ditemukan'));

      await lettersController.verifyLetter(req, res, next);

      expect(notFoundResponse).toHaveBeenCalledWith(res, 'tidak ditemukan');
    });

    it('should handle validation errors (Negative Path)', async () => {
      req.params.id = '1';
      letterService.verifyLetter.mockRejectedValue(new Error('tidak valid'));

      await lettersController.verifyLetter(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'tidak valid');
    });
  });

  describe('downloadLetter', () => {
    it('should download letter if file exists (Success Path)', async () => {
      req.params.id = '1';
      req.user = { id: 1 };
      letterService.getLetterFile.mockResolvedValue('test.pdf');
      fs.existsSync.mockReturnValue(true);

      await lettersController.downloadLetter(req, res, next);

      expect(res.download).toHaveBeenCalled();
    });

    it('should return validation error if docUrl not provided (Negative Path)', async () => {
      req.params.id = '1';
      letterService.getLetterFile.mockResolvedValue(null);

      await lettersController.downloadLetter(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Surat belum tersedia atau belum disetujui RW');
    });

    it('should return not found if file does not exist (Negative Path)', async () => {
      req.params.id = '1';
      letterService.getLetterFile.mockResolvedValue('test.pdf');
      fs.existsSync.mockReturnValue(false);

      await lettersController.downloadLetter(req, res, next);

      expect(notFoundResponse).toHaveBeenCalledWith(res, 'File fisik surat tidak ditemukan di server');
    });
  });
});
