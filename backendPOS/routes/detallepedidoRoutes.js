const express = require('express');
const router = express.Router();
const detallepedidoController = require('../controllers/detallepedidoController');

router.get('/', detallepedidoController.getDetallepedido);

module.exports = router;