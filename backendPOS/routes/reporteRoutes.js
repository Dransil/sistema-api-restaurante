const express = require('express');
const router = express.Router();
const reporteController = require('../controllers/reporteController');
const { verificarRol } = require('../middlewares/auth');

router.get('/diario', reporteController.getResumenDiario);
router.get('/top', reporteController.getTopProductos);
router.get('/rango', reporteController.getVentasPorRango);
router.get('/factura', reporteController.getReporteFacturacion);
router.get('/factura/:id', reporteController.getFacturaDetalle);
module.exports = router;