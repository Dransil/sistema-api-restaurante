const express = require('express');
const router = express.Router();
const reporteController = require('../controllers/reporteController');

router.get('/diario', reporteController.getResumenDiario);
router.get('/top', reporteController.getTopProductos);
router.get('/rango', reporteController.getVentasPorRango);

module.exports = router;