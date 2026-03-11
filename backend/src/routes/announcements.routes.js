const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth.middleware');
const { isRT, isRW } = require('../middleware/role.middleware');
const announcementsController = require('../controllers/announcements.controller');

// Create announcement
router.post('/', authenticate, isRT(), announcementsController.createAnnouncement);

// Get announcements
router.get('/', authenticate, announcementsController.getAnnouncements);

// Update announcement
router.patch('/:id', authenticate, isRT(), announcementsController.updateAnnouncement);

// Delete announcement
router.delete('/:id', authenticate, isRT(), announcementsController.deleteAnnouncement);

module.exports = router;

