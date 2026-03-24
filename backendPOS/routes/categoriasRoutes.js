const express = require('express');
const router = express.Router();
const categoriasController = require('../controllers/categoriasController');
const { verificarRol } = require('../middlewares/auth');
// Rutas con middleware de autenticación
router.get('/', verificarRol([1]),categoriasController.getCategorias);
router.get('/:id_categoria', verificarRol([1]),categoriasController.getCategoriaById);
router.get('/productos/:id_categoria', verificarRol([1]),categoriasController.getProductosByCategoria);
router.post('/', verificarRol([1]),categoriasController.addCategoria);
router.put('/:id', verificarRol([1]),categoriasController.updateCategoria);

// Rutas sin middleware de autenticación
//router.get('/', categoriasController.getCategorias);
//router.get('/:id_categoria', categoriasController.getCategoriaById);
//router.get('/productos/:id_categoria', categoriasController.getProductosByCategoria);
// router.post('/', categoriasController.addCategoria);
//router.put('/:id', categoriasController.updateCategoria);

module.exports = router;