const express = require('express');
const router = express.Router();
const productoController = require('../controllers/productoController');
const upload = require('../middlewares/upload')

router.get('/', productoController.getProductos);
//router.post('/',productoController.addProductos); // Antiguo metodo sin imagen
router.post('/', upload.single('imagen_url'), productoController.addProductosimg);

module.exports = router;