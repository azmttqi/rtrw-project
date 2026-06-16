const express = require('express');
const router = express.Router();
const multer = require('multer');
const upload = multer({ storage: multer.memoryStorage() });
const dashboardController = require('../controllers/dashboard.controller');
const { authenticate } = require('../middleware/auth.middleware');

router.get('/stats', authenticate, dashboardController.getStats);
router.get('/finance', authenticate, dashboardController.getFinanceSummary);
router.post('/scan-receipt', authenticate, upload.single('receipt'), dashboardController.scanReceipt);

module.exports = router;
