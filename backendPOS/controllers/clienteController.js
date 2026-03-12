const pool = require('../config/db');

// Obtener todos los clientes
const getClientes = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM clientes ORDER BY id DESC');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: 'Error al obtener clientes: ' + err.message });
    }
};

// Obtener cliente por CI
const getClienteByCI = async (req, res) => {
    const { ci } = req.params;
    try {
        const result = await pool.query('SELECT * FROM clientes WHERE ci = $1', [ci]);
        if (result.rows.length === 0) {
            return res.status(404).json({ mensaje: 'Cliente no encontrado' });
        }
        res.json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: 'Error al buscar cliente: ' + err.message });
    }
};

// Registrar nuevo cliente
const addCliente = async (req, res) => {
    const { razon_social, ci } = req.body;
    try {
        const result = await pool.query(
            'INSERT INTO clientes (razon_social, ci) VALUES ($1, $2) RETURNING *',
            [razon_social, ci]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        if (err.code === '23505') {
            return res.status(400).json({ error: 'Ya existe un cliente registrado con este CI' });
        }
        res.status(500).json({ error: 'Error al registrar cliente: ' + err.message });
    }
};
module.exports = { getClientes, getClienteByCI, addCliente }