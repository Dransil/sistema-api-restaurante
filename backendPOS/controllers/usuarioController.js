const pool = require('../config/db');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const login = async (req, res) => {
    const {username, password} = req.body;
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
        const token =jwt.sign(
            {id:user.id, rol: user.rol_id},
            process.env.JWT_SECRET,
            {expiresIn: '8h'}
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
    const {username, password, rol_id} = req.body;
    try {
        const salt = await bcrypt.genSalt(10);
        const pass_hash = await bcrypt.hash(password, salt);

        const nuevoUsuario = await pool.query('INSERT INTO usuarios (username, password_hash, rol_id) VALUES ($1, $2, $3) RETURNING id, username, rol_id',
        [username, pass_hash, rol_id]);

        res.json(nuevoUsuario.rows[0]);
    } catch (error) {
        res.status(500).json({ error: 'Error: ' + error.message });
    }
}

module.exports = {login, register};