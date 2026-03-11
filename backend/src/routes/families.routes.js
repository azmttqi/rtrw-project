const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth.middleware');
const { isRT } = require('../middleware/role.middleware');
const familiesController = require('../controllers/families.controller');

// Get my family (for warga)
router.get('/me', authenticate, familiesController.getMyFamily);

// Create family (for warga)
router.post('/', authenticate, familiesController.createFamily);

// Get families by RT
router.get('/', authenticate, isRT(), familiesController.getFamiliesByRT);

// Verify family (RT only)
router.patch('/:id/verify', authenticate, isRT(), familiesController.verifyFamily);

module.exports = router;

