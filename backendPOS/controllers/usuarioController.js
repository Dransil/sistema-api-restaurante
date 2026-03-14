const pool = require('../config/db');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const passSegura = (password) => {
    // Mínimo 8 caracteres, una mayúscula, una minúscula y un número
    const regex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d\w\W]{8,}$/;
    return regex.test(password);
}

// Obtener todos los usuarios
const getUsuario = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM usuarios ORDER BY id ASC');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: 'Error: ' + err.message });
    }
}
// Obtener todos los usuarios
const getUsuarioActivo = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM usuarios WHERE activo = true ORDER BY id ASC');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: 'Error: ' + err.message });
    }
}
// Obtener todos los usuarios
const getUsuarioNoActivo = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM usuarios WHERE activo = false ORDER BY id ASC');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: 'Error: ' + err.message });
    }
}

// Verificacion de login
const login = async (req, res) => {
    const { username, password } = req.body;
    try {
        // Verificacion de usuario
        const userResult = await pool.query('SELECT * FROM usuarios WHERE username = $1', [username]);
        if (userResult.rows.length === 0) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }
        const user = userResult.rows[0];
        if (!user.activo) {
            return res.status(403).json({
                error: 'Acceso denegado. Esta cuenta ha sido desactivada por el administrador.'
            });
        }
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
                rol_id: user.rol_id,
                name: user.name,
                first_name: user.first_name,
                second_name: user.second_name
            }
        })
    } catch (error) {
        res.status(500).json({ error: 'Error: ' + error.message });
    }
}

const register = async (req, res) => {
    const { username, password, rol_id } = req.body;

    if(!passSegura(password)){
        return res.status(400).json({ 
            error: 'La contraseña debe tener al menos 8 caracteres, una mayúscula, una minúscula y un número.' 
        });
    }
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

// Crear usuario
const createUsuario = async (params) => {
    const {
        username, password, rol_id,
        name, first_name, second_name,
        fecha_nac, celular, email
    } = req.body;

    try {
        const saltos = await bcrypt.genSalt(10);
        const pass_hash = await bcrypt.hash(password, saltos);

        const query = `
            INSERT INTO usuarios 
            (username, password_hash, rol_id, name, first_name, second_name, fecha_nac, celular, email) 
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) 
            RETURNING id, username, rol_id, name`;
        const values = [
            username, pass_hash, rol_id,
            name, first_name, second_name,
            fecha_nac, celular, email
        ];

        const nuevoUsuario = await pool.query(query, values);

        res.status(201).json(nuevoUsuario.rows[0]);
    } catch (error) {
        res.status(500).json({ error: 'Error: ' + error.message });
    }
}

// Actualizar usuario
const updateUsuario = async (req, res) => {
    const { id } = req.params;
    const { 
        username, password, rol_id, activo,
        name, first_name, second_name, 
        fecha_nac, celular, email 
    } = req.body;
    if (password && password.trim() !== "" && !passSegura(password)){
        return res.status(400).json({ 
            error: 'La contraseña debe tener al menos 8 caracteres, una mayúscula, una minúscula y un número.' 
        });
    }
    try {
        // Verificar si usuario existe
        const usuarioExist = await pool.query('SELECT * FROM usuarios WHERE id = $1', [id]);
        if (usuarioExist.rows.length === 0) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }
        
        let query, values;
        if (password && password.trim() !== "") {
            const saltos = await bcrypt.genSalt(10);
            const pass_hash = await bcrypt.hash(password, saltos);

            query = `UPDATE usuarios SET 
                     username = $1, password_hash = $2, rol_id = $3, activo = $4, 
                     name = $5, first_name = $6, second_name = $7, fecha_nac = $8, 
                     celular = $9, email = $10 
                     WHERE id = $11 RETURNING *`;
            values = [username, pass_hash, rol_id, activo, name, first_name, second_name, fecha_nac, celular, email, id];
        } else {
            query = `UPDATE usuarios SET 
                     username = $1, rol_id = $2, activo = $3, 
                     name = $4, first_name = $5, second_name = $6, fecha_nac = $7, 
                     celular = $8, email = $9 
                     WHERE id = $10 RETURNING *`;
            values = [username, rol_id, activo, name, first_name, second_name, fecha_nac, celular, email, id];
        }
        const result = await pool.query(query, values);
        res.json({ mensaje: "Usuario actualizado", usuario: result.rows[0] });
    } catch (err) {
        res.status(500).json({ error: "Error: " + err.message });
    }
}
// Nota: agregar control de datos para que genere una pass segura

// Cambiar el estado del usuarios
const cambiarEstadoUsuario = async (req, res) => {
    const { id } = req.params;
    const { activo } = req.body;

    try {
        const query = 'UPDATE usuarios SET activo = $1 WHERE id = $2 RETURNING id, username, activo';
        const values = [activo, id];
        const result = await pool.query(query, values);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Usuario no encontrado" });
        }

        const estado = activo ? 'activado' : 'desactivado';
        res.json({
            mensaje: `Usuario ${estado} correctamente`,
            usuario: result.rows[0]
        });

    } catch (err) {
        res.status(500).json({ error: "Error al cambiar estado: " + err.message });
    }
}
module.exports = { login, register, getUsuario, createUsuario, updateUsuario, cambiarEstadoUsuario, getUsuarioActivo, getUsuarioNoActivo };