const express = require('express');
const router = express.Router();
const reporteController = require('../controllers/reporteController');
const { verificarRol } = require('../middlewares/auth');

// Rutas con middleware de autenticación
router.get('/diario', verificarRol([1]), reporteController.getResumenDiario);
router.get('/top', verificarRol([1]), reporteController.getTopProductos);
router.get('/rango', verificarRol([1]), reporteController.getVentasPorRango);
router.get('/factura', verificarRol([1]), reporteController.getReporteFacturacion);
router.get('/factura/:id', verificarRol([1]), reporteController.getFacturaDetalle);

// Rutas sin middleware de autenticación
// router.get('/diario', reporteController.getResumenDiario);
// router.get('/top', reporteController.getTopProductos);
// router.get('/rango', reporteController.getVentasPorRango);
// router.get('/factura', reporteController.getReporteFacturacion);
// router.get('/factura/:id', reporteController.getFacturaDetalle);

module.exports = router;