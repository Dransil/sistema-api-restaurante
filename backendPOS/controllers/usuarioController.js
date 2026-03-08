const pool = require('../config/db');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const getUsuario = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM usuarios ORDER BY id ASC');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: 'Error: ' + err.message });
    }
}
const login = async (req, res) => {
    const { username, password } = req.body;
    try {
        // Verificacion de usuario
        const userResult = await pool.query('SELECT * FROM usuarios WHERE username = $1', [username]);
        if (userResult.rows.length === 0) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }
        const user = userResult.rows[0];
        // Verificacion de contraseña
        const passValid = await bcrypt.compare(password, user.password_hash);
        if (!passValid) {
            return res.status(401).json({ error: 'Contraseña incorrecta' });
        }
        // Generacion de token JWT
        const token = jwt.sign(
            { id: user.id, rol: user.rol_id },
            process.env.JWT_SECRET,
            { expiresIn: '8h' }
        )
        res.json({
            message: 'Login correcto',
            token,
            user: {
                id: user.id,
                username: user.username,
                rol_id: user.rol_id
            }
        })
    } catch (error) {
        res.status(500).json({ error: 'Error: ' + error.message });
    }
}

const register = async (req, res) => {
    const { username, password, rol_id } = req.body;
    try {
        const saltos = await bcrypt.genSalt(10);
        const pass_hash = await bcrypt.hash(password, saltos);

        const nuevoUsuario = await pool.query('INSERT INTO usuarios (username, password_hash, rol_id) VALUES ($1, $2, $3) RETURNING id, username, rol_id',
            [username, pass_hash, rol_id]);

        res.json(nuevoUsuario.rows[0]);
    } catch (error) {
        res.status(500).json({ error: 'Error: ' + error.message });
    }
}

const updateUsuario = async (req, res) => {
    const { id } = req.params;
    const { username, password, rol_id, activo } = req.body;
    try {
        // Verificar si usuario existe
        const usuarioExist = await pool.query('SELECT * FROM usuarios WHERE id = $1', [id]);
        if (usuarioExist.rows.length === 0) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }
        //
        let query, values;
        if (password && password.trim() !== "") {
            const saltos = await bcrypt.genSalt(10);
            const pass_hash = await bcrypt.hash(password, saltos);

            query = `UPDATE usuarios SET username = $1, password_hash = $2, rol_id = $3, activo = $4 
                     WHERE id = $5 RETURNING id, username, rol_id, activo`;
            values = [username, pass_hash, rol_id, activo, id];
        } else {
            query = `UPDATE usuarios SET username = $1, rol_id = $2, activo = $3
                     WHERE id = $4 RETURNING id, username, rol_id, activo`;
            values = [username, rol_id, activo, id];
        }
        const result = await pool.query(query, values);
        res.json({ mensaje: "Usuario actualizado", usuario: result.rows[0] });
    } catch (err) {
        res.status(500).json({ error: "Error: " + err.message });
    }
}
// Nota: agregar control de datos para que genere una pass segura

module.exports = { login, register, getUsuario, updateUsuario };