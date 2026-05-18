const express = require('express');
const ObatController = require('./obat.controller');
const { authenticate, authorize } = require('../../middleware/auth');

const router = express.Router();

// Admin routes (all obat routes require auth + admin role)
router.get('/', authenticate, authorize('admin'), ObatController.getAll);
router.get('/:id', authenticate, authorize('admin'), ObatController.getById);
router.post('/', authenticate, authorize('admin'), ObatController.create);
router.put('/:id', authenticate, authorize('admin'), ObatController.update);
router.delete('/:id', authenticate, authorize('admin'), ObatController.delete);
router.get('/stats/low-stock', authenticate, authorize('admin'), ObatController.getLowStock);
router.get('/stats/overview', authenticate, authorize('admin'), ObatController.getStats);

module.exports = router;
