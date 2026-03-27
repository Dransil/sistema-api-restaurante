const express = require('express');
const router = express.Router();
const configlocalController = require('../controllers/configlocalController');
const { verificarRol } = require('../middlewares/auth');

router.get('/', verificarRol([1, 2]), configlocalController.getConfigloc);
router.post('/', verificarRol([1]), configlocalController.saveConfig);

module.exports = router;