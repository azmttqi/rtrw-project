const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth.middleware');
const { isRW } = require('../middleware/role.middleware');
const rwController = require('../controllers/rw.controller');

// Setup RW (RW only)
router.post('/setup', authenticate, isRW(), rwController.setupEnvironment);

module.exports = router;
