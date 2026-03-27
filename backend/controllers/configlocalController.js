const pool = require('../config/db');

const getConfigloc = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM configuracion_local LIMIT 1');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: 'Error: ' + err.message });
    }
}

const saveConfig = async (req, res) => {
    const { nombre_restaurante, nit, direccion, telefono, ciudad, moneda, logo_url } = req.body;

    try {
        const check = await pool.query('SELECT id FROM configuracion_local LIMIT 1');

        let query;
        let values = [nombre_restaurante, nit, direccion, telefono, ciudad, moneda, logo_url];

        if (check.rows.length > 0) {
            query = `
                UPDATE configuracion_local 
                SET nombre_restaurante = $1, nit = $2, direccion = $3, 
                    telefono = $4, ciudad = $5, moneda = $6, logo_url = $7
                WHERE id = $8
                RETURNING *`;
        } else {
            query = `
                INSERT INTO configuracion_local 
                (nombre_restaurante, nit, direccion, telefono, ciudad, moneda, logo_url)
                VALUES ($1, $2, $3, $4, $5, $6, $7)
                RETURNING *`;
        }

        const result = await pool.query(query, values);
        res.json({ mensaje: "Configuración guardada", datos: result.rows });

    } catch (err) {
        res.status(500).json({ error: "Error al procesar configuración: " + err.message });
    }
};

module.exports = { getConfigloc, saveConfig }