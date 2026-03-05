const pool = require('../config/db');

const getCategoria = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM categorias ORDER BY id ASC');
        res.json(result.json);
    } catch (err) {
        res.status(500).json({ error: 'Error: ' + err.message});
    }
}

module.exports = {getCategoria};