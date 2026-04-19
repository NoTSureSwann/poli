const express = require('express');
const router = express.Router();
const pasienController = require('./pasien.controller');
const { authenticate } = require('../../middleware/auth');

router.use(authenticate);

router.get('/', pasienController.getAllPasien);
router.get('/:id', pasienController.getPasienById);
router.post('/', pasienController.createPasien);
router.put('/:id', pasienController.updatePasien);

module.exports = router;
