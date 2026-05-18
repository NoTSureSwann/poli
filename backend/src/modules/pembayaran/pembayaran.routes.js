const express = require('express');
const router = express.Router();
const PembayaranController = require('./pembayaran.controller');
const { authenticate, authorize } = require('../../middleware/auth');

// Admin routes
router.get('/', authenticate, authorize('admin'), PembayaranController.getAll);
router.post('/', authenticate, authorize('admin'), PembayaranController.create);
router.get('/:id', authenticate, authorize('admin'), PembayaranController.getById);
router.put('/:id', authenticate, authorize('admin'), PembayaranController.update);
router.delete('/:id', authenticate, authorize('admin'), PembayaranController.delete);

// Struk routes
router.get('/:id/struk', authenticate, authorize('admin'), PembayaranController.getStruk);
router.get('/:id/struk-obat', authenticate, authorize('admin'), PembayaranController.getStrukObat);

// Report routes
router.get('/laporan/pendapatan', authenticate, authorize('admin'), PembayaranController.getRevenueReport);

module.exports = router;
