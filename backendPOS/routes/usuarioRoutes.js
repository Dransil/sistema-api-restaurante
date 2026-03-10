const express = require('express');
const router = express.Router();
const usuarioController = require('../controllers/usuarioController');

router.get('/', usuarioController.getUsuario);
router.post('/register', usuarioController.register);
router.post('/create', usuarioController.createUsuario);
router.post('/login', usuarioController.login);
router.put('/:id', usuarioController.updateUsuario);
router.patch('/:id/estado', usuarioController.cambiarEstadoUsuario);
module.exports = router;