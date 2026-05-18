const express = require('express');
const router = express.Router();
const dnsController = require('./dns.controller');

router.get('/resolve', dnsController.resolveHost);
router.get('/check', dnsController.checkEndpoint);
router.get('/info', dnsController.getInfo);

module.exports = router;
