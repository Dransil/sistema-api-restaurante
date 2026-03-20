const express = require('express');
const router = express.Router();
const clienteController = require('../controllers/clienteController');
const { verificarRol } = require('../middlewares/auth');

// Rutas con middleware de autenticación
router.get('/', verificarRol([1,2]),clienteController.getClientes);
router.get('/:ci', verificarRol([1,2]),clienteController.getClienteByCI);
router.post('/', verificarRol([1,2]),clienteController.addCliente);
router.put('/:id', verificarRol([1,2]),clienteController.updateCliente);

// Rutas sin middleware de autenticación
//router.get('/', clienteController.getClientes);
//router.get('/:ci', clienteController.getClienteByCI);
//router.post('/', clienteController.addCliente);
//router.put('/:id', clienteController.updateCliente);

module.exports = router;