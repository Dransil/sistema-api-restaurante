const express = require('express');
const router = express.Router();
const detallepedidoController = require('../controllers/detallepedidoController');

router.get('/', detallepedidoController.getDetallepedido);
router.get('/:id_pedido', detallepedidoController.getDetalleByPedidoId);

module.exports = router;