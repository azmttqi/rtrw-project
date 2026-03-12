const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth.middleware');
const { isRT, isRW } = require('../middleware/role.middleware');
const lettersController = require('../controllers/letters.controller');

// Warga mengajukan surat
router.post('/', authenticate, lettersController.createLetter);

// Semua melihat daftar (Warga hanya miliknya, RT/RW lingkupnya)
router.get('/', authenticate, lettersController.getLetters);

// Verifikasi (RT atau RW)
router.patch('/:id/verify', authenticate, lettersController.verifyLetter);

// Download PDF
router.get('/:id/download', authenticate, lettersController.downloadLetter);

module.exports = router;
