const express = require('express');
const router = express.Router();
const pedidoController = require('../controllers/pedidoController');
const { verificarRol } = require('../middlewares/auth');

// Rutas con middleware de autenticación
router.get('/', verificarRol([1, 2]), pedidoController.getPedido);
router.post('/', verificarRol([1, 2]), pedidoController.registrarVenta);
// Rutas sin middleware de autenticación
// router.get('/', pedidoController.getPedido);
// router.post('/', pedidoController.registrarVenta);

module.exports = router;