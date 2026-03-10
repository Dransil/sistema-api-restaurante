const pool = require('../config/db');
const path = require('path');
const fs = require('fs');

// Obtener todos los productos
const getProductos = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM productos ORDER BY id ASC');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: 'Error: ' + err.message });
    }
}

// Obtener productos que esten activos
const getProductosActivos = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM productos WHERE activo = true ORDER BY id ASC');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: 'Error: ' + err.message });
    }
}

// Obtener productos que no esten activos
const getProductosNoActivos = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM productos WHERE activo = false ORDER BY id ASC');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: 'Error: ' + err.message });
    }
}

// Insertar un nuevo producto
const addProductos = async (req, res) => {
    const { nombre, precio, stock, categoria_id, imagen_url } = req.body;
    try {
        const query = ('INSERT INTO productos (nombre, precio, stock, categoria_id, imagen_url) VALUES ($1, $2, $3, $4, $5) RETURNING *')
        const values = [nombre, precio, stock, categoria_id, imagen_url];
        const result = await pool.query(query, values);
        res.status(201).json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: 'Error al crear productos: ' + err.message });
    }
}

// Insertar un nuevo producto con imagen
const addProductosimg = async (req, res) => {
    const { nombre, precio, stock, categoria_id } = req.body;
    const imagen_url = req.file ? `/uploads/${req.file.filename}` : null;

    try {
        const query = 'INSERT INTO productos (nombre, precio, stock, categoria_id, imagen_url) VALUES ($1, $2, $3, $4, $5) RETURNING *';
        const values = [nombre, precio, stock, categoria_id, imagen_url];
        const result = await pool.query(query, values);
        res.status(201).json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: 'Error al crear producto: ' + err.message });
    }
}

// Actualizar producto
const updateProducto = async (req, res) => {
    const {id} = req.params;
    const {nombre, precio, stock, categoria_id} = req.body;
    let imagen_url = null;
    try {
        // Seleccionar producto de la base de datos
        const productoSelec = await pool.query('SELECT imagen_url FROM productos WHERE id = $1', [id]);
        // Verificacion de imagenes en el disco
        if (req.file) {
            imagen_url = `/uploads/${req.file.filename}`;
            const antiguaimg = productoSelec.rows[0].imagen_url;
            //Si existe la imagen y la encuentra se borra con fs
            if(antiguaimg){
                const ruta = path.join(__dirname, '..', antiguaimg);
                if (fs.existsSync(ruta)) {
                    fs.unlinkSync(ruta);
                }
            }
        } else {
            imagen_url = productoSelec.rows[0].imagen_url;
        }
        const query = `UPDATE productos SET nombre = $1, precio = $2, stock = $3, categoria_id = $4, imagen_url = $5 
                       WHERE id = $6 RETURNING *`;
        const values = [nombre, precio, stock, categoria_id, imagen_url, id];
        const result = await pool.query(query,values);
        res.status(201).json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: "Error: " + err.message });
    }
}
module.exports = { getProductos, getProductosActivos, getProductosNoActivos, addProductos, addProductosimg, updateProducto };