const response = (res, statusCode = 200, success = true, message = null, data = null) => {
  const result = {
    success,
  };

  if (message) result.message = message;
  if (data !== null) result.data = data;

  return res.status(statusCode).json(result);
};

const successResponse = (res, message = 'Success', data = null) => {
  return response(res, 200, true, message, data);
};

const createdResponse = (res, message = 'Created successfully', data = null) => {
  return response(res, 201, true, message, data);
};

const errorResponse = (res, message = 'Internal server error', statusCode = 500) => {
  return response(res, statusCode, false, message, null);
};

const notFoundResponse = (res, message = 'Resource not found') => {
  return response(res, 404, false, message, null);
};

const unauthorizedResponse = (res, message = 'Unauthorized') => {
  return response(res, 401, false, message, null);
};

const forbiddenResponse = (res, message = 'Forbidden') => {
  return response(res, 403, false, message, null);
};

const validationErrorResponse = (res, message = 'Validation error') => {
  return response(res, 400, false, message, null);
};

module.exports = {
  response,
  successResponse,
  createdResponse,
  errorResponse,
  notFoundResponse,
  unauthorizedResponse,
  forbiddenResponse,
  validationErrorResponse,
};

