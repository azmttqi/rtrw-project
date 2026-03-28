const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth.middleware');
const notificationController = require('../controllers/notification.controller');

// Notifikasi keuangan (RW: status iuran per-RT | RT: status iuran per-warga)
router.get('/dues', authenticate, notificationController.getDuesNotifications);

// Inbox surat (RT atau RW)
router.get('/letters', authenticate, notificationController.getLetterInbox);

module.exports = router;
