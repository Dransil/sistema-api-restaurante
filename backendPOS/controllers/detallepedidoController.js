const pool = require('../config/db');

const getDetallepedido = async (req, res) => {
    try {
        const result = pool.query('SELECT * FROM detalle_pedido ORDER BY id ASC');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: 'Error: ' + err.message });
    }
}

module.exports = {getDetallepedido};