const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth.middleware');
const { isRT } = require('../middleware/role.middleware');
const invitationRepository = require('../repositories/invitation.repository');
const { successResponse, createdResponse, validationErrorResponse } = require('../utils/response');

// Create invitation (RT only)
router.post('/', authenticate, isRT(), async (req, res, next) => {
  try {
    const { no_wa } = req.body;
    const rt_id = req.user.rt_id;

    if (!no_wa) {
      return validationErrorResponse(res, 'Nomor WhatsApp wajib diisi');
    }

    // Check if there's already an active invitation
    const existing = await invitationRepository.findByNoWaAndRT(no_wa, rt_id);
    if (existing) {
      return validationErrorResponse(res, 'Undangan sudah ada untuk nomor ini');
    }

    const invitation = await invitationRepository.create({ no_wa, rt_id });
    return createdResponse(res, 'Undangan berhasil dibuat', invitation);
  } catch (error) {
    next(error);
  }
});

// List invitations
router.get('/', authenticate, isRT(), async (req, res, next) => {
  try {
    const rt_id = req.user.rt_id;
    const invitations = await invitationRepository.findAllByRT(rt_id);
    return successResponse(res, 'Daftar undangan', invitations);
  } catch (error) {
    next(error);
  }
});

// Delete invitation
router.delete('/:id', authenticate, isRT(), async (req, res, next) => {
  try {
    const { id } = req.params;
    await invitationRepository.delete(id);
    return successResponse(res, 'Undangan dihapus');
  } catch (error) {
    next(error);
  }
});

module.exports = router;

