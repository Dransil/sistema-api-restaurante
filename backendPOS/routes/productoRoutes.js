const express = require('express');
const router = express.Router();
const productoController = require('../controllers/productoController');
const upload = require('../middlewares/upload')

router.get('/', productoController.getProductos);
router.get('/activos', productoController.getProductosActivos);
router.get('/noactivos', productoController.getProductosNoActivos);
router.post('/', upload.single('imagen_url'), productoController.addProductosimg);
router.put('/:id', upload.single('imagen_url'), productoController.updateProducto);
router.patch('/:id/estado', productoController.cambiarEstadoProducto);

module.exports = router;