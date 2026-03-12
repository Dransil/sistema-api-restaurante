const express = require('express');
const cors = require('cors');
require('dotenv').config();
const path = require('path');
// Importar rutas
const productoRoutes = require('./routes/productoRoutes');
const categoriasRoutes = require('./routes/categoriasRoutes');
const rolesRoutes = require('./routes/rolesRoutes');
const usuarioRoutes = require('./routes/usuarioRoutes');
const pedidosRoutes = require('./routes/pedidoRoutes');
const detallepedidoRoutes = require('./routes/detallepedidoRoutes');
const clienteRoutes = require('./routes/clienteRoutes')
const configlocalRoutes = require('./routes/configlocalRoutes');
// Express y puerto
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware CORS
app.use(cors()); 
app.use(express.json());

app.get('/test', (req, res) => {
  res.send('Backend funcionando correctamente');
});
// Rutas
app.use('/productos', productoRoutes);
app.use('/categorias', categoriasRoutes);
app.use('/roles', rolesRoutes);
app.use('/usuarios', usuarioRoutes);
app.use('/pedidos', pedidosRoutes);
app.use('/detallepedido', detallepedidoRoutes);
app.use('/clientes', clienteRoutes);
app.use('/configloc', configlocalRoutes);
//Servir carpeta uploads
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
app.listen(PORT, () => {
  console.log(`Servicios en línea: http://localhost:${PORT}`);
});