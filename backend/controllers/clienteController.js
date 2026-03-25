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

// Actualizar cliente
const updateCliente = async (req, res) => {
    const { id } = req.params;
    const { razon_social, ci } = req.body;

    try {
        const clienteExistente = await pool.query('SELECT * FROM clientes WHERE id = $1', [id]);
        
        if (clienteExistente.rows.length === 0) {
            return res.status(404).json({ error: "Cliente no encontrado" });
        }

        const query = `
            UPDATE clientes 
            SET razon_social = $1, ci = $2 
            WHERE id = $3 
            RETURNING *`;
        
        const values = [razon_social, ci, id];
        const result = await pool.query(query, values);

        res.json({ mensaje: "Cliente actualizado correctamente", cliente: result.rows[0] });

    } catch (err) {
        if (err.code === '23505') {
            return res.status(400).json({ error: "El CI ya está registrado con otro cliente" });
        }
        res.status(500).json({ error: "Error al actualizar cliente: " + err.message });
    }
};

module.exports = { getClientes, getClienteByCI, addCliente, updateCliente }