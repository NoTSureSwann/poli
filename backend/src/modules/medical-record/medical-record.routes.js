const express = require('express');
const router = express.Router();
const medicalRecordController = require('./medical-record.controller');
const { authenticate } = require('../../middleware/auth');

router.use(authenticate);

router.get('/patient/:patientId', medicalRecordController.getMedicalRecordsByPatient);
router.get('/:id', medicalRecordController.getMedicalRecordById);
router.post('/', medicalRecordController.createMedicalRecord);

module.exports = router;
