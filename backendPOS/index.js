const express = require('express');
const cors = require('cors');
require('dotenv').config();
// Importar rutas
const productoRoutes = require('./routes/productoRoutes');
const usuarioRoutes = require('./routes/usuarioRoutes');
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
app.use('/usuarios', usuarioRoutes);
app.use('/productos', productoRoutes);

app.listen(PORT, () => {
  console.log(`Servicios en línea: http://localhost:${PORT}`);
});