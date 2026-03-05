const pool = require('../config/db');

// Obtener todas las categorías
const getProductos = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM productos ORDER BY id ASC');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: 'Error: ' + err.message });
    }
}

// Insertar un nuev producto
const addProductos = async (req, res) => {
    const {nombre, precio, stock, categoria_id, imagen_url} = req.body;
    try {
        const query = ('INSERT INTO productos (nombre, precio, stock, categoria_id, imagen_url) VALUES ($1, $2, $3, $4, $5) RETURNING *')
        const values = [nombre, precio, stock, categoria_id, imagen_url];
        const result = await pool.query(query, values);
        res.status(201).json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: 'Error al crear productos: ' + err.message});
    }
}

module.exports = {getProductos, addProductos};