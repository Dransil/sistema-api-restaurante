const pool = require('../config/db');

const getConfigloc = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM configuracion_local LIMIT 1');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: 'Error: ' + err.message });
    }
}

module.exports = { getConfigloc }