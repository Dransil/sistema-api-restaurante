const express = require('express');
const router = express.Router();
const detallepedidoController = require('../controllers/detallepedidoController');
const { verificarRol } = require('../middlewares/auth');

router.get('/', verificarRol([1]),detallepedidoController.getDetallepedido);
router.get('/:id_pedido', verificarRol([1]),detallepedidoController.getDetalleByPedidoId);

module.exports = router;