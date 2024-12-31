DROP DATABASE IF EXISTS aceros_duran;

CREATE DATABASE aceros_duran;
USE aceros_duran;

-- Tabla sucursales
CREATE TABLE sucursales (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(255),
    telefono VARCHAR(20),
    email VARCHAR(100)
);

-- Tabla roles
CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT
);

-- Tabla usuarios
CREATE TABLE usuarios (
    CURP VARCHAR(19) PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    nombre_completo VARCHAR(100) NOT NULL,
    numero_telefono VARCHAR(20),
    rol_id INT NOT NULL,
    sucursal_id INT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (rol_id) REFERENCES roles(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (sucursal_id) REFERENCES sucursales(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla categorias_clientes
CREATE TABLE categorias_clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT,
    frecuencia_minima INT,
    monto_minimo DECIMAL(12,2),
    descuento DECIMAL(5,2),
    periodo_inactividad INT
);

-- Tabla clientes
CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_completo VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    direccion VARCHAR(255),
    empresa_asociada VARCHAR(100),
    fecha_registro DATE NOT NULL DEFAULT CURRENT_DATE,
    categoria_id INT,
    puntos INT DEFAULT 0,
    fecha_inactividad DATE,
    FOREIGN KEY (categoria_id) REFERENCES categorias_clientes(id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Tabla transacciones_puntos
CREATE TABLE transacciones_puntos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    puntos_ganados INT DEFAULT 0,
    puntos_reclamados INT DEFAULT 0,
    fecha_transaccion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    descripcion TEXT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla categorias (antes grupos_productos)
CREATE TABLE categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_categoria VARCHAR(50) UNIQUE NOT NULL,
    clave_sat VARCHAR(50),
    descripcion VARCHAR(200)
);

-- Tabla productos
CREATE TABLE productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo_producto VARCHAR(50) UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    id_categoria INT NOT NULL,
    descripcion TEXT,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla especificaciones
CREATE TABLE especificaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    atributo VARCHAR(100) NOT NULL,
    valor VARCHAR(100) NOT NULL,
    FOREIGN KEY (id_producto) REFERENCES productos(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla pesos_dimensiones
CREATE TABLE pesos_dimensiones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    largo DECIMAL(10,2),
    kg_por_metro DECIMAL(10,2),
    peso_pieza DECIMAL(10,2),
    FOREIGN KEY (id_producto) REFERENCES productos(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Catálogo de normas
CREATE TABLE catalogo_normas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    norma VARCHAR(100) UNIQUE NOT NULL
);

-- Relación producto-normas
CREATE TABLE producto_normas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    id_norma INT NOT NULL,
    FOREIGN KEY (id_producto) REFERENCES productos(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_norma) REFERENCES catalogo_normas(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla acabados
CREATE TABLE acabados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    acabado VARCHAR(100),
    FOREIGN KEY (id_producto) REFERENCES productos(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla inventarios
CREATE TABLE inventarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    producto_id INT NOT NULL,
    sucursal_id INT NOT NULL,
    cantidad INT DEFAULT 0,
    stock_minimo INT DEFAULT 10,
    stock_maximo INT DEFAULT 1000,
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (sucursal_id) REFERENCES sucursales(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla ventas (asegúrate de definirla antes de pedidos)
CREATE TABLE ventas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla pedidos
CREATE TABLE pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    venta_id INT NOT NULL,
    repartidor_id VARCHAR(19),
    estado VARCHAR(50) DEFAULT 'Pendiente',
    fecha_asignacion TIMESTAMP,
    fecha_entrega TIMESTAMP,
    FOREIGN KEY (venta_id) REFERENCES ventas(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (repartidor_id) REFERENCES usuarios(CURP) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Tabla notificaciones_pedidos
CREATE TABLE notificaciones_pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    repartidor_id VARCHAR(19),
    detalles TEXT NOT NULL,
    fecha_notificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (repartidor_id) REFERENCES usuarios(CURP) ON DELETE SET NULL ON UPDATE CASCADE
);
