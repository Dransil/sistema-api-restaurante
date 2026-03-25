const express = require('express');
const router = express.Router();
const productoController = require('../controllers/productoController');
const upload = require('../middlewares/upload')
const { verificarRol } = require('../middlewares/auth');

// Rutas con middleware de autenticación
router.get('/', verificarRol([1, 2]), productoController.getProductos);
router.get('/activos', verificarRol([1, 2]), productoController.getProductosActivos);
router.get('/noactivos', verificarRol([1, 2]), productoController.getProductosNoActivos);
router.post('/', upload.single('imagen_url'), verificarRol([1]), productoController.addProductosimg);
router.put('/:id', upload.single('imagen_url'), verificarRol([1]), productoController.updateProducto);
router.patch('/:id/estado', verificarRol([1, 2]), productoController.cambiarEstadoProducto);

// Rutas sin middleware de autenticación
// router.get('/', productoController.getProductos);
// router.get('/activos', productoController.getProductosActivos);
// router.get('/noactivos', productoController.getProductosNoActivos);
// router.post('/', upload.single('imagen_url'), productoController.addProductosimg);
// router.put('/:id', upload.single('imagen_url'), productoController.updateProducto);
// router.patch('/:id/estado', productoController.cambiarEstadoProducto);

module.exports = router;