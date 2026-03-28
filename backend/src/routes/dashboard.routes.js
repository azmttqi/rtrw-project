const express = require('express');
const router = express.Router();
const dashboardController = require('../controllers/dashboard.controller');
const { authenticate } = require('../middleware/auth.middleware');

router.get('/stats', authenticate, dashboardController.getStats);
router.get('/finance', authenticate, dashboardController.getFinanceSummary);

module.exports = router;
