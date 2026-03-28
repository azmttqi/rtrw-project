const jwt = require('jsonwebtoken');
const { JWT_SECRET } = require('../config/jwt');
const pool = require('../config/database');
const { unauthorizedResponse } = require('../utils/response');

const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return unauthorizedResponse(res, 'No token provided');
    }

    const token = authHeader.split(' ')[1];

    const decoded = jwt.verify(token, JWT_SECRET);

    const result = await pool.query(
      `SELECT u.id, u.nama, u.no_wa, u.role, u.rt_id, u.rw_id, u.is_verified,
              r.nomor_rt, rw.nomor_rw
       FROM users u
       LEFT JOIN rts r ON u.rt_id = r.id
       LEFT JOIN rws rw ON u.rw_id = rw.id OR (u.role = 'RW' AND rw.id = (SELECT id FROM rws WHERE id = u.rw_id))
       WHERE u.id = $1`,
      [decoded.userId]
    );

    if (result.rows.length === 0) {
      return unauthorizedResponse(res, 'User not found');
    }

    req.user = result.rows[0];
    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return unauthorizedResponse(res, 'Invalid token');
    }
    if (error.name === 'TokenExpiredError') {
      return unauthorizedResponse(res, 'Token expired');
    }
    return unauthorizedResponse(res, 'Authentication failed');
  }
};

module.exports = { authenticate };

