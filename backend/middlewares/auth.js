const jwt = require('jsonwebtoken');

const verificarRol = (rolesPermitidos) => {
    return (req, res, next) => {
        // Obtener el token del header (Authorization: Bearer TOKEN)
        // En postman autorizar copiando y pegando el token
        const authHeader = req.headers['authorization'];
        const token = authHeader && authHeader.split(' ')[1];

        if (!token) {
            return res.status(401).json({ error: "Acceso denegado. No se proporcionó un token." });
        }

        try {
            // Verificacion del token
            const decoded = jwt.verify(token, process.env.JWT_SECRET);
            
            // Validación del rol
            // Comparacion en el rol_id, en el token esta como rol
            if (!rolesPermitidos.includes(decoded.rol)) {
                return res.status(403).json({ error: "No tienes permisos para acceder a este recurso." });
            }

            req.usuario = decoded;
            next();
        } catch (error) {
            res.status(403).json({ error: "Token inválido o expirado." });
        }
    };
};

module.exports = { verificarRol };