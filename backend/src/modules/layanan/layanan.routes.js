const express = require('express');
const LayananController = require('./layanan.controller');
const { authenticate, authorize } = require('../../middleware/auth');

const router = express.Router();

// Public routes (no auth required)
router.get('/', LayananController.getAll);
router.get('/:id', LayananController.getById);

// Admin routes (auth + admin role required)
router.post('/', authenticate, authorize('admin'), LayananController.create);
router.put('/:id', authenticate, authorize('admin'), LayananController.update);
router.delete('/:id', authenticate, authorize('admin'), LayananController.delete);
router.get('/stats/pricing-by-category', authenticate, authorize('admin'), LayananController.getPricingByCategory);

module.exports = router;
