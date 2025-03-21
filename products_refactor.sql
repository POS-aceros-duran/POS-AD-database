 ----------------------------------------------------------------
        -- 3. TABLAS DE PRODUCTOS, INVENTARIO Y CARACTERÍSTICAS
        ----------------------------------------------------------------

        -- tabla de claves SAT
        CREATE TABLE claves_sat (
            id BIGINT AUTO_INCREMENT PRIMARY KEY,
            clave VARCHAR(50) UNIQUE NOT NULL,
            descripcion VARCHAR(255)
        );


        -- Tabla categorías de productos
        CREATE TABLE categorias (
            id BIGINT AUTO_INCREMENT PRIMARY KEY,
            nombre_categoria VARCHAR(50) UNIQUE NOT NULL,
            clave_sat BIGINT,
            descripcion VARCHAR(200),
            FOREIGN KEY (clave_sat) REFERENCES claves_sat(id) ON DELETE SET NULL ON UPDATE CASCADE
        );

        -- Catálogo de normas
        CREATE TABLE catalogo_normas (
            id BIGINT AUTO_INCREMENT PRIMARY KEY,
            norma VARCHAR(100) UNIQUE NOT NULL
        );

        -- Tabla productos
        CREATE TABLE productos (
            id BIGINT AUTO_INCREMENT PRIMARY KEY,
            nombre VARCHAR(100) NOT NULL,   
            id_categoria BIGINT NOT NULL,
            descripcion TEXT,
            MedidaA DECIMAL(10,2),         -- En pulgadas (ej: 0.5 para 1/2")
            MedidaB DECIMAL(10,2),         -- En pulgadas (para no cuadrados/redondos)
            DiametroNominal VARCHAR(20),   -- Solo para tubos mecánicos (ej: "1/2\"")
            Longitud DECIMAL(10,2) DEFAULT 6.10,  -- En metros
            peso_pieza DECIMAL(10,2) DEFAULT 0,  -- Peso en kg
            clave_sat BIGINT,  -- Referencia a claves_sat
            norma_id BIGINT,  -- Referencia a catalogo_normas
            FOREIGN KEY (norma_id) REFERENCES catalogo_normas(id) ON DELETE SET NULL ON UPDATE CASCADE,
            FOREIGN KEY (id_categoria) REFERENCES categorias(id) ON DELETE CASCADE ON UPDATE CASCADE,
            FOREIGN KEY (clave_sat) REFERENCES claves_sat(id) ON DELETE SET NULL ON UPDATE CASCADE
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

        -- Tabla catalogo de acabados
        CREATE TABLE catalogo_acabados (
            id BIGINT AUTO_INCREMENT PRIMARY KEY,
            nombre VARCHAR(50) UNIQUE NOT NULL,
            descripcion TEXT DEFAULT NULL
        );            

        -- Tabla para variantes (calibres/espesores)
        CREATE TABLE productos_variantes (
            id BIGINT PRIMARY KEY AUTO_INCREMENT,
            producto_id BIGINT NOT NULL,
            calibre VARCHAR(10),          -- Ej: "20", "C12"
            espesor DECIMAL(10,3),        -- En pulgadas (ej: 0.036)
            diametroExterior DECIMAL(10,2), -- Solo para tubos mecánicos
            diametroInterior DECIMAL(10,2), -- Solo para tubos mecánicos
            piezasPorPaquete INT,         -- Ej: 231
            codigoSKU VARCHAR(50) UNIQUE, -- Identificador único
            FOREIGN KEY (Producto_id) REFERENCES productos(id) ON DELETE CASCADE ON UPDATE CASCADE
        );

        -- Tabla acabados-productos
        CREATE TABLE producto_variante_acabados (
            id BIGINT AUTO_INCREMENT PRIMARY KEY,
            producto_variante_id BIGINT NOT NULL,
            acabado_id BIGINT NOT NULL, 
            FOREIGN KEY (acabado_id) REFERENCES catalogo_acabados(id) ON DELETE CASCADE ON UPDATE CASCADE,
            FOREIGN KEY (producto_variante_id) REFERENCES productos_variantes(id) ON DELETE CASCADE ON UPDATE CASCADE
        );

        -- Tabla inventarios
        CREATE TABLE inventarios (
            id BIGINT AUTO_INCREMENT PRIMARY KEY,
            producto_variante_id BIGINT NOT NULL,
            sucursal_id BIGINT NOT NULL,
            cantidad BIGINT DEFAULT 0,
            stock_minimo BIGINT DEFAULT 10,
            stock_maximo BIGINT DEFAULT 1000,
            FOREIGN KEY (sucursal_id) REFERENCES sucursales(id) ON DELETE CASCADE ON UPDATE CASCADE,
            FOREIGN KEY (producto_variante_id) REFERENCES productos_variantes(id) ON DELETE CASCADE ON UPDATE CASCADE
        );
