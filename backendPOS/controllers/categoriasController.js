const pool = require('../config/db');

// Obtener todas las categorías
const getCategorias = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM categorias ORDER BY id ASC');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: 'Error: ' + err.message });
    }
}
// Obtener categoría por id
const getCategoriaById = async (req, res) => {
    const { id } = req.params;

    try {
        const query = 'SELECT * FROM categorias WHERE id = $1';
        const result = await pool.query(query, [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ mensaje: "La categoría no existe" });
        }

        res.json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: 'Error al obtener la categoría: ' + err.message });
    }
};
// Insertar una nueva categoría
const addCategoria = async (req, res) => {
    const { nombre } = req.body;
    try {
        const query = ('INSERT INTO categorias (nombre) VALUES ($1) RETURNING *')
        const values = [nombre];
        const result = await pool.query(query, values);
        res.status(201).json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: 'Error al crear categorias: ' + err.message });
    }
}

// Obtener productos por categoría
const getProductosByCategoria = async (req, res) => {
    const { id_categoria } = req.params;

    try {
        const query = `
            SELECT 
                p.*, 
                c.nombre AS nombre_categoria 
            FROM productos p
            JOIN categorias c ON p.categoria_id = c.id
            WHERE p.categoria_id = $1 AND p.activo = true
            ORDER BY p.nombre ASC
        `;

        const result = await pool.query(query, [id_categoria]);

        if (result.rows.length === 0) {
            return res.status(404).json({
                mensaje: "No hay productos activos en esta categoría"
            });
        }

        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: 'Error al filtrar por categoría: ' + err.message });
    }
};

// Actualizar categoría
const updateCategoria = async (req, res) => {
    const { id } = req.params;
    const { nombre, activo } = req.body;

    try {
        const checkQuery = 'SELECT * FROM categorias WHERE id = $1';
        const checkResult = await pool.query(checkQuery, [id]);

        if (checkResult.rows.length === 0) {
            return res.status(404).json({ error: "Categoría no encontrada" });
        }

        const query = `
            UPDATE categorias 
            SET nombre = $1, activo = $2 
            WHERE id = $3 
            RETURNING *`;

        const values = [nombre, activo, id];
        const result = await pool.query(query, values);

        res.json({
            mensaje: "Categoría actualizada correctamente",
            categoria: result.rows[0]
        });

    } catch (err) {
        if (err.code === '23505') {
            return res.status(400).json({ error: "Ya existe una categoría con ese nombre" });
        }
        res.status(500).json({ error: "Error al actualizar categoría: " + err.message });
    }
};
module.exports = { getCategorias, getCategoriaById, addCategoria, getProductosByCategoria, updateCategoria };