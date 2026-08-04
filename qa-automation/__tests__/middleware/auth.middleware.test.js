const jwt = require('jsonwebtoken');
const pool = require('../../../backend/src/config/database');
const { unauthorizedResponse } = require('../../../backend/src/utils/response');
const { authenticate } = require('../../../backend/src/middleware/auth.middleware');

jest.mock('jsonwebtoken');
jest.mock('../../../backend/src/config/database');
jest.mock('../../../backend/src/utils/response');

describe('Auth Middleware', () => {
  let req, res, next;

  beforeEach(() => {
    req = { headers: {} };
    res = {};
    next = jest.fn();
    jest.clearAllMocks();
  });

  it('should return unauthorized if no token provided', async () => {
    await authenticate(req, res, next);
    expect(unauthorizedResponse).toHaveBeenCalledWith(res, 'No token provided');
  });

  it('should return unauthorized if token does not start with Bearer', async () => {
    req.headers.authorization = 'InvalidFormat Token';
    await authenticate(req, res, next);
    expect(unauthorizedResponse).toHaveBeenCalledWith(res, 'No token provided');
  });

  it('should call next if token is valid and user is found', async () => {
    req.headers.authorization = 'Bearer validtoken';
    jwt.verify.mockReturnValue({ userId: 1 });
    pool.query.mockResolvedValue({ rows: [{ id: 1, role: 'WARGA' }] });

    await authenticate(req, res, next);

    expect(jwt.verify).toHaveBeenCalledWith('validtoken', expect.any(String));
    expect(pool.query).toHaveBeenCalledWith(expect.any(String), [1]);
    expect(req.user).toEqual({ id: 1, role: 'WARGA' });
    expect(next).toHaveBeenCalled();
  });

  it('should return unauthorized if user not found in DB', async () => {
    req.headers.authorization = 'Bearer validtoken';
    jwt.verify.mockReturnValue({ userId: 1 });
    pool.query.mockResolvedValue({ rows: [] });

    await authenticate(req, res, next);

    expect(unauthorizedResponse).toHaveBeenCalledWith(res, 'User not found');
    expect(next).not.toHaveBeenCalled();
  });

  it('should handle JsonWebTokenError', async () => {
    req.headers.authorization = 'Bearer invalidtoken';
    const error = new Error();
    error.name = 'JsonWebTokenError';
    jwt.verify.mockImplementation(() => { throw error; });

    await authenticate(req, res, next);

    expect(unauthorizedResponse).toHaveBeenCalledWith(res, 'Invalid token');
  });

  it('should handle TokenExpiredError', async () => {
    req.headers.authorization = 'Bearer expiredtoken';
    const error = new Error();
    error.name = 'TokenExpiredError';
    jwt.verify.mockImplementation(() => { throw error; });

    await authenticate(req, res, next);

    expect(unauthorizedResponse).toHaveBeenCalledWith(res, 'Token expired');
  });

  it('should handle generic errors', async () => {
    req.headers.authorization = 'Bearer token';
    jwt.verify.mockImplementation(() => { throw new Error('Generic DB Error'); });

    await authenticate(req, res, next);

    expect(unauthorizedResponse).toHaveBeenCalledWith(res, 'Authentication failed');
  });
});
