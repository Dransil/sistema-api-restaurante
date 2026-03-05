const pool = require('../config/db');

// Obtener todas las categorías
const getCategorias = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM categorias ORDER BY id ASC');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: 'Error: ' + err.message});
    }
}

// Insertar una nueva categoría
const addCategoria = async (req, res) => {
    const {nombre} = req.body;
    try {
        const query = ('INSERT INTO categorias (nombre) VALUES ($1) RETURNING *')
        const values = [nombre];
        const result = await pool.query(query, values);
        res.status(201).json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: 'Error al crear categorias: ' + err.message});
    }
}
module.exports = {getCategorias, addCategoria};