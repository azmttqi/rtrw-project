const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth.middleware');
const { isRT, isRW } = require('../middleware/role.middleware');
const duesController = require('../controllers/dues.controller');

// --- Settings ---
// Get settings (Warga view RT settings, RT view RW settings)
router.get('/settings', authenticate, duesController.getSettings);

// Create settings (RT sets for Warga, RW sets for RT)
router.post('/settings', authenticate, duesController.createSetting);

// --- Bills ---
router.post('/bills', authenticate, isRT(), duesController.createBill);
router.post('/bills/:id/remind', authenticate, isRT(), duesController.sendManualReminder);
router.get('/bills', authenticate, isRT(), duesController.getBillsByRT);

// --- Payments ---
router.post('/pay', authenticate, duesController.createPayment);
router.get('/payments', authenticate, isRT(), duesController.getPaymentsByRT);
router.patch('/payments/:id/verify', authenticate, isRT(), duesController.verifyPayment);

module.exports = router;
