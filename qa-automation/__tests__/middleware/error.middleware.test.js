const { errorHandler, notFoundHandler } = require('../../../backend/src/middleware/error.middleware');
const { errorResponse } = require('../../../backend/src/utils/response');

jest.mock('../../../backend/src/utils/response');

describe('Error Middleware', () => {
  let req, res, next;

  beforeEach(() => {
    req = {};
    res = {};
    next = jest.fn();
    jest.spyOn(console, 'error').mockImplementation(() => {}); // Suppress console.error in tests
    jest.clearAllMocks();
  });

  afterAll(() => {
    console.error.mockRestore();
  });

  describe('errorHandler', () => {
    it('should handle entity.parse.failed', () => {
      const err = { type: 'entity.parse.failed' };
      errorHandler(err, req, res, next);
      expect(errorResponse).toHaveBeenCalledWith(res, 'Invalid JSON', 400);
    });

    it('should handle duplicate entry (23505)', () => {
      const err = { code: '23505' };
      errorHandler(err, req, res, next);
      expect(errorResponse).toHaveBeenCalledWith(res, 'Duplicate entry', 409);
    });

    it('should handle foreign key violation (23503)', () => {
      const err = { code: '23503' };
      errorHandler(err, req, res, next);
      expect(errorResponse).toHaveBeenCalledWith(res, 'Foreign key constraint violation', 400);
    });

    it('should handle generic errors with custom status and message', () => {
      const err = { message: 'Custom error', statusCode: 418 };
      errorHandler(err, req, res, next);
      expect(errorResponse).toHaveBeenCalledWith(res, 'Custom error', 418);
    });

    it('should handle fallback generic errors', () => {
      const err = {};
      errorHandler(err, req, res, next);
      expect(errorResponse).toHaveBeenCalledWith(res, 'Internal server error', 500);
    });
  });

  describe('notFoundHandler', () => {
    it('should handle route not found', () => {
      notFoundHandler(req, res);
      expect(errorResponse).toHaveBeenCalledWith(res, 'Route not found', 404);
    });
  });
});
