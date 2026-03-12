const pool = require('../config/db');

const getPedido = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM pedidos ORDER BY id ASC');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: 'Error: ' + err.message });
    }
}

const registrarVenta = async (req, res) => {
    const { usuario_id, cliente_id, total, detalles } = req.body;
    const client = await pool.connect();

    try {
        await client.query('BEGIN');
        // Insertar la cabecera (Tabla pedidos)
        const pedidoRes = await client.query(
            'INSERT INTO pedidos (usuario_id, cliente_id, total) VALUES ($1, $2, $3) RETURNING id',
            [usuario_id, cliente_id || null, total]
        );
        const pedidoId = pedidoRes.rows[0].id;

        // Insertar los detalles (Tabla detalle_pedido)
        for (const item of detalles) {
            // Calculo del subtotal
            const subtotal = item.cantidad * item.precio_unitario;

            await client.query(
                `INSERT INTO detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario, subtotal) 
                 VALUES ($1, $2, $3, $4, $5)`,
                [pedidoId, item.producto_id, item.cantidad, item.precio_unitario, subtotal]
            );

            // Actualizar Stock
            const stockRes = await client.query(
                'UPDATE productos SET stock = stock - $1 WHERE id = $2 RETURNING stock, nombre',
                [item.cantidad, item.producto_id]
            );

            if (stockRes.rows[0].stock < 0) {
                throw new Error(`Stock insuficiente para el producto: ${stockRes.rows[0].nombre}`);
            }
        }

        // Incrementar contador del cliente para sus pedidos realizados
        if (cliente_id) {
            await client.query(
                'UPDATE clientes SET pedidos_realizados = pedidos_realizados + 1 WHERE id = $1',
                [cliente_id]
            );
        }

        await client.query('COMMIT');
        res.status(201).json({ 
            mensaje: "Venta completada", 
            pedido_id: pedidoId 
        });

    } catch (error) {
        await client.query('ROLLBACK');
        res.status(500).json({ error: error.message });
    } finally {
        client.release();
    }
};

module.exports = {getPedido, registrarVenta};