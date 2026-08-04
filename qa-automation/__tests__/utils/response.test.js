const {
  response,
  successResponse,
  createdResponse,
  errorResponse,
  notFoundResponse,
  unauthorizedResponse,
  forbiddenResponse,
  validationErrorResponse,
} = require('../../../backend/src/utils/response');

describe('Response Utility', () => {
  let mockRes;

  beforeEach(() => {
    mockRes = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
  });

  describe('response (base helper)', () => {
    it('should format a standard response with custom parameters', () => {
      const data = { id: 1 };
      response(mockRes, 200, true, 'Operation success', data);

      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'Operation success',
        data
      });
    });

    it('should omit message and data when not provided or null', () => {
      response(mockRes, 204, true, null, null);

      expect(mockRes.status).toHaveBeenCalledWith(204);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true
      });
    });
  });

  describe('successResponse', () => {
    it('should return 200 with default message and null data', () => {
      successResponse(mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'Success'
      });
    });

    it('should return 200 with custom message and data payload', () => {
      const payload = { count: 10, items: [] };
      successResponse(mockRes, 'Data fetched successfully', payload);

      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'Data fetched successfully',
        data: payload
      });
    });
  });

  describe('createdResponse', () => {
    it('should return 201 with default message', () => {
      createdResponse(mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(201);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'Created successfully'
      });
    });

    it('should return 201 with custom message and created entity data', () => {
      const createdItem = { id: 10, name: 'New Item' };
      createdResponse(mockRes, 'Entity created', createdItem);

      expect(mockRes.status).toHaveBeenCalledWith(201);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'Entity created',
        data: createdItem
      });
    });
  });

  describe('errorResponse', () => {
    it('should return 500 with default message when no arguments provided', () => {
      errorResponse(mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(500);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Internal server error'
      });
    });

    it('should return custom status code and custom error message', () => {
      errorResponse(mockRes, 'Service unavailable', 503);

      expect(mockRes.status).toHaveBeenCalledWith(503);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Service unavailable'
      });
    });
  });

  describe('notFoundResponse', () => {
    it('should return 404 with default message', () => {
      notFoundResponse(mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(404);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Resource not found'
      });
    });

    it('should return 404 with custom not found message', () => {
      notFoundResponse(mockRes, 'User with specified ID not found');

      expect(mockRes.status).toHaveBeenCalledWith(404);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'User with specified ID not found'
      });
    });
  });

  describe('unauthorizedResponse', () => {
    it('should return 401 with default message', () => {
      unauthorizedResponse(mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(401);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Unauthorized'
      });
    });

    it('should return 401 with custom unauthorized message', () => {
      unauthorizedResponse(mockRes, 'Token expired');

      expect(mockRes.status).toHaveBeenCalledWith(401);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Token expired'
      });
    });
  });

  describe('forbiddenResponse', () => {
    it('should return 403 with default message', () => {
      forbiddenResponse(mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(403);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Forbidden'
      });
    });

    it('should return 403 with custom forbidden message', () => {
      forbiddenResponse(mockRes, 'Access restricted to RT admins');

      expect(mockRes.status).toHaveBeenCalledWith(403);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Access restricted to RT admins'
      });
    });
  });

  describe('validationErrorResponse', () => {
    it('should return 400 with default message', () => {
      validationErrorResponse(mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Validation error'
      });
    });

    it('should return 400 with custom validation error message', () => {
      validationErrorResponse(mockRes, 'Field nama is required');

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Field nama is required'
      });
    });
  });
});
