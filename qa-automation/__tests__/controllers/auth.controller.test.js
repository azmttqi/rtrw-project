const authController = require('../../../backend/src/controllers/auth.controller');
const authService = require('../../../backend/src/services/auth.service');
const { successResponse, createdResponse, validationErrorResponse } = require('../../../backend/src/utils/response');

jest.mock('../../../backend/src/services/auth.service');
jest.mock('../../../backend/src/utils/response');

describe('Auth Controller', () => {
  let req, res, next;

  beforeEach(() => {
    req = {
      body: {},
      user: {}
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
    next = jest.fn();
    jest.clearAllMocks();
  });

  describe('register', () => {
    it('should register a new user and return 201 (Success Path)', async () => {
      req.body = { nama: 'Test', no_wa: '0812', password: 'password123', role: 'WARGA' };
      const mockResult = { user: { id: 1, nama: 'Test' }, token: 'mockToken' };
      authService.register.mockResolvedValue(mockResult);

      await authController.register(req, res, next);

      expect(authService.register).toHaveBeenCalledWith({
        nama: 'Test', no_wa: '0812', password: 'password123', role: 'WARGA',
        email: undefined, token_invitation: undefined, nomor_rw: undefined, nomor_rt: undefined, alamat: undefined, nama_wilayah: undefined
      });
      expect(createdResponse).toHaveBeenCalledWith(res, 'Registrasi berhasil', mockResult);
    });

    it('should return validation error if required fields are missing (Negative Path)', async () => {
      req.body = { nama: 'Test' }; // missing no_wa, password

      await authController.register(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Nama, nomor WhatsApp, dan password wajib diisi');
    });

    it('should return validation error for specific service errors (Negative Path)', async () => {
      req.body = { nama: 'Test', no_wa: '0812', password: 'password123' };
      const error = new Error('already registered');
      authService.register.mockRejectedValue(error);

      await authController.register(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'already registered');
    });
    
    it('should call next for generic errors (Negative Path)', async () => {
      req.body = { nama: 'Test', no_wa: '0812', password: 'password123' };
      const error = new Error('Database Error');
      authService.register.mockRejectedValue(error);

      await authController.register(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('registerGoogle', () => {
    it('should register via Google and return 200 (Success Path)', async () => {
      req.body = { idToken: 'mockIdToken' };
      const mockResult = { user: { id: 1 }, token: 'mockToken' };
      authService.registerGoogle.mockResolvedValue(mockResult);

      await authController.registerGoogle(req, res, next);

      expect(authService.registerGoogle).toHaveBeenCalledWith({ idToken: 'mockIdToken', token_invitation: undefined });
      expect(successResponse).toHaveBeenCalledWith(res, 'Login/Registrasi Google berhasil', mockResult);
    });

    it('should return validation error if idToken is missing (Negative Path)', async () => {
      req.body = {};

      await authController.registerGoogle(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Google ID Token wajib diisi');
    });
    
    it('should return validation error if token invalid (Negative Path)', async () => {
      req.body = { idToken: 'mockIdToken' };
      const error = new Error('Invalid or expired invitation');
      authService.registerGoogle.mockRejectedValue(error);

      await authController.registerGoogle(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Invalid or expired invitation');
    });

    it('should call next for generic errors (Negative Path)', async () => {
      req.body = { idToken: 'mockIdToken' };
      const error = new Error('Network Error');
      authService.registerGoogle.mockRejectedValue(error);

      await authController.registerGoogle(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('login', () => {
    it('should login and return 200 (Success Path)', async () => {
      req.body = { no_wa: '0812', password: 'password123' };
      const mockResult = { user: { id: 1 }, token: 'mockToken' };
      authService.login.mockResolvedValue(mockResult);

      await authController.login(req, res, next);

      expect(authService.login).toHaveBeenCalledWith({ no_wa: '0812', password: 'password123' });
      expect(successResponse).toHaveBeenCalledWith(res, 'Login berhasil', mockResult);
    });

    it('should return validation error if fields are missing (Negative Path)', async () => {
      req.body = { no_wa: '0812' };

      await authController.login(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Nomor WhatsApp dan password wajib diisi');
    });

    it('should return validation error for Invalid credentials (Negative Path)', async () => {
      req.body = { no_wa: '0812', password: 'wrong' };
      const error = new Error('Invalid credentials');
      authService.login.mockRejectedValue(error);

      await authController.login(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Nomor WhatsApp atau password salah');
    });
    
    it('should call next for generic errors (Negative Path)', async () => {
      req.body = { no_wa: '0812', password: 'password123' };
      const error = new Error('Server Error');
      authService.login.mockRejectedValue(error);

      await authController.login(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('getProfile', () => {
    it('should get profile and return 200 (Success Path)', async () => {
      req.user = { id: 1 };
      const mockUser = { id: 1, nama: 'Test' };
      authService.getProfile.mockResolvedValue(mockUser);

      await authController.getProfile(req, res, next);

      expect(authService.getProfile).toHaveBeenCalledWith(1);
      expect(successResponse).toHaveBeenCalledWith(res, 'Profile retrieved', mockUser);
    });

    it('should call next on error (Negative Path)', async () => {
      req.user = { id: 1 };
      const error = new Error('Not found');
      authService.getProfile.mockRejectedValue(error);

      await authController.getProfile(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('updateProfile', () => {
    it('should update profile and return 200 (Success Path)', async () => {
      req.user = { id: 1 };
      req.body = { nama: 'Test Updated', email: 'test@mail.com', no_wa: '0812' };
      const mockUser = { id: 1, ...req.body };
      authService.updateProfile.mockResolvedValue(mockUser);

      await authController.updateProfile(req, res, next);

      expect(authService.updateProfile).toHaveBeenCalledWith(1, req.body);
      expect(successResponse).toHaveBeenCalledWith(res, 'Profile updated', mockUser);
    });

    it('should call next on error (Negative Path)', async () => {
      req.user = { id: 1 };
      const error = new Error('Error');
      authService.updateProfile.mockRejectedValue(error);

      await authController.updateProfile(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('changePassword', () => {
    it('should change password and return 200 (Success Path)', async () => {
      req.user = { id: 1 };
      req.body = { oldPassword: 'old', newPassword: 'new' };
      const mockUser = { id: 1, nama: 'Test' };
      authService.changePassword.mockResolvedValue(mockUser);

      await authController.changePassword(req, res, next);

      expect(authService.changePassword).toHaveBeenCalledWith(1, req.body);
      expect(successResponse).toHaveBeenCalledWith(res, 'Kata sandi berhasil diubah', mockUser);
    });
    
    it('should return validation error if fields are missing (Negative Path)', async () => {
      req.body = { oldPassword: 'old' };

      await authController.changePassword(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Kata sandi lama dan baru wajib diisi');
    });

    it('should return validation error for wrong password (Negative Path)', async () => {
      req.user = { id: 1 };
      req.body = { oldPassword: 'old', newPassword: 'new' };
      const error = new Error('Kata sandi lama salah');
      authService.changePassword.mockRejectedValue(error);

      await authController.changePassword(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Kata sandi lama salah');
    });

    it('should call next on generic error (Negative Path)', async () => {
      req.user = { id: 1 };
      req.body = { oldPassword: 'old', newPassword: 'new' };
      const error = new Error('DB error');
      authService.changePassword.mockRejectedValue(error);

      await authController.changePassword(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('verifyEmail', () => {
    it('should verify email and return 200 (Success Path)', async () => {
      req.body = { identifier: 'test@mail.com', otp: '123456' };
      const mockUser = { id: 1, nama: 'Test', is_verified: true };
      authService.verifyEmail.mockResolvedValue(mockUser);

      await authController.verifyEmail(req, res, next);

      expect(authService.verifyEmail).toHaveBeenCalledWith(req.body);
      expect(successResponse).toHaveBeenCalledWith(res, 'Email berhasil diverifikasi', {
        id: 1, nama: 'Test', is_verified: true
      });
    });
    
    it('should return validation error if fields are missing (Negative Path)', async () => {
      req.body = { identifier: 'test@mail.com' };

      await authController.verifyEmail(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Identifier and OTP are required');
    });

    it('should return validation error for service error (Negative Path)', async () => {
      req.body = { identifier: 'test@mail.com', otp: '123456' };
      const error = new Error('OTP tidak valid');
      authService.verifyEmail.mockRejectedValue(error);

      await authController.verifyEmail(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'OTP tidak valid');
    });
  });
});
