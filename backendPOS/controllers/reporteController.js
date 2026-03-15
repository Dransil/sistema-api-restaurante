const pool = require('../config/db');

// Resumen de ventas diarias
const getResumenDiario = async (req, res) => {
    try {
        const query = `
            SELECT 
                COUNT(id) as ventas_cantidad,
                COALESCE(SUM(total), 0) as total_dinero
            FROM pedidos 
            WHERE fecha_hora::date = CURRENT_DATE 
            AND estado = 'PAGADO'
        `;
        const result = await pool.query(query);
        res.json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: 'Error en resumen diario: ' + err.message });
    }
};

// Top de los productos más vendidos
const getTopProductos = async (req, res) => {
    try {
        const query = `
            SELECT 
                p.nombre, 
                SUM(dp.cantidad) as total_unidades,
                SUM(dp.subtotal) as total_recaudado
            FROM detalle_pedido dp
            JOIN productos p ON dp.producto_id = p.id
            JOIN pedidos ped ON dp.pedido_id = ped.id
            WHERE ped.estado = 'PAGADO'
            GROUP BY p.id, p.nombre
            ORDER BY total_unidades DESC
            LIMIT 5
        `;
        const result = await pool.query(query);
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: 'Error en top productos: ' + err.message });
    }
};

// Ventas por rango de fechas
const getVentasPorRango = async (req, res) => {
    const { inicio, fin } = req.query;

    try {
        const query = `
            SELECT 
                p.id, 
                p.fecha_hora, 
                p.total, 
                u.username as cajero,
                COALESCE(c.razon_social, 'Venta Rápida') as cliente
            FROM pedidos p
            LEFT JOIN usuarios u ON p.usuario_id = u.id
            LEFT JOIN clientes c ON p.cliente_id = c.id
            WHERE p.fecha_hora::date BETWEEN $1 AND $2
            AND p.estado = 'PAGADO'
            ORDER BY p.fecha_hora DESC
        `;
        const result = await pool.query(query, [inicio, fin]);
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: 'Error en reporte por rango: ' + err.message });
    }
};

// Venta detallada para control
const getVentasDetalladas = async (req, res) => {
    const { inicio, fin } = req.query;
    try {
        const query = `
            SELECT p.id, p.fecha_hora, p.total, u.username as cajero, c.razon_social as cliente
            FROM pedidos p
            LEFT JOIN usuarios u ON p.usuario_id = u.id
            LEFT JOIN clientes c ON p.cliente_id = c.id
            WHERE p.fecha_hora::date BETWEEN $1 AND $2
            ORDER BY p.fecha_hora DESC
        `;
        const result = await pool.query(query, [inicio, fin]);
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

module.exports = { getResumenDiario, getTopProductos, getVentasPorRango, getVentasDetalladas };