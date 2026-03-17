const express = require('express');
const router = express.Router();
const categoriasController = require('../controllers/categoriasController');

router.get('/', categoriasController.getCategorias);
router.get('/:id_categoria', categoriasController.getCategoriaById);
router.get('/productos/:id_categoria', categoriasController.getProductosByCategoria);
router.post('/', categoriasController.addCategoria);

module.exports = router;