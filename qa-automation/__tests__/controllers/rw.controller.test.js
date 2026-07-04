const rwController = require('../../../backend/src/controllers/rw.controller');
const pool = require('../../../backend/src/config/database');
const { createdResponse, errorResponse } = require('../../../backend/src/utils/response');

jest.mock('../../../backend/src/config/database');
jest.mock('../../../backend/src/utils/response');

describe('RW Controller', () => {
  let req, res, next, mockClient;

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

    mockClient = {
      query: jest.fn(),
      release: jest.fn()
    };
    pool.connect.mockResolvedValue(mockClient);

    jest.clearAllMocks();
  });

  describe('setupEnvironment', () => {
    it('should setup environment and return 201 (Success Path)', async () => {
      req.user = { id: 1 };
      req.body = { nomor_rw: '01', rts: ['01', '02'] };
      
      // Mock RW insertion
      mockClient.query.mockResolvedValueOnce(); // BEGIN
      mockClient.query.mockResolvedValueOnce({ rows: [{ id: 1 }] }); // Insert RW
      mockClient.query.mockResolvedValueOnce(); // Update User
      mockClient.query.mockResolvedValueOnce({ rows: [{ id: 1, nomor_rt: '01' }] }); // Insert RT 1
      mockClient.query.mockResolvedValueOnce({ rows: [{ id: 2, nomor_rt: '02' }] }); // Insert RT 2
      mockClient.query.mockResolvedValueOnce(); // COMMIT

      await rwController.setupEnvironment(req, res, next);

      expect(mockClient.query).toHaveBeenCalledWith('BEGIN');
      expect(mockClient.query).toHaveBeenCalledWith('COMMIT');
      expect(mockClient.release).toHaveBeenCalled();
      expect(createdResponse).toHaveBeenCalledWith(res, 'Lingkungan RW berhasil disetup', {
        rwId: 1, nomor_rw: '01', rts: [{ id: 1, nomor_rt: '01' }, { id: 2, nomor_rt: '02' }]
      });
    });

    it('should return error if missing fields (Negative Path)', async () => {
      req.body = { nomor_rw: '01' }; // missing rts

      await rwController.setupEnvironment(req, res, next);

      expect(errorResponse).toHaveBeenCalledWith(res, 'Nomor RW dan daftar RT wajib diisi', 400);
      expect(mockClient.release).toHaveBeenCalled(); // Since it checks after getting client
    });

    it('should rollback and call next on error (Negative Path)', async () => {
      req.user = { id: 1 };
      req.body = { nomor_rw: '01', rts: ['01'] };
      
      const error = new Error('DB Error');
      mockClient.query.mockResolvedValueOnce(); // BEGIN
      mockClient.query.mockRejectedValueOnce(error); // Error on Insert RW

      await rwController.setupEnvironment(req, res, next);

      expect(mockClient.query).toHaveBeenCalledWith('ROLLBACK');
      expect(next).toHaveBeenCalledWith(error);
      expect(mockClient.release).toHaveBeenCalled();
    });
  });
});
