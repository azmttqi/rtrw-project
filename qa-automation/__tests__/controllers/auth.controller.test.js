const authController = require('../../../backend/src/controllers/auth.controller');
const authService = require('../../../backend/src/services/auth.service');
const { successResponse, createdResponse, validationErrorResponse } = require('../../../backend/src/utils/response');

jest.mock('../../../backend/src/services/auth.service');
jest.mock('../../../backend/src/utils/response');

describe('Auth Controller', () => {
  let req, res, next;

  beforeEach(() => {
    req = {
      user: { id: 1, role: 'WARGA' },
      query: {},
      body: {},
      params: {}
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
    next = jest.fn();
    jest.clearAllMocks();
  });

  describe('register', () => {
    it('should register a new user successfully (Success Path)', async () => {
      req.body = {
        nama: 'Ahmad Fauzi',
        no_wa: '081234567890',
        email: 'ahmad@example.com',
        password: 'password123',
        role: 'WARGA'
      };
      const mockResult = {
        user: { id: 1, nama: 'Ahmad Fauzi', no_wa: '081234567890' },
        token: 'mock-jwt-token'
      };
      authService.register.mockResolvedValue(mockResult);

      await authController.register(req, res, next);

      expect(authService.register).toHaveBeenCalledWith(expect.objectContaining({
        nama: req.body.nama,
        no_wa: req.body.no_wa,
        password: req.body.password
      }));
      expect(createdResponse).toHaveBeenCalledWith(res, 'Registrasi berhasil', {
        user: mockResult.user,
        token: mockResult.token
      });
    });

    it('should return validation error if required fields (nama, no_wa, password) are missing (Negative Path)', async () => {
      req.body = { nama: 'Ahmad' }; // missing no_wa & password

      await authController.register(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Nama, nomor WhatsApp, dan password wajib diisi');
      expect(authService.register).not.toHaveBeenCalled();
    });

    it('should return validation error if service throws known user error (Negative Path)', async () => {
      req.body = {
        nama: 'Ahmad Fauzi',
        no_wa: '081234567890',
        password: '123'
      };
      const error = new Error('Password minimal 6 karakter');
      authService.register.mockRejectedValue(error);

      await authController.register(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Password minimal 6 karakter');
    });

    it('should call next on unexpected service error (Negative Path)', async () => {
      req.body = {
        nama: 'Ahmad Fauzi',
        no_wa: '081234567890',
        password: 'password123'
      };
      const error = new Error('Database connection failed');
      authService.register.mockRejectedValue(error);

      await authController.register(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('registerGoogle', () => {
    it('should login/register with Google token successfully (Success Path)', async () => {
      req.body = { idToken: 'valid-google-id-token', token_invitation: 'invite-123' };
      const mockResult = {
        user: { id: 2, email: 'google@gmail.com' },
        token: 'mock-jwt-token'
      };
      authService.registerGoogle.mockResolvedValue(mockResult);

      await authController.registerGoogle(req, res, next);

      expect(authService.registerGoogle).toHaveBeenCalledWith(req.body);
      expect(successResponse).toHaveBeenCalledWith(res, 'Login/Registrasi Google berhasil', mockResult);
    });

    it('should return validation error if idToken is missing (Negative Path)', async () => {
      req.body = {};

      await authController.registerGoogle(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Google ID Token wajib diisi');
      expect(authService.registerGoogle).not.toHaveBeenCalled();
    });

    it('should return validation error if invitation is invalid or expired (Negative Path)', async () => {
      req.body = { idToken: 'valid-google-id-token', token_invitation: 'expired-token' };
      const error = new Error('Invalid or expired invitation token');
      authService.registerGoogle.mockRejectedValue(error);

      await authController.registerGoogle(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, error.message);
    });

    it('should call next on generic error in Google register (Negative Path)', async () => {
      req.body = { idToken: 'valid-google-id-token' };
      const error = new Error('Google OAuth Server unavailable');
      authService.registerGoogle.mockRejectedValue(error);

      await authController.registerGoogle(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('login', () => {
    it('should login successfully with valid credentials (Success Path)', async () => {
      req.body = { no_wa: '081234567890', password: 'password123' };
      const mockResult = {
        user: { id: 1, nama: 'Budi' },
        token: 'auth-token'
      };
      authService.login.mockResolvedValue(mockResult);

      await authController.login(req, res, next);

      expect(authService.login).toHaveBeenCalledWith(req.body);
      expect(successResponse).toHaveBeenCalledWith(res, 'Login berhasil', mockResult);
    });

    it('should return validation error if no_wa or password is missing (Negative Path)', async () => {
      req.body = { no_wa: '081234567890' };

      await authController.login(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Nomor WhatsApp dan password wajib diisi');
      expect(authService.login).not.toHaveBeenCalled();
    });

    it('should return validation error on Invalid credentials (Negative Path)', async () => {
      req.body = { no_wa: '081234567890', password: 'wrongpassword' };
      const error = new Error('Invalid credentials');
      authService.login.mockRejectedValue(error);

      await authController.login(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Nomor WhatsApp atau password salah');
    });

    it('should call next on unexpected server error (Negative Path)', async () => {
      req.body = { no_wa: '081234567890', password: 'password123' };
      const error = new Error('DB Crash');
      authService.login.mockRejectedValue(error);

      await authController.login(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('getProfile', () => {
    it('should retrieve user profile successfully (Success Path)', async () => {
      req.user = { id: 5 };
      const mockProfile = { id: 5, nama: 'Siti', role: 'WARGA' };
      authService.getProfile.mockResolvedValue(mockProfile);

      await authController.getProfile(req, res, next);

      expect(authService.getProfile).toHaveBeenCalledWith(5);
      expect(successResponse).toHaveBeenCalledWith(res, 'Profile retrieved', mockProfile);
    });

    it('should call next when error occurs (Negative Path)', async () => {
      req.user = { id: 5 };
      const error = new Error('User not found');
      authService.getProfile.mockRejectedValue(error);

      await authController.getProfile(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('updateProfile', () => {
    it('should update user profile successfully (Success Path)', async () => {
      req.user = { id: 5 };
      req.body = { nama: 'Siti Aminah', no_wa: '0811112222', email: 'siti@mail.com' };
      const mockUpdated = { id: 5, ...req.body };
      authService.updateProfile.mockResolvedValue(mockUpdated);

      await authController.updateProfile(req, res, next);

      expect(authService.updateProfile).toHaveBeenCalledWith(5, req.body);
      expect(successResponse).toHaveBeenCalledWith(res, 'Profile updated', mockUpdated);
    });

    it('should call next if updateProfile fails (Negative Path)', async () => {
      req.user = { id: 5 };
      const error = new Error('Failed to update');
      authService.updateProfile.mockRejectedValue(error);

      await authController.updateProfile(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('changePassword', () => {
    it('should change password successfully (Success Path)', async () => {
      req.user = { id: 5 };
      req.body = { oldPassword: 'oldPass123', newPassword: 'newPass123' };
      const mockResult = { id: 5, updated: true };
      authService.changePassword.mockResolvedValue(mockResult);

      await authController.changePassword(req, res, next);

      expect(authService.changePassword).toHaveBeenCalledWith(5, req.body);
      expect(successResponse).toHaveBeenCalledWith(res, 'Kata sandi berhasil diubah', mockResult);
    });

    it('should return validation error if oldPassword or newPassword missing (Negative Path)', async () => {
      req.user = { id: 5 };
      req.body = { oldPassword: 'oldPass123' };

      await authController.changePassword(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Kata sandi lama dan baru wajib diisi');
    });

    it('should return validation error if old password is wrong (Negative Path)', async () => {
      req.user = { id: 5 };
      req.body = { oldPassword: 'wrong', newPassword: 'newPassword123' };
      const error = new Error('Kata sandi lama salah');
      authService.changePassword.mockRejectedValue(error);

      await authController.changePassword(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Kata sandi lama salah');
    });

    it('should call next if changePassword encounters generic error (Negative Path)', async () => {
      req.user = { id: 5 };
      req.body = { oldPassword: 'oldPass123', newPassword: 'newPass123' };
      const error = new Error('Server error');
      authService.changePassword.mockRejectedValue(error);

      await authController.changePassword(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('verifyEmail', () => {
    it('should verify email successfully (Success Path)', async () => {
      req.body = { identifier: 'ahmad@example.com', otp: '123456' };
      const mockUser = { id: 1, nama: 'Ahmad', is_verified: true };
      authService.verifyEmail.mockResolvedValue(mockUser);

      await authController.verifyEmail(req, res, next);

      expect(authService.verifyEmail).toHaveBeenCalledWith(req.body);
      expect(successResponse).toHaveBeenCalledWith(res, 'Email berhasil diverifikasi', {
        id: mockUser.id,
        nama: mockUser.nama,
        is_verified: mockUser.is_verified
      });
    });

    it('should return validation error if identifier or otp is missing (Negative Path)', async () => {
      req.body = { identifier: 'ahmad@example.com' };

      await authController.verifyEmail(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Identifier and OTP are required');
    });

    it('should return validation error if OTP is invalid (Negative Path)', async () => {
      req.body = { identifier: 'ahmad@example.com', otp: '000000' };
      const error = new Error('Invalid OTP');
      authService.verifyEmail.mockRejectedValue(error);

      await authController.verifyEmail(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Invalid OTP');
    });
  });
});
