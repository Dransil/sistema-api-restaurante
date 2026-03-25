const pool = require('../config/db');

const getDetallepedido = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM detalle_pedido ORDER BY id ASC');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: 'Error: ' + err.message });
    }
}

const getDetalleByPedidoId = async (req, res) => {
    const { id_pedido } = req.params; // El ID que viene en la URL

    try {
        const query = `
            SELECT 
                dp.id,
                dp.pedido_id,
                dp.producto_id,
                p.nombre AS producto_nombre,
                p.imagen_url,
                dp.cantidad,
                dp.precio_unitario,
                dp.subtotal
            FROM detalle_pedido dp
            JOIN productos p ON dp.producto_id = p.id
            WHERE dp.pedido_id = $1
            ORDER BY dp.id ASC
        `;
        
        const result = await pool.query(query, [id_pedido]);

        if (result.rows.length === 0) {
            return res.status(404).json({ mensaje: "No se encontraron detalles para este pedido" });
        }

        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: 'Error al obtener el detalle: ' + err.message });
    }
}

module.exports = {getDetallepedido, getDetalleByPedidoId};