-- 0. Tabla sucursales
CREATE TABLE sucursales (
    id SERIAL PRIMARY KEY,
     nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(255),
    telefono VARCHAR(20),
    email VARCHAR(100)
);

-- 1. Tabla roles
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT
);

-- 4. Tabla usuarios
CREATE TABLE usuarios (
    CURP VARCHAR(19 ) PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    nombre_completo VARCHAR(100) NOT NULL,
    numero_telefono VARCHAR(20),
    rol_id INT NOT NULL,
    sucursal_id INT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (rol_id) REFERENCES roles(id),
    FOREIGN KEY(sucursal_id) REFERENCES sucursal(id)
);  

-- 5. Tabla categorias_clientes
CREATE TABLE categorias_clientes (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT,
    frecuencia_minima INT,
    monto_minimo DECIMAL(12,2),
    descuento DECIMAL(5,2),
    periodo_inactividad INT
);

-- 6. Tabla clientes
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nombre_completo VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    direccion VARCHAR(255),
    empresa_asociada VARCHAR(100),
    fecha_registro DATE NOT NULL DEFAULT CURRENT_DATE,
    categoria_id INT,
    puntos INT DEFAULT 0,
    fecha_inactividad DATE,
    FOREIGN KEY (categoria_id) REFERENCES categorias_clientes(id)
);

-- 7. Tabla transacciones_puntos
CREATE TABLE transacciones_puntos (
    id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL,
    puntos_ganados INT DEFAULT 0,
    puntos_reclamados INT DEFAULT 0,
    fecha_transaccion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    descripcion TEXT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- 8. Tabla categorias_productos
CREATE TABLE grupos_productos (
    id SERIAL PRIMARY KEY,
    grupos VARCHAR(50) UNIQUE NOT NULL,
    clave_sat VARCHAR(50),
    descripcion VARCHAR(200)
);

-- 9. Tabla productos
CREATE TABLE productos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo_acero VARCHAR(50),
    dimensiones VARCHAR(50),
    peso DECIMAL(10,2), 
    precio_unitario DECIMAL(12,2),
    precio_por_kg DECIMAL(12,2),
    largo DECIMAL(12,2),
    categoria_producto_id INT,
    descripcion VARCHAR(200),
    FOREIGN KEY (categoria_producto_id) REFERENCES grupos_productos(id)
);

-- 11. Tabla inventarios
CREATE TABLE inventarios (
    id SERIAL PRIMARY KEY,
    producto_id INT NOT NULL,
    sucursal_id INT NOT NULL,
    cantidad INT DEFAULT 0,
    stock_minimo INT DEFAULT 10,
    stock_maximo INT DEFAULT 1000,
    FOREIGN KEY (producto_id) REFERENCES productos(id),
    FOREIGN KEY (sucursal_id) REFERENCES sucursales(id)
);

