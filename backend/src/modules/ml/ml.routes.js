const express = require('express');
const router = express.Router();
const mlController = require('./ml.controller');
const { authenticate } = require('../../middleware/auth');

// GET /api/ml/export
// Exports medical data for ML
router.get('/export', authenticate, mlController.exportMLData);

module.exports = router;
