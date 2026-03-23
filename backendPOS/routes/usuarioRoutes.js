const express = require('express');
const router = express.Router();
const usuarioController = require('../controllers/usuarioController');
const { verificarRol } = require('../middlewares/auth');

router.get('/', usuarioController.getUsuario);
router.get('/activos', usuarioController.getUsuarioActivo);
router.get('/noactivos', usuarioController.getUsuarioNoActivo);
router.post('/register', usuarioController.register);
router.post('/create', usuarioController.createUsuario);
router.post('/login', usuarioController.login);
router.put('/:id', usuarioController.updateUsuario);
router.patch('/:id/estado', usuarioController.cambiarEstadoUsuario);
module.exports = router;