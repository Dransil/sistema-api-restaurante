const express = require('express');
const router = express.Router();
const configlocalController = require('../controllers/configlocalController');
const { verificarRol } = require('../middlewares/auth');

router.get('/', verificarRol([1]), configlocalController.getConfigloc);

module.exports = router;