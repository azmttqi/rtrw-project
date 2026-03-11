const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth.middleware');
const residentsController = require('../controllers/residents.controller');

// Get residents by family
router.get('/', authenticate, residentsController.getResidentsByFamily);

// Add resident
router.post('/', authenticate, residentsController.addResident);

// Update resident
router.patch('/:id', authenticate, residentsController.updateResident);

// Delete resident
router.delete('/:id', authenticate, residentsController.deleteResident);

module.exports = router;

