const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth.middleware');
const { isRT, isRW } = require('../middleware/role.middleware');
const facilitiesController = require('../controllers/facilities.controller');

// --- Catalog Routes ---
// POST /api/facilities (RT Adds item)
router.post('/', authenticate, isRT(), facilitiesController.createFacility);

// GET /api/facilities (Warga views items)
router.get('/', authenticate, facilitiesController.getFacilities);

// PATCH /api/facilities/:id (RT edits item)
router.patch('/:id', authenticate, isRT(), facilitiesController.updateFacility);

// DELETE /api/facilities/:id (RT deletes item)
router.delete('/:id', authenticate, isRT(), facilitiesController.deleteFacility);


// --- Reservation Routes ---
// POST /api/facilities/:id/reserve (Warga books an item)
router.post('/:id/reserve', authenticate, facilitiesController.createReservation);

// GET /api/facilities/reservations/list (RT sees all bookings)
// Note: Placed before /:id to avoid mistaking 'reservations' as a facility ID in a broader generic route if any existed, though we use different base path anyway
router.get('/reservations/all', authenticate, isRT(), facilitiesController.getReservations);

// PATCH /api/facilities/reservations/:id/verify (RT Approves/Rejects booking)
router.patch('/reservations/:id/verify', authenticate, isRT(), facilitiesController.verifyReservation);

module.exports = router;

