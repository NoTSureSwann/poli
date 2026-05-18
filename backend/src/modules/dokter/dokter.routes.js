const express = require('express');
const DokterController = require('./dokter.controller');
const { authenticate, authorize } = require('../../middleware/auth');

const router = express.Router();

// Public routes (no auth required)
router.get('/', DokterController.getAll);
router.get('/:id', DokterController.getById);
router.get('/poli/:poli_id', DokterController.getByPoli);

// Admin routes (auth + admin role required)
router.post('/', authenticate, authorize('admin'), DokterController.create);
router.put('/:id', authenticate, authorize('admin'), DokterController.update);
router.delete('/:id', authenticate, authorize('admin'), DokterController.delete);
router.get('/stats/pricing', authenticate, authorize('admin'), DokterController.getPricingStats);

module.exports = router;
