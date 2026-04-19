const express = require('express');
const router = express.Router();
const pembayaranController = require('./pembayaran.controller');
const { authenticate, authorize } = require('../../middleware/auth');

router.use(authenticate);

// Only admin can create payments and trigger notifications
router.post('/', authorize('admin'), pembayaranController.createPayment);
router.get('/:id', pembayaranController.getPaymentById);

module.exports = router;
