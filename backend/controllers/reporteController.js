const pool = require('../config/db');
const { get } = require('../routes/productoRoutes');

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

// Obtener todas las facturas
const getReporteFacturacion = async (req, res) => {
    const { inicio, fin } = req.query;

    try {
        const query = `
            SELECT 
                p.id AS factura_nro,
                p.fecha_hora,
                COALESCE(c.razon_social, 'Venta Rápida') AS cliente,
                COALESCE(c.ci, 'S/N') AS nit_ci,
                prod.nombre AS producto,
                dp.cantidad,
                dp.precio_unitario,
                dp.subtotal,
                p.total AS total_factura
            FROM pedidos p
            LEFT JOIN clientes c ON p.cliente_id = c.id
            JOIN detalle_pedido dp ON p.id = dp.pedido_id
            JOIN productos prod ON dp.producto_id = prod.id
            WHERE p.fecha_hora::date BETWEEN $1 AND $2
            AND p.estado = 'PAGADO'
            ORDER BY p.id DESC, prod.nombre ASC
        `;
        
        const result = await pool.query(query, [inicio, fin]);
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: 'Error en reporte detallado: ' + err.message });
    }
};
// Obtener factura detallada (Para impresión)
const getFacturaDetalle = async (req, res) => {
    const { id } = req.params;

    try {
        // Obtener la cabecera del pedido y datos del cliente
        const pedidoQuery = `
            SELECT 
                p.id AS nro_factura,
                p.fecha_hora,
                p.total,
                p.estado,
                u.username AS cajero,
                COALESCE(c.razon_social, 'Venta Rápida') AS cliente_nombre,
                COALESCE(c.ci, 'S/N') AS cliente_ci
            FROM pedidos p
            LEFT JOIN usuarios u ON p.usuario_id = u.id
            LEFT JOIN clientes c ON p.cliente_id = c.id
            WHERE p.id = $1
        `;
        
        const pedidoRes = await pool.query(pedidoQuery, [id]);

        if (pedidoRes.rows.length === 0) {
            return res.status(404).json({ error: "Factura no encontrada" });
        }

        // Obtener los productos de esa factura
        const detallesQuery = `
            SELECT 
                prod.nombre AS producto,
                dp.cantidad,
                dp.precio_unitario,
                dp.subtotal
            FROM detalle_pedido dp
            JOIN productos prod ON dp.producto_id = prod.id
            WHERE dp.pedido_id = $1
        `;
        
        const detallesRes = await pool.query(detallesQuery, [id]);

        const facturaCompleta = {
            ...pedidoRes.rows[0],
            items: detallesRes.rows
        };

        res.json(facturaCompleta);

    } catch (err) {
        res.status(500).json({ error: 'Error al generar factura: ' + err.message });
    }
};
module.exports = { getResumenDiario, getTopProductos, getVentasPorRango, getVentasDetalladas, getReporteFacturacion, getFacturaDetalle };