const express = require('express');
const router = express.Router();
const clienteController = require('../controllers/clienteController');

router.get('/', clienteController.getClientes);
router.get('/:ci', clienteController.getClienteByCI);
router.post('/', clienteController.addCliente);
router.put('/:id', clienteController.updateCliente);

module.exports = router;