const express = require('express');
const router = express.Router();
const categoriasController = require('../controllers/categoriasController');

router.get('/', categoriasController.getCategorias);
router.post('/', categoriasController.addCategoria);

module.exports = router;