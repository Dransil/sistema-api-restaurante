const express = require('express');
const router = express.Router();
const clienteController = require('../controllers/clienteController');
const { verificarRol } = require('../middlewares/auth');

router.get('/', verificarRol([1,2]),clienteController.getClientes);
//router.get('/', clienteController.getClientes);
router.get('/:ci', clienteController.getClienteByCI);
router.post('/', clienteController.addCliente);
router.put('/:id', clienteController.updateCliente);

module.exports = router;