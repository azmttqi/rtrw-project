const usersController = require('../../../backend/src/controllers/users.controller');
const userRepository = require('../../../backend/src/repositories/user.repository');
const { successResponse, errorResponse, validationErrorResponse } = require('../../../backend/src/utils/response');

jest.mock('../../../backend/src/repositories/user.repository');
jest.mock('../../../backend/src/utils/response');

describe('Users Controller', () => {
  let req, res, next;

  beforeEach(() => {
    req = {
      user: { id: 1, role: 'ADMIN' },
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

  describe('getUsers', () => {
    it('should return list of users with pagination (Success Path)', async () => {
      req.query = { rt_id: '5', rw_id: '10', role: 'WARGA', is_verified: 'true', page: '1', limit: '10' };
      const mockResult = {
        data: [{ id: 1, nama: 'Budi' }],
        total: 1
      };
      userRepository.findAll.mockResolvedValue(mockResult);

      await usersController.getUsers(req, res, next);

      expect(userRepository.findAll).toHaveBeenCalledWith({
        rt_id: '5',
        rw_id: '10',
        role: 'WARGA',
        is_verified: 'true',
        page: 1,
        limit: 10
      });
      expect(successResponse).toHaveBeenCalledWith(
        res,
        'Users retrieved',
        expect.objectContaining({
          users: mockResult.data,
          pagination: expect.any(Object)
        })
      );
    });

    it('should call next on repository error in getUsers (Negative Path)', async () => {
      const error = new Error('Database find error');
      userRepository.findAll.mockRejectedValue(error);

      await usersController.getUsers(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('getUserById', () => {
    it('should return user details by id (Success Path)', async () => {
      req.params.id = '5';
      const mockUser = { id: 5, nama: 'Budi' };
      userRepository.findById.mockResolvedValue(mockUser);

      await usersController.getUserById(req, res, next);

      expect(userRepository.findById).toHaveBeenCalledWith('5');
      expect(successResponse).toHaveBeenCalledWith(res, 'User details', mockUser);
    });

    it('should return 404 errorResponse if user not found (Negative Path)', async () => {
      req.params.id = '999';
      userRepository.findById.mockResolvedValue(null);

      await usersController.getUserById(req, res, next);

      expect(errorResponse).toHaveBeenCalledWith(res, 'User not found', 404);
    });

    it('should call next on generic error during getUserById (Negative Path)', async () => {
      req.params.id = '5';
      const error = new Error('Database error');
      userRepository.findById.mockRejectedValue(error);

      await usersController.getUserById(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('updateProfile', () => {
    it('should update user profile successfully (Success Path)', async () => {
      req.user = { id: 5 };
      req.body = { nama: 'Budi Baru', no_wa: '081299998888' };
      const mockUpdated = { id: 5, nama: 'Budi Baru', no_wa: '081299998888' };
      userRepository.update.mockResolvedValue(mockUpdated);

      await usersController.updateProfile(req, res, next);

      expect(userRepository.update).toHaveBeenCalledWith(5, {
        nama: 'Budi Baru',
        no_wa: '081299998888'
      });
      expect(successResponse).toHaveBeenCalledWith(res, 'Profil berhasil diupdate', mockUpdated);
    });

    it('should return validation error if no fields provided to update (Negative Path)', async () => {
      req.user = { id: 5 };
      req.body = {};

      await usersController.updateProfile(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'Tidak ada data untuk diupdate');
      expect(userRepository.update).not.toHaveBeenCalled();
    });

    it('should call next on generic error during updateProfile (Negative Path)', async () => {
      req.user = { id: 5 };
      req.body = { nama: 'Budi' };
      const error = new Error('Database update error');
      userRepository.update.mockRejectedValue(error);

      await usersController.updateProfile(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('verifyRT', () => {
    it('should verify RT user successfully with APPROVED status (Success Path)', async () => {
      req.params.id = '2';
      req.body = { status: 'APPROVED', rt_id: 10 };
      const mockUser = { id: 2, role: 'RT', is_verified: false };
      const mockUpdated = { id: 2, role: 'RT', is_verified: true, rt_id: 10 };
      userRepository.findById.mockResolvedValue(mockUser);
      userRepository.update.mockResolvedValue(mockUpdated);

      await usersController.verifyRT(req, res, next);

      expect(userRepository.findById).toHaveBeenCalledWith('2');
      expect(userRepository.update).toHaveBeenCalledWith('2', {
        is_verified: true,
        rt_id: 10
      });
      expect(successResponse).toHaveBeenCalledWith(res, 'RT berhasil diverifikasi', mockUpdated);
    });

    it('should handle REJECTED status for RT verification (Success Path)', async () => {
      req.params.id = '2';
      req.body = { status: 'REJECTED' };
      const mockUser = { id: 2, role: 'RT' };
      userRepository.findById.mockResolvedValue(mockUser);

      await usersController.verifyRT(req, res, next);

      expect(successResponse).toHaveBeenCalledWith(res, 'Verifikasi RT ditolak');
      expect(userRepository.update).not.toHaveBeenCalled();
    });

    it('should return validation error if user is not found or not an RT (Negative Path)', async () => {
      req.params.id = '3';
      req.body = { status: 'APPROVED' };
      const mockUser = { id: 3, role: 'WARGA' };
      userRepository.findById.mockResolvedValue(mockUser);

      await usersController.verifyRT(req, res, next);

      expect(validationErrorResponse).toHaveBeenCalledWith(res, 'User bukan RT atau tidak ditemukan');
    });

    it('should call next on generic error during verifyRT (Negative Path)', async () => {
      req.params.id = '2';
      req.body = { status: 'APPROVED' };
      const error = new Error('Database failure');
      userRepository.findById.mockRejectedValue(error);

      await usersController.verifyRT(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });
});
