-- Tabla de roles
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL -- 'Administrador', 'Cajero'
);

-- Tabla de usuarios
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    rol_id INT REFERENCES roles(id),
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de categorías
CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

-- Tabla de productos
CREATE TABLE productos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    categoria_id INT REFERENCES categorias(id),
    imagen_url TEXT
);

-- Tabla de pedidos (Ventas)
CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_id INT REFERENCES usuarios(id),
    total DECIMAL(10,2) NOT NULL,
    estado VARCHAR(20) DEFAULT 'PAGADO' -- 'PAGADO', 'ANULADO'
);

-- Detalle del pedido
CREATE TABLE detalle_pedido (
    id SERIAL PRIMARY KEY,
    pedido_id INT REFERENCES pedidos(id) ON DELETE CASCADE,
    producto_id INT REFERENCES productos(id),
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL
);

-- Tabla para personalizar el sistema en cada instalación
CREATE TABLE configuracion_local (
    id SERIAL PRIMARY KEY,
    nombre_restaurante VARCHAR(150) NOT NULL,
    nit VARCHAR(20),
    direccion TEXT,
    telefono VARCHAR(20),
    ciudad VARCHAR(50) DEFAULT 'Cochabamba',
    moneda VARCHAR(5) DEFAULT 'Bs',
    logo_url TEXT,
    plan_actual VARCHAR(20) DEFAULT 'BASICO' -- 'BASICO', 'INTERMEDIO', 'PREMIUM'
);

INSERT INTO roles (nombre) VALUES ('Administrador'), ('Cajero');

INSERT INTO configuracion_local (nombre_restaurante, nit, ciudad, plan_actual) 
VALUES ('Restaurante prueba 1', '12345678', 'Bolivia', 'BASICO');