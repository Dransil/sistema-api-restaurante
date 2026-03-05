const express = require('express');
const router = express.Router();
const configlocalController = require('../controllers/configlocalController');

router.get('/', configlocalController.getConfigloc);

module.exports = router;