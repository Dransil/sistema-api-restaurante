const express = require('express');
const router = express.Router();
const detallepedidoController = require('../controllers/detallepedidoController');
const { verificarRol } = require('../middlewares/auth');

// Rutas con middleware de autenticación
router.get('/', verificarRol([1]),detallepedidoController.getDetallepedido);
router.get('/:id_pedido', verificarRol([1]),detallepedidoController.getDetalleByPedidoId);
// Rutas sin middleware de autenticación
//router.get('/', detallepedidoController.getDetallepedido);
//router.get('/:id_pedido', detallepedidoController.getDetalleByPedidoId);

module.exports = router;