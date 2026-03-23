const express = require('express');
const router = express.Router();
const pedidoController = require('../controllers/pedidoController');
const { verificarRol } = require('../middlewares/auth');

router.get('/', pedidoController.getPedido);
router.post('/', pedidoController.registrarVenta);

module.exports = router;