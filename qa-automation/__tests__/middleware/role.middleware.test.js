const { authorize, isRT, isRW, isWarga } = require('../../../backend/src/middleware/role.middleware');
const { forbiddenResponse } = require('../../../backend/src/utils/response');

jest.mock('../../../backend/src/utils/response');

describe('Role Middleware', () => {
  let req, res, next;

  beforeEach(() => {
    req = {};
    res = {};
    next = jest.fn();
    jest.clearAllMocks();
  });

  describe('authorize', () => {
    it('should return forbidden if user is not authenticated (no req.user)', () => {
      const middleware = authorize('ADMIN');
      middleware(req, res, next);

      expect(forbiddenResponse).toHaveBeenCalledWith(res, 'User not authenticated');
      expect(next).not.toHaveBeenCalled();
    });

    it('should return forbidden if user does not have required role', () => {
      req.user = { role: 'WARGA' };
      const middleware = authorize('ADMIN');
      middleware(req, res, next);

      expect(forbiddenResponse).toHaveBeenCalledWith(res, 'You do not have permission to access this resource');
      expect(next).not.toHaveBeenCalled();
    });

    it('should call next if user has the required role', () => {
      req.user = { role: 'ADMIN' };
      const middleware = authorize('ADMIN', 'SUPERADMIN');
      middleware(req, res, next);

      expect(forbiddenResponse).not.toHaveBeenCalled();
      expect(next).toHaveBeenCalled();
    });
  });

  describe('isRT', () => {
    it('should allow RT role', () => {
      req.user = { role: 'RT' };
      isRT()(req, res, next);
      expect(next).toHaveBeenCalled();
    });

    it('should allow RW role (as defined in isRT)', () => {
      req.user = { role: 'RW' };
      isRT()(req, res, next);
      expect(next).toHaveBeenCalled();
    });

    it('should forbid WARGA role', () => {
      req.user = { role: 'WARGA' };
      isRT()(req, res, next);
      expect(forbiddenResponse).toHaveBeenCalled();
    });
  });

  describe('isRW', () => {
    it('should allow RW role', () => {
      req.user = { role: 'RW' };
      isRW()(req, res, next);
      expect(next).toHaveBeenCalled();
    });

    it('should forbid RT role', () => {
      req.user = { role: 'RT' };
      isRW()(req, res, next);
      expect(forbiddenResponse).toHaveBeenCalled();
    });
  });

  describe('isWarga', () => {
    it('should allow WARGA role', () => {
      req.user = { role: 'WARGA' };
      isWarga()(req, res, next);
      expect(next).toHaveBeenCalled();
    });

    it('should forbid ADMIN role', () => {
      req.user = { role: 'ADMIN' };
      isWarga()(req, res, next);
      expect(forbiddenResponse).toHaveBeenCalled();
    });
  });
});
