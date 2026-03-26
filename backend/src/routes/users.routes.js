const express = require('express');
const router = express.Router();
const usersController = require('../controllers/users.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { isRT, isRW } = require('../middleware/role.middleware');

router.get('/', authenticate, isRT(), usersController.getUsers);
router.get('/:id', authenticate, isRT(), usersController.getUserById);

// Verify RT (RW only)
router.patch('/:id/verify-rt', authenticate, isRW(), usersController.verifyRT);

module.exports = router;

