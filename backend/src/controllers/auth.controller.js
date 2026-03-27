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
        user: {
          id: result.user.id,
          nama: result.user.nama,
          no_wa: result.user.no_wa,
          role: result.user.role,
          is_verified: result.user.is_verified,
        },
        token: result.token,
      });
    } catch (error) {
      if (error.message.includes('already registered') || 
          error.message.includes('Invalid invitation') ||
          error.message.includes('already used') ||
          error.message.includes('expired')) {
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
        user: {
          id: result.user.id,
          nama: result.user.nama,
          email: result.user.email,
          role: result.user.role,
          rt_id: result.user.rt_id,
          rw_id: result.user.rw_id,
          is_verified: result.user.is_verified,
        },
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
        user: {
          id: result.user.id,
          nama: result.user.nama,
          no_wa: result.user.no_wa,
          role: result.user.role,
          rt_id: result.user.rt_id,
          rw_id: result.user.rw_id,
          is_verified: result.user.is_verified,
        },
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

