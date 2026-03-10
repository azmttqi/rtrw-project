const { forbiddenResponse } = require('../utils/response');

const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return forbiddenResponse(res, 'User not authenticated');
    }

    if (!roles.includes(req.user.role)) {
      return forbiddenResponse(res, 'You do not have permission to access this resource');
    }

    next();
  };
};

const isRT = () => authorize('RT', 'RW');
const isRW = () => authorize('RW');
const isWarga = () => authorize('WARGA');

module.exports = {
  authorize,
  isRT,
  isRW,
  isWarga,
};

