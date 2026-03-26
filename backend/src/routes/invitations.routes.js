const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth.middleware');
const { isRT, isRW } = require('../middleware/role.middleware');
const invitationRepository = require('../repositories/invitation.repository');
const { successResponse, createdResponse, validationErrorResponse } = require('../utils/response');

// Create invitation (RT only for Warga, RW only for RT)
router.post('/', authenticate, async (req, res, next) => {
  try {
    const { no_wa } = req.body;
    let rt_id = null;
    let rw_id = null;

    if (req.user.role === 'RT') {
      rt_id = req.user.rt_id;
      if (!no_wa) return validationErrorResponse(res, 'Nomor WhatsApp wajib diisi untuk mengundang Warga');
      const existing = await invitationRepository.findByNoWaAndRT(no_wa, rt_id);
      if (existing) return validationErrorResponse(res, 'Undangan sudah ada untuk nomor ini');
    } else if (req.user.role === 'RW') {
      rw_id = req.user.rw_id;
      // RT invitation via Google doesn't necessarily need a no_wa initially if it's just a link
    } else {
      return errorResponse(res, 'Hanya RT atau RW yang bisa membuat undangan', 403);
    }

    const invitation = await invitationRepository.create({ no_wa, rt_id, rw_id });
    return createdResponse(res, 'Undangan berhasil dibuat', invitation);
  } catch (error) {
    next(error);
  }
});

// List invitations
router.get('/', authenticate, async (req, res, next) => {
  try {
    let invitations = [];
    if (req.user.role === 'RT') {
      invitations = await invitationRepository.findAllByRT(req.user.rt_id);
    } else if (req.user.role === 'RW') {
      invitations = await invitationRepository.findAllByRW(req.user.rw_id);
    }
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

// Validate invitation token (Public)
router.get('/:token', async (req, res, next) => {
  try {
    const { token } = req.params;
    const invitation = await invitationRepository.findByToken(token);
    if (!invitation || invitation.is_used || new Date() > invitation.expires_at) {
      return validationErrorResponse(res, 'Token undangan tidak valid atau kedaluwarsa');
    }
    const role = invitation.rt_id ? 'WARGA' : 'RT';
    return successResponse(res, 'Token valid', { role, ...invitation });
  } catch (error) {
    next(error);
  }
});

module.exports = router;

