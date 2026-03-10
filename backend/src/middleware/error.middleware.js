const { errorResponse } = require('../utils/response');

const errorHandler = (err, req, res, next) => {
  console.error('Error:', err);

  if (err.type === 'entity.parse.failed') {
    return errorResponse(res, 'Invalid JSON', 400);
  }

  if (err.code === '23505') {
    return errorResponse(res, 'Duplicate entry', 409);
  }

  if (err.code === '23503') {
    return errorResponse(res, 'Foreign key constraint violation', 400);
  }

  return errorResponse(res, err.message || 'Internal server error', err.statusCode || 500);
};

const notFoundHandler = (req, res) => {
  return errorResponse(res, 'Route not found', 404);
};

module.exports = {
  errorHandler,
  notFoundHandler,
};

