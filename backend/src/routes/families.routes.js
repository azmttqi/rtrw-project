const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth.middleware');
const { isRT } = require('../middleware/role.middleware');
const familiesController = require('../controllers/families.controller');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Multer config
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dir = './uploads/documents';
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    cb(null, `doc-${Date.now()}${path.extname(file.originalname)}`);
  }
});
const upload = multer({ storage });

// Get my family (for warga)
router.get('/me', authenticate, familiesController.getMyFamily);

// Create family (for warga) - support multiple document uploads
router.post('/', authenticate, upload.array('documents', 5), familiesController.createFamily);

// Get families by RT
router.get('/', authenticate, isRT(), familiesController.getFamiliesByRT);

// Verify family (RT only)
router.patch('/:id/verify', authenticate, isRT(), familiesController.verifyFamily);

module.exports = router;

