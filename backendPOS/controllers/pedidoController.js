const pool = require('../config/db');

const getPedido = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM pedidos ORDER BY id ASC');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: 'Error: ' + err.message });
    }
}

module.exports = {getPedido};