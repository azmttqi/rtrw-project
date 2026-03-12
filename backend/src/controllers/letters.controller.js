const letterService = require('../services/letter.service');
const pool = require('../config/database');
const { successResponse, createdResponse, validationErrorResponse, notFoundResponse } = require('../utils/response');
const path = require('path');
const fs = require('fs');

const lettersController = {
  async createLetter(req, res, next) {
    try {
      // 1. Check if user is verified
      if (!req.user.is_verified) {
          return validationErrorResponse(res, 'Akun Anda belum diverifikasi oleh RT');
      }

      // 2. Get family_id owned by this user
      const resFamily = await pool.query('SELECT id, status_verifikasi FROM families WHERE user_id = $1', [req.user.id]);
      const family = resFamily.rows[0];

      if (!family) {
        return validationErrorResponse(res, 'Anda belum terdaftar dalam KK manapun');
      }

      if (family.status_verifikasi !== 'APPROVED') {
          return validationErrorResponse(res, 'Data Keluarga (KK) Anda belum disetujui oleh RT');
      }

      const { jenis_surat, keterangan_keperluan } = req.body;
      const letter = await letterService.createLetter({
        family_id: family.id,
        jenis_surat,
        keterangan_keperluan
      });

      return createdResponse(res, 'Pengajuan surat berhasil dikirim', letter);
    } catch (error) {
      if (error.message.includes('wajib diisi')) return validationErrorResponse(res, error.message);
      next(error);
    }
  },

  async getLetters(req, res, next) {
    try {
      const letters = await letterService.getLetters(req.user);
      return successResponse(res, 'Daftar pengajuan surat', letters);
    } catch (error) {
      next(error);
    }
  },

  async verifyLetter(req, res, next) {
    try {
      const { id } = req.params;
      const { status } = req.body; // 'APPROVED' | 'REJECTED'
      
      const letter = await letterService.verifyLetter(id, req.user, status);
      return successResponse(res, 'Verifikasi surat berhasil', letter);
    } catch (error) {
      if (error.message.includes('ditemukan')) return notFoundResponse(res, error.message);
      if (error.message.includes('valid') || error.message.includes('wewenang') || error.message.includes('disetujui RT')) {
        return validationErrorResponse(res, error.message);
      }
      next(error);
    }
  },

  async downloadLetter(req, res, next) {
    try {
      const { id } = req.params;
      const docUrl = await letterService.getLetterFile(id, req.user);
      
      if (!docUrl) {
        return validationErrorResponse(res, 'Surat belum tersedia atau belum disetujui RW');
      }

      const filePath = path.join(__dirname, '../../', docUrl);
      if (!fs.existsSync(filePath)) {
        return notFoundResponse(res, 'File fisik surat tidak ditemukan di server');
      }

      res.download(filePath);
    } catch (error) {
      next(error);
    }
  }
};

module.exports = lettersController;