-- 12. Tabla ventas
CREATE TABLE ventas (
    id SERIAL PRIMARY KEY,
    cliente_id INT,
    sucursal_id INT NOT NULL,
    usuario_id INT NOT NULL,
    fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(12,2),
    descuento_aplicado DECIMAL(12,2),
    tipo_pago VARCHAR(50) DEFAULT 'Efectivo',
    estado VARCHAR(50) DEFAULT 'Completada',
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (sucursal_id) REFERENCES sucursales(id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- 13. Tabla detalle_ventas
CREATE TABLE detalle_ventas (
    id SERIAL PRIMARY KEY,
    venta_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(12,2),
    precio_total DECIMAL(12,2),
    FOREIGN KEY (venta_id) REFERENCES ventas(id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);

-- 14. Tabla devoluciones
CREATE TABLE devoluciones (
    id SERIAL PRIMARY KEY,
    venta_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    fecha_devolucion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    motivo TEXT,
    FOREIGN KEY (venta_id) REFERENCES ventas(id),
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);


-- departamentos
CREATE TABLE departamentos(
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL
)

-- 15. Tabla proveedores
CREATE TABLE proveedores (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(255),
    telefono VARCHAR(20),
    email VARCHAR(100),
    departamento_id INT NOT NULL,
    informacion_general TEXT,
    limite_credito INTEGER, -- cantidad de credito que el proveedor puede otorgar en la compa de productos
    credito_disponible INTEGER, -- calculo de la cantidad de credito aun disponible con este proveedor                                                                  
    FOREIGN KEY (departamento_id) REFERENCES departamentos(id),
);

-- 16. Tabla compras
CREATE TABLE compras (
    id SERIAL PRIMARY KEY,
    proveedor_id INT NOT NULL,
    sucursal_id INT NOT NULL,
    usuario_id INT NOT NULL,
    fecha_compra TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(12,2),
    tipo_compra VARCHAR(50),
    incluye_iva BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (proveedor_id) REFERENCES proveedores(id),
    FOREIGN KEY (sucursal_id) REFERENCES sucursales(id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- 17. Tabla detalle_compras
CREATE TABLE detalle_compras (
    id SERIAL PRIMARY KEY,
    compra_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(12,2),
    precio_total DECIMAL(12,2),
    FOREIGN KEY (compra_id) REFERENCES compras(id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);

-- 18. Tabla cuentas_por_pagar
CREATE TABLE cuentas_por_pagar (
    id SERIAL PRIMARY KEY,
    compra_id INT NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    estado VARCHAR(50) DEFAULT 'Pendiente',
    FOREIGN KEY (compra_id) REFERENCES compras(id)
);

-- 19. Tabla cuentas_por_cobrar
CREATE TABLE cuentas_por_cobrar (
    id SERIAL PRIMARY KEY,
    venta_id INT NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    estado VARCHAR(50) DEFAULT 'Pendiente',
    FOREIGN KEY (venta_id) REFERENCES ventas(id)
);

-- 20. Tabla facturas_empresa
CREATE TABLE facturas_empresa (
    id SERIAL PRIMARY KEY,
    razon_social VARCHAR(100) NOT NULL,
    rfc VARCHAR(20) UNIQUE NOT NULL,
    direccion VARCHAR(255),
    email VARCHAR(100),
    telefono VARCHAR(20)
);

-- 21. Tabla facturas
CREATE TABLE facturas (
    id SERIAL PRIMARY KEY,
    venta_id INT NOT NULL,
    numero_factura VARCHAR(50) UNIQUE NOT NULL,
    fecha_emision TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_vencimiento TIMESTAMP,
    total DECIMAL(12,2),
    FOREIGN KEY (venta_id) REFERENCES ventas(id)
);

-- 22. Tabla envios_facturas: Almacena los datos para enviar un correo electrónico de la factura
CREATE TABLE envios_facturas (
    id SERIAL PRIMARY KEY,
    factura_id INT NOT NULL,
    email_destinatario VARCHAR(100) NOT NULL,
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado_envio VARCHAR(50) DEFAULT 'Enviado',
    mensaje TEXT,
    FOREIGN KEY (factura_id) REFERENCES facturas(id)
);

-- 25. Tabla fondo_ahorro
CREATE TABLE fondo_ahorro (
    id SERIAL PRIMARY KEY,
    colaborador_id INT NOT NULL,
    monto_aportado DECIMAL(12,2) NOT NULL,
    monto_adicional DECIMAL(12,2) GENERATED ALWAYS AS (monto_aportado * 0.10) STORED,
    fecha_aportacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (colaborador_id) REFERENCES usuarios(id)
);

-- 26. Tabla salarios
CREATE TABLE salarios (
    id SERIAL PRIMARY KEY,
    colaborador_id INT NOT NULL,
    salario_base DECIMAL(12,2) NOT NULL,
    bonificaciones DECIMAL(12,2) DEFAULT 0,
    deducciones DECIMAL(12,2) DEFAULT 0,
    salario_total DECIMAL(12,2) GENERATED ALWAYS AS (salario_base + bonificaciones - deducciones) STORED,
    fecha_pago DATE NOT NULL,
    FOREIGN KEY (colaborador_id) REFERENCES usuarios(id)
);

-- registo de pagos realizados a cuentas por pagar
CREATE TABLE tipo_pagos (
    id SERIAL PRIMARY KEY,
    tipo VARCHAR(50) UNIQUE NOT NULL,

);


-- 27 Tabla de categoria gastos
create table categoria_gastos(
   id SERIAL PRIMARY KEY,
   categoria_nombre varchar(200) -- gastos fijos, gastos varios, 
);

--  27.1 Tabla gastos
CREATE TABLE gastos (
    id SERIAL PRIMARY KEY,
    sucursal_id INT NOT NULL,
    descripcion TEXT NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    categoria_gasto VARCHAR(50),
    fecha_gasto DATE NOT NULL,
    FOREIGN KEY (sucursal_id) REFERENCES sucursales(id)
);

-- 28. Tabla utilidades: calculo de utilidades por mes
CREATE TABLE utilidades (
    id SERIAL PRIMARY KEY,
    producto_id INT NOT NULL,
    sucursal_id INT NOT NULL,
    periodo VARCHAR(20) NOT NULL, -- Formato: YYYY-MM
    ingresos DECIMAL(12,2) DEFAULT 0,
    costos DECIMAL(12,2) DEFAULT 0,
    utilidad DECIMAL(12,2) GENERATED ALWAYS AS (ingresos - costos) STORED,
    FOREIGN KEY (producto_id) REFERENCES productos(id),
    FOREIGN KEY (sucursal_id) REFERENCES sucursales(id)
);

-- 29. Tabla descuentos
CREATE TABLE descuentos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    porcentaje DECIMAL(5,2) NOT NULL,
    tipo VARCHAR(50), -- Ej: Volumen, Frecuencia, Recurrente
    criterio_cantidad INT,
    criterio_monto DECIMAL(12,2),
    categoria_cliente_id INT,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (categoria_cliente_id) REFERENCES categorias_clientes(id)
);

-- 30. Tabla descuentos_reglas
CREATE TABLE descuentos_reglas (
    id SERIAL PRIMARY KEY,
    descuento_id INT NOT NULL,
    criterio VARCHAR(50) NOT NULL, -- Ej: Cantidad, Frecuencia
    valor INT, -- Valor para cantidad o frecuencia
    FOREIGN KEY (descuento_id) REFERENCES descuentos(id)
);

-- 31. Tabla promociones
CREATE TABLE promociones (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    descuento_porcentaje DECIMAL(5,2),
    activo BOOLEAN DEFAULT TRUE
);

-- 32. Tabla cliente_promociones
CREATE TABLE cliente_promociones (
    id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL,
    promocion_id INT NOT NULL,
    fecha_activacion DATE NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (promocion_id) REFERENCES promociones(id)
);

-- 33. Tabla notificaciones_pedidos
CREATE TABLE notificaciones_pedidos (
    id SERIAL PRIMARY KEY,
    pedido_id INT NOT NULL,
    repartidor_id INT NOT NULL,
    detalles JSONB NOT NULL,
    fecha_notificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
    FOREIGN KEY (repartidor_id) REFERENCES usuarios(id)
);

-- 34. Tabla pedidos
CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    venta_id INT NOT NULL,
    repartidor_id INT,
    estado VARCHAR(50) DEFAULT 'Pendiente',
    fecha_asignacion TIMESTAMP,
    fecha_entrega TIMESTAMP,
    FOREIGN KEY (venta_id) REFERENCES ventas(id),
    FOREIGN KEY (repartidor_id) REFERENCES usuarios(id)
);