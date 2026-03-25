const express = require('express');
const router = express.Router();
const usuarioController = require('../controllers/usuarioController');
const { verificarRol } = require('../middlewares/auth');

// Rutas con middleware de autenticación
router.get('/', verificarRol([1]), usuarioController.getUsuario);
router.get('/activos', verificarRol([1]), usuarioController.getUsuarioActivo);
router.get('/noactivos', verificarRol([1]), usuarioController.getUsuarioNoActivo);
router.post('/create', verificarRol([1]), usuarioController.createUsuario);
router.put('/:id', verificarRol([1]), usuarioController.updateUsuario);
router.patch('/:id/estado', verificarRol([1]), usuarioController.cambiarEstadoUsuario);

// Rutas sin middleware de autenticación
// router.get('/', usuarioController.getUsuario);
// router.get('/activos', usuarioController.getUsuarioActivo);
// router.get('/noactivos', usuarioController.getUsuarioNoActivo);
// router.post('/create', usuarioController.createUsuario);
// router.put('/:id', usuarioController.updateUsuario);
// router.patch('/:id/estado', usuarioController.cambiarEstadoUsuario);

// Endpoints sin middleware, fundamentales
router.post('/register', usuarioController.register);
router.post('/login', usuarioController.login);

module.exports = router;