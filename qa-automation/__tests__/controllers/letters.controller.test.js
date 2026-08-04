const lettersController = require('../../../backend/src/controllers/letters.controller');
const letterService = require('../../../backend/src/services/letter.service');
const pool = require('../../../backend/src/config/database');
const fs = require('fs');
const { successResponse, createdResponse, validationErrorResponse, notFoundResponse } = require('../../../backend/src/utils/response');

jest.mock('../../../backend/src/services/letter.service');
jest.mock('../../../backend/src/config/database', () => ({
  query: jest.fn()
}));
jest.mock('../../../backend/src/utils/response');
jest.mock('fs');

describe('Letters Controller', () => {
  let req, res, next;

  beforeEach(() => {
    req = {
      user: { id: 1, is_verified: true, role: 'WARGA', rt_id: 5, rw_id: 10 },
      query: {},
      body: {},
      params: {}
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
      download: jest.fn()
    };
    next = jest.fn();
    jest.clearAllMocks();
  });

  describe('createLetter', () => {
    it('should submit letter request successfully when user is verified and family is approved (Success Path)', async () => {
      req.user.is_verified = true;
      req.body = { jenis_surat: 'SURAT_PENGANTAR_KTP', keterangan_keperluan: 'Perpanjangan KTP' };
      pool.query.mockResolvedValue({ rows: [{ id: 10, status_verifikasi: 'APPROVED' }] });
      const mockLetter = { id: 100, family_id: 10, ...req.body };
      letterService.createLetter.mockResolvedValue(mockLetter);

      await lettersController.createLetter(req, res, next);

      expect(pool.query).toHaveBeenCalledWith(
        'SELECT id, status_verifikasi FROM families WHERE user_id = $1',
        [req.user.id]
      );
      expect(letterService.createLetter).toHaveBeenCalledWith({
        family_id: 10,
        jenis_surat: 'SURAT_PENGANTAR_KTP',
        keterangan_keperluan: 'Perpanjangan KTP'
      });
      expect(createdResponse).toHaveBeenCalledWith(res, 'Pengajuan surat berhasil dikirim', mockLetter);
    });

    it('should return validation error if user is not verified (Negative Path)', async () => {
      req.user.is_verified = false;

      await lettersController.createLetter(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Akun Anda belum diverifikasi oleh RT');
      expect(pool.query).not.toHaveBeenCalled();
    });

    it('should return validation error if user does not belong to any family (Negative Path)', async () => {
      req.user.is_verified = true;
      pool.query.mockResolvedValue({ rows: [] });

      await lettersController.createLetter(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Anda belum terdaftar dalam KK manapun');
    });

    it('should return validation error if family is not approved yet (Negative Path)', async () => {
      req.user.is_verified = true;
      pool.query.mockResolvedValue({ rows: [{ id: 10, status_verifikasi: 'PENDING' }] });

      await lettersController.createLetter(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Data Keluarga (KK) Anda belum disetujui oleh RT');
    });

    it('should return validation error if letterService throws required fields error (Negative Path)', async () => {
      req.user.is_verified = true;
      pool.query.mockResolvedValue({ rows: [{ id: 10, status_verifikasi: 'APPROVED' }] });
      const error = new Error('Jenis surat wajib diisi');
      letterService.createLetter.mockRejectedValue(error);

      await lettersController.createLetter(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Jenis surat wajib diisi');
    });

    it('should call next on generic database error (Negative Path)', async () => {
      req.user.is_verified = true;
      const error = new Error('Database disconnected');
      pool.query.mockRejectedValue(error);

      await lettersController.createLetter(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('getLetters', () => {
    it('should get letters list for the authenticated user (Success Path)', async () => {
      const mockLetters = [{ id: 1, jenis_surat: 'SURAT_PENGANTAR_KTP', status: 'PENDING_RT' }];
      letterService.getLetters.mockResolvedValue(mockLetters);

      await lettersController.getLetters(req, res, next);

      expect(letterService.getLetters).toHaveBeenCalledWith(req.user);
      expect(successResponse).toHaveBeenCalledWith(res, 'Daftar pengajuan surat', mockLetters);
    });

    it('should call next if getLetters fails (Negative Path)', async () => {
      const error = new Error('Failed to fetch letters');
      letterService.getLetters.mockRejectedValue(error);

      await lettersController.getLetters(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('verifyLetter', () => {
    it('should verify letter successfully by RT/RW (Success Path)', async () => {
      req.params.id = '100';
      req.body = { status: 'APPROVED' };
      const mockVerified = { id: 100, status: 'APPROVED_RT' };
      letterService.verifyLetter.mockResolvedValue(mockVerified);

      await lettersController.verifyLetter(req, res, next);

      expect(letterService.verifyLetter).toHaveBeenCalledWith('100', req.user, 'APPROVED');
      expect(successResponse).toHaveBeenCalledWith(res, 'Verifikasi surat berhasil', mockVerified);
    });

    it('should return notFoundResponse if letter not found (Negative Path)', async () => {
      req.params.id = '999';
      req.body = { status: 'APPROVED' };
      const error = new Error('Surat tidak ditemukan');
      letterService.verifyLetter.mockRejectedValue(error);

      await lettersController.verifyLetter(req, res, next);

      expect(notFoundResponse).toHaveBeenCalledWith(res, 'Surat tidak ditemukan');
    });

    it('should return validation error if status is invalid or authority issue (Negative Path)', async () => {
      req.params.id = '100';
      req.body = { status: 'UNKNOWN' };
      const error = new Error('Status surat tidak valid');
      letterService.verifyLetter.mockRejectedValue(error);

      await lettersController.verifyLetter(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Status surat tidak valid');
    });

    it('should call next on generic error during verifyLetter (Negative Path)', async () => {
      req.params.id = '100';
      const error = new Error('DB write failed');
      letterService.verifyLetter.mockRejectedValue(error);

      await lettersController.verifyLetter(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('downloadLetter', () => {
    it('should download letter successfully when file exists (Success Path)', async () => {
      req.params.id = '100';
      letterService.getLetterFile.mockResolvedValue('uploads/letters/surat_100.pdf');
      fs.existsSync.mockReturnValue(true);

      await lettersController.downloadLetter(req, res, next);

      expect(letterService.getLetterFile).toHaveBeenCalledWith('100', req.user);
      expect(res.download).toHaveBeenCalledWith(expect.stringContaining('surat_100.pdf'));
    });

    it('should return validation error if letter document URL is not available (Negative Path)', async () => {
      req.params.id = '100';
      letterService.getLetterFile.mockResolvedValue(null);

      await lettersController.downloadLetter(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Surat belum tersedia atau belum disetujui RW');
      expect(res.download).not.toHaveBeenCalled();
    });

    it('should return notFoundResponse if physical file does not exist on disk (Negative Path)', async () => {
      req.params.id = '100';
      letterService.getLetterFile.mockResolvedValue('uploads/letters/surat_100.pdf');
      fs.existsSync.mockReturnValue(false);

      await lettersController.downloadLetter(req, res, next);

      expect(notFoundResponse).toHaveBeenCalledWith(res, 'File fisik surat tidak ditemukan di server');
      expect(res.download).not.toHaveBeenCalled();
    });

    it('should call next on generic error during downloadLetter (Negative Path)', async () => {
      req.params.id = '100';
      const error = new Error('Disk read error');
      letterService.getLetterFile.mockRejectedValue(error);

      await lettersController.downloadLetter(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });
});
