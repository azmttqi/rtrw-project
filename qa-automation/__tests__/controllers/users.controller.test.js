const usersController = require('../../../backend/src/controllers/users.controller');
const userRepository = require('../../../backend/src/repositories/user.repository');
const { successResponse, errorResponse, validationErrorResponse } = require('../../../backend/src/utils/response');
const { getPaginationMeta } = require('../../../backend/src/utils/pagination');

jest.mock('../../../backend/src/repositories/user.repository');
jest.mock('../../../backend/src/utils/response');
jest.mock('../../../backend/src/utils/pagination');

describe('Users Controller', () => {
  let req, res, next;

  beforeEach(() => {
    req = {
      query: {},
      body: {},
      params: {},
      user: {}
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
    next = jest.fn();
    jest.clearAllMocks();
  });

  describe('getUsers', () => {
    it('should return users (Success Path)', async () => {
      req.query = { page: 1, limit: 10 };
      const mockResult = { data: [{ id: 1 }], total: 1 };
      userRepository.findAll.mockResolvedValue(mockResult);
      getPaginationMeta.mockReturnValue({ page: 1, limit: 10, total: 1, totalPages: 1 });

      await usersController.getUsers(req, res, next);

      expect(userRepository.findAll).toHaveBeenCalledWith({
        rt_id: undefined, rw_id: undefined, role: undefined, is_verified: undefined, page: 1, limit: 10
      });
      expect(successResponse).toHaveBeenCalledWith(res, 'Users retrieved', {
        users: mockResult.data,
        pagination: { page: 1, limit: 10, total: 1, totalPages: 1 }
      });
    });

    it('should call next on error (Negative Path)', async () => {
      const error = new Error('DB Error');
      userRepository.findAll.mockRejectedValue(error);

      await usersController.getUsers(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('getUserById', () => {
    it('should return user details (Success Path)', async () => {
      req.params.id = '1';
      const mockUser = { id: 1 };
      userRepository.findById.mockResolvedValue(mockUser);

      await usersController.getUserById(req, res, next);

      expect(userRepository.findById).toHaveBeenCalledWith('1');
      expect(successResponse).toHaveBeenCalledWith(res, 'User details', mockUser);
    });

    it('should return 404 if user not found (Negative Path)', async () => {
      req.params.id = '1';
      userRepository.findById.mockResolvedValue(null);

      await usersController.getUserById(req, res, next);

      expect(errorResponse).toHaveBeenCalledWith(res, 'User not found', 404);
    });

    it('should call next on error (Negative Path)', async () => {
      req.params.id = '1';
      const error = new Error('DB Error');
      userRepository.findById.mockRejectedValue(error);

      await usersController.getUserById(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('updateProfile', () => {
    it('should update profile and return 200 (Success Path)', async () => {
      req.user = { id: 1 };
      req.body = { nama: 'Updated', no_wa: '08123456789' };
      const mockUser = { id: 1, ...req.body };
      userRepository.update.mockResolvedValue(mockUser);

      await usersController.updateProfile(req, res, next);

      expect(userRepository.update).toHaveBeenCalledWith(1, { nama: 'Updated', no_wa: '08123456789' });
      expect(successResponse).toHaveBeenCalledWith(res, 'Profil berhasil diupdate', mockUser);
    });

    it('should return validation error if no data to update (Negative Path)', async () => {
      req.user = { id: 1 };
      req.body = {};

      await usersController.updateProfile(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Tidak ada data untuk diupdate');
    });

    it('should call next on error (Negative Path)', async () => {
      req.user = { id: 1 };
      req.body = { nama: 'Updated' };
      const error = new Error('DB Error');
      userRepository.update.mockRejectedValue(error);

      await usersController.updateProfile(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('verifyRT', () => {
    it('should verify RT and return 200 (Success Path)', async () => {
      req.params.id = '1';
      req.body = { status: 'APPROVED', rt_id: 1 };
      const mockUser = { id: 1, role: 'RT' };
      userRepository.findById.mockResolvedValue(mockUser);
      userRepository.update.mockResolvedValue({ id: 1, is_verified: true, rt_id: 1 });

      await usersController.verifyRT(req, res, next);

      expect(userRepository.findById).toHaveBeenCalledWith('1');
      expect(userRepository.update).toHaveBeenCalledWith('1', { is_verified: true, rt_id: 1 });
      expect(successResponse).toHaveBeenCalledWith(res, 'RT berhasil diverifikasi', { id: 1, is_verified: true, rt_id: 1 });
    });

    it('should handle rejection (Success Path)', async () => {
      req.params.id = '1';
      req.body = { status: 'REJECTED' };
      const mockUser = { id: 1, role: 'RT' };
      userRepository.findById.mockResolvedValue(mockUser);

      await usersController.verifyRT(req, res, next);

      expect(successResponse).toHaveBeenCalledWith(res, 'Verifikasi RT ditolak');
    });

    it('should return validation error if user not found or not RT (Negative Path)', async () => {
      req.params.id = '1';
      req.body = { status: 'APPROVED' };
      userRepository.findById.mockResolvedValue({ id: 1, role: 'WARGA' });

      await usersController.verifyRT(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'User bukan RT atau tidak ditemukan');
    });

    it('should call next on error (Negative Path)', async () => {
      req.params.id = '1';
      const error = new Error('DB Error');
      userRepository.findById.mockRejectedValue(error);

      await usersController.verifyRT(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });
});
