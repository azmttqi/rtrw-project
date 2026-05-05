const authService = require('../services/auth.service');
const { successResponse, createdResponse, errorResponse, validationErrorResponse } = require('../utils/response');

const authController = {
  async register(req, res, next) {
    try {
      const { nama, no_wa, email, password, role, token_invitation, nomor_rw, alamat, nama_wilayah } = req.body;

      if (!nama || !no_wa || !password) {
        return validationErrorResponse(res, 'Nama, nomor WhatsApp, dan password wajib diisi');
      }

      const result = await authService.register({ 
        nama, no_wa, email, password, role, token_invitation, 
        nomor_rw, alamat, nama_wilayah 
      });

      return createdResponse(res, 'Registrasi berhasil', {
        user: result.user,
        token: result.token,
      });
    } catch (error) {
      const userErrors = [
        'already registered', 'Invalid or expired', 'already used', 'expired',
        'minimal 6 karakter', 'tidak valid', 'wajib diisi', 'tidak sesuai'
      ];

      if (userErrors.some(msg => error.message.includes(msg))) {
        return validationErrorResponse(res, error.message);
      }
      next(error);
    }

  },

  async registerGoogle(req, res, next) {
    try {
      const { idToken, token_invitation } = req.body;

      if (!idToken) {
        return validationErrorResponse(res, 'Google ID Token wajib diisi');
      }

      const result = await authService.registerGoogle({ idToken, token_invitation });

      return successResponse(res, 'Login/Registrasi Google berhasil', {
        user: result.user,
        token: result.token,
      });
    } catch (error) {
      if (error.message.includes('Invalid or expired invitation')) {
        return validationErrorResponse(res, error.message);
      }
      next(error);
    }
  },

  async login(req, res, next) {
    try {
      const { no_wa, password } = req.body;

      if (!no_wa || !password) {
        return validationErrorResponse(res, 'Nomor WhatsApp dan password wajib diisi');
      }

      const result = await authService.login({ no_wa, password });

      return successResponse(res, 'Login berhasil', {
        user: result.user,
        token: result.token,
      });
    } catch (error) {
      if (error.message === 'Invalid credentials') {
        return validationErrorResponse(res, 'Nomor WhatsApp atau password salah');
      }
      next(error);
    }
  },

  async getProfile(req, res, next) {
    try {
      const user = await authService.getProfile(req.user.id);
      return successResponse(res, 'Profile retrieved', user);
    } catch (error) {
      next(error);
    }
  },

  async updateProfile(req, res, next) {
    try {
      const { nama } = req.body;
      const user = await authService.updateProfile(req.user.id, { nama });
      return successResponse(res, 'Profile updated', user);
    } catch (error) {
      next(error);
    }
  },

  async verifyEmail(req, res, next) {
    try {
      const { identifier, otp } = req.body;
      if (!identifier || !otp) {
        return validationErrorResponse(res, 'Identifier and OTP are required');
      }
      const user = await authService.verifyEmail({ identifier, otp });
      return successResponse(res, 'Email berhasil diverifikasi', {
        id: user.id,
        nama: user.nama,
        is_verified: user.is_verified
      });
    } catch (error) {
      return validationErrorResponse(res, error.message);
    }
  },
};

module.exports = authController;

