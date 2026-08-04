const rwController = require('../../../backend/src/controllers/rw.controller');
const pool = require('../../../backend/src/config/database');
const { createdResponse, errorResponse } = require('../../../backend/src/utils/response');

jest.mock('../../../backend/src/config/database', () => ({
  connect: jest.fn()
}));
jest.mock('../../../backend/src/utils/response');

describe('RW Controller', () => {
  let req, res, next, mockClient;

  beforeEach(() => {
    mockClient = {
      query: jest.fn(),
      release: jest.fn()
    };
    pool.connect.mockResolvedValue(mockClient);

    req = {
      user: { id: 1, role: 'RW' },
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

  describe('setupEnvironment', () => {
    it('should setup RW and RTs environment successfully (Success Path)', async () => {
      req.body = {
        nomor_rw: '05',
        rts: ['01', '02']
      };

      mockClient.query
        .mockResolvedValueOnce({}) // BEGIN
        .mockResolvedValueOnce({ rows: [{ id: 10 }] }) // INSERT INTO rws
        .mockResolvedValueOnce({}) // UPDATE users
        .mockResolvedValueOnce({ rows: [{ id: 101, rw_id: 10, nomor_rt: '01' }] }) // INSERT RT 01
        .mockResolvedValueOnce({ rows: [{ id: 102, rw_id: 10, nomor_rt: '02' }] }) // INSERT RT 02
        .mockResolvedValueOnce({}); // COMMIT

      await rwController.setupEnvironment(req, res, next);

      expect(pool.connect).toHaveBeenCalled();
      expect(mockClient.query).toHaveBeenCalledWith('BEGIN');
      expect(mockClient.query).toHaveBeenCalledWith('COMMIT');
      expect(mockClient.release).toHaveBeenCalled();
      expect(createdResponse).toHaveBeenCalledWith(res, 'Lingkungan RW berhasil disetup', {
        rwId: 10,
        nomor_rw: '05',
        rts: [
          { id: 101, rw_id: 10, nomor_rt: '01' },
          { id: 102, rw_id: 10, nomor_rt: '02' }
        ]
      });
    });

    it('should return error response if nomor_rw or rts is missing or invalid (Negative Path)', async () => {
      req.body = { nomor_rw: '05' }; // rts missing

      await rwController.setupEnvironment(req, res, next);

      expect(errorResponse).toHaveBeenCalledWith(res, 'Nomor RW dan daftar RT wajib diisi', 400);
      expect(mockClient.release).toHaveBeenCalled();
    });

    it('should rollback transaction and call next on query failure (Negative Path)', async () => {
      req.body = {
        nomor_rw: '05',
        rts: ['01']
      };

      const error = new Error('Database transaction failed');
      mockClient.query
        .mockResolvedValueOnce({}) // BEGIN
        .mockRejectedValueOnce(error); // INSERT INTO rws fails

      await rwController.setupEnvironment(req, res, next);

      expect(mockClient.query).toHaveBeenCalledWith('ROLLBACK');
      expect(mockClient.release).toHaveBeenCalled();
      expect(next).toHaveBeenCalledWith(error);
    });
  });
});
