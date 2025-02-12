DROP DATABASE IF EXISTS aceros_duran;
CREATE DATABASE aceros_duran;
USE aceros_duran;

----------------------------------------------------------------
-- 1. TABLAS DE CONFIGURACIÓN Y SEGURIDAD
----------------------------------------------------------------

-- Tabla sucursales
CREATE TABLE sucursales (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(255),
    telefono VARCHAR(20),
    email VARCHAR(100)
);

-- Tabla roles
CREATE TABLE roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT
);

-- Tabla permisos (para asignar acciones específicas)
CREATE TABLE permisos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT
);

-- Tabla intermedia para la relación muchos a muchos entre roles y permisos
CREATE TABLE rol_permisos (
    rol_id BIGINT NOT NULL,
    permiso_id BIGINT NOT NULL,
    PRIMARY KEY (rol_id, permiso_id),
    FOREIGN KEY (rol_id) REFERENCES roles(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (permiso_id) REFERENCES permisos(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla usuarios (utiliza UUID)
CREATE TABLE usuarios (
    id CHAR(36) PRIMARY KEY,  -- Identificador UUID (ej. '550e8400-e29b-41d4-a716-446655440000')
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,        -- Almacenada encriptada
    nombre_completo VARCHAR(100) NOT NULL,
    numero_telefono VARCHAR(20),
    rol_id BIGINT NOT NULL,
    sucursal_id BIGINT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (rol_id) REFERENCES roles(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (sucursal_id) REFERENCES sucursales(id) ON DELETE CASCADE ON UPDATE CASCADE
);

----------------------------------------------------------------
-- 2. TABLAS DE CLIENTES Y PROGRAMA DE PUNTOS
----------------------------------------------------------------

-- Tabla categorías de clientes
CREATE TABLE categorias_clientes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT,
    frecuencia_minima BIGINT,         -- Compras mínimas en un período
    monto_minimo DECIMAL(12,2),         -- Monto mínimo de gasto en un período
    descuento DECIMAL(5,2),             -- Porcentaje de descuento aplicable
    periodo_inactividad BIGINT         -- En meses, para aplicar cambios en beneficios
);

-- Tabla clientes (utiliza UUID)
CREATE TABLE clientes (
    id CHAR(36) PRIMARY KEY,  -- UUID
    nombre_completo VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    direccion VARCHAR(255),
    empresa_asociada VARCHAR(100),
    fecha_registro DATE NOT NULL DEFAULT CURRENT_DATE,
    categoria_id BIGINT,
    puntos BIGINT DEFAULT 0,
    fecha_inactividad DATE,
    FOREIGN KEY (categoria_id) REFERENCES categorias_clientes(id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Tabla transacciones de puntos
CREATE TABLE transacciones_puntos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cliente_id CHAR(36) NOT NULL,
    puntos_ganados BIGINT DEFAULT 0,
    puntos_reclamados BIGINT DEFAULT 0,
    fecha_transaccion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    descripcion TEXT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE ON UPDATE CASCADE
);

----------------------------------------------------------------
-- 3. TABLAS DE PRODUCTOS, INVENTARIO Y CARACTERÍSTICAS
----------------------------------------------------------------

-- Tabla categorías de productos
CREATE TABLE categorias (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre_categoria VARCHAR(50) UNIQUE NOT NULL,
    clave_sat VARCHAR(50),
    descripcion VARCHAR(200)
);

-- Tabla productos
CREATE TABLE productos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    codigo_producto VARCHAR(50) UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    id_categoria BIGINT NOT NULL,
    descripcion TEXT,
    precio_compra DECIMAL(12,2) NOT NULL,
    precio_venta DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla de imágenes de producto (relación 1:N)
CREATE TABLE producto_imagenes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_producto BIGINT NOT NULL,
    ruta_imagen VARCHAR(255) NOT NULL,
    es_principal BOOLEAN DEFAULT FALSE,
    orden BIGINT DEFAULT 0,  -- Para definir el orden de visualización
    FOREIGN KEY (id_producto) REFERENCES productos(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla especificaciones
CREATE TABLE especificaciones (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_producto BIGINT NOT NULL,
    atributo VARCHAR(100) NOT NULL,
    valor VARCHAR(100) NOT NULL,
    FOREIGN KEY (id_producto) REFERENCES productos(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla pesos_dimensiones
CREATE TABLE pesos_dimensiones (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_producto BIGINT NOT NULL,
    largo DECIMAL(10,2),
    kg_por_metro DECIMAL(10,2),
    peso_pieza DECIMAL(10,2),
    FOREIGN KEY (id_producto) REFERENCES productos(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Catálogo de normas
CREATE TABLE catalogo_normas (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    norma VARCHAR(100) UNIQUE NOT NULL
);

-- Relación producto-normas
CREATE TABLE producto_normas (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_producto BIGINT NOT NULL,
    id_norma BIGINT NOT NULL,
    FOREIGN KEY (id_producto) REFERENCES productos(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_norma) REFERENCES catalogo_normas(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla acabados
CREATE TABLE acabados (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_producto BIGINT NOT NULL,
    acabado VARCHAR(100),
    FOREIGN KEY (id_producto) REFERENCES productos(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla inventarios
CREATE TABLE inventarios (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT NOT NULL,
    sucursal_id BIGINT NOT NULL,
    cantidad BIGINT DEFAULT 0,
    stock_minimo BIGINT DEFAULT 10,
    stock_maximo BIGINT DEFAULT 1000,
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (sucursal_id) REFERENCES sucursales(id) ON DELETE CASCADE ON UPDATE CASCADE
);

----------------------------------------------------------------
-- 4. TABLAS DE VENTAS, DETALLE DE VENTAS, FACTURAS Y PEDIDOS
----------------------------------------------------------------

-- Tabla ventas (utiliza UUID)
CREATE TABLE ventas (
    id CHAR(36) PRIMARY KEY,  -- UUID
    cliente_id CHAR(36) NOT NULL,
    fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(12,2) NOT NULL,
    tipo_pago_id BIGINT,  -- Referencia directa a la tabla tipos_pago
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (tipo_pago_id) REFERENCES tipos_pago(id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Tabla detalle de ventas, con restricción UNIQUE (venta_id, producto_id)
CREATE TABLE detalle_ventas (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    venta_id CHAR(36) NOT NULL,
    producto_id BIGINT NOT NULL,
    cantidad BIGINT NOT NULL,
    precio_unitario DECIMAL(12,2) NOT NULL,
    descuento_aplicado DECIMAL(5,2) DEFAULT 0,
    UNIQUE (venta_id, producto_id),
    FOREIGN KEY (venta_id) REFERENCES ventas(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla facturas
CREATE TABLE facturas (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    venta_id CHAR(36) NOT NULL,
    fecha_emision TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(12,2) NOT NULL,
    ruta_archivo VARCHAR(255),
    FOREIGN KEY (venta_id) REFERENCES ventas(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla catálogo de estado de pedido
CREATE TABLE catalogo_estado_pedido (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL
);

INSERT INTO catalogo_estado_pedido (nombre) VALUES ('Pendiente'), ('En Camino'), ('Entregado');

-- Tabla pedidos (utiliza UUID)
CREATE TABLE pedidos (
    id CHAR(36) PRIMARY KEY,  -- UUID
    venta_id CHAR(36) NOT NULL,
    repartidor_id CHAR(36),  -- Referencia a usuarios (UUID)
    estado_id BIGINT NOT NULL,  -- Referencia al catálogo de estados de pedido
    fecha_asignacion TIMESTAMP,
    fecha_entrega TIMESTAMP,
    FOREIGN KEY (venta_id) REFERENCES ventas(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (repartidor_id) REFERENCES usuarios(id) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (estado_id) REFERENCES catalogo_estado_pedido(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Tabla notificaciones de pedidos
CREATE TABLE notificaciones_pedidos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    pedido_id CHAR(36) NOT NULL,
    repartidor_id CHAR(36),
    detalles TEXT NOT NULL,
    fecha_notificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (repartidor_id) REFERENCES usuarios(id) ON DELETE SET NULL ON UPDATE CASCADE
);

----------------------------------------------------------------
-- 5. TABLAS DE FORMAS DE PAGO Y CATÁLOGOS
----------------------------------------------------------------

-- Tabla tipos de pago
CREATE TABLE tipos_pago (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL
);

-- Tabla catálogo para el tipo de compra
CREATE TABLE catalogo_tipo_compra (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL
);

-- Tabla catálogo para el estado en cuentas por pagar
CREATE TABLE catalogo_estado_cxp (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL
);

-- Tabla catálogo para el estado en cuentas por cobrar
CREATE TABLE catalogo_estado_cxc (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL
);

----------------------------------------------------------------
-- 6. TABLAS DE COMPRAS, PROVEEDORES Y DETALLE DE COMPRAS
----------------------------------------------------------------

-- Tabla proveedores
CREATE TABLE proveedores (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(255),
    telefono VARCHAR(20),
    email VARCHAR(100),
    contacto VARCHAR(100)
);

-- Tabla compras (utiliza UUID)
CREATE TABLE compras (
    id CHAR(36) PRIMARY KEY,  -- UUID
    proveedor_id BIGINT NOT NULL,
    usuario_id CHAR(36) NOT NULL,  -- Usuario (empleado) que registra la compra
    fecha_compra TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(12,2) NOT NULL,
    tipo_compra_id BIGINT NOT NULL,   -- Referencia a catalogo_tipo_compra
    incluye_IVA BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (proveedor_id) REFERENCES proveedores(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (tipo_compra_id) REFERENCES catalogo_tipo_compra(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Tabla detalle de compras
CREATE TABLE detalle_compras (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    compra_id CHAR(36) NOT NULL,
    producto_id BIGINT NOT NULL,
    cantidad BIGINT NOT NULL,
    precio_unitario DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (compra_id) REFERENCES compras(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE ON UPDATE CASCADE
);

----------------------------------------------------------------
-- 7. TABLAS DE GASTOS Y CONTABILIDAD
----------------------------------------------------------------

-- Tabla gastos
CREATE TABLE gastos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sucursal_id BIGINT NOT NULL,
    descripcion VARCHAR(255),
    monto DECIMAL(12,2) NOT NULL,
    fecha_gasto DATE NOT NULL,
    categoria VARCHAR(50),
    FOREIGN KEY (sucursal_id) REFERENCES sucursales(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla cuentas por pagar
CREATE TABLE cuentas_por_pagar (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    proveedor_id BIGINT NOT NULL,
    compra_id CHAR(36),
    monto DECIMAL(12,2) NOT NULL,
    fecha_vencimiento DATE,
    estado_id BIGINT NOT NULL,  -- Referencia a catalogo_estado_cxp
    FOREIGN KEY (proveedor_id) REFERENCES proveedores(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (compra_id) REFERENCES compras(id) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (estado_id) REFERENCES catalogo_estado_cxp(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Tabla cuentas por cobrar
CREATE TABLE cuentas_por_cobrar (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cliente_id CHAR(36) NOT NULL,
    venta_id CHAR(36),
    monto DECIMAL(12,2) NOT NULL,
    fecha_vencimiento DATE,
    estado_id BIGINT NOT NULL,  -- Referencia a catalogo_estado_cxc
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (venta_id) REFERENCES ventas(id) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (estado_id) REFERENCES catalogo_estado_cxc(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

----------------------------------------------------------------
-- 8. TABLAS DE COTIZACIONES, FONDO DE AHORRO Y SALARIOS
----------------------------------------------------------------

-- Tabla presupuestos (utiliza UUID para id)
CREATE TABLE presupuestos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cliente_id CHAR(36),
    usuario_id CHAR(36),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(12,2) NOT NULL,
    mostrar_detalle BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Tabla fondo de ahorro
CREATE TABLE fondo_ahorro (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    usuario_id CHAR(36) NOT NULL,
    monto_acumulado DECIMAL(12,2) DEFAULT 0,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla salarios
CREATE TABLE salarios (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    usuario_id CHAR(36) NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    fecha_pago DATE NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE
);

----------------------------------------------------------------
-- FIN DEL SCRIPT
----------------------------------------------------------------
