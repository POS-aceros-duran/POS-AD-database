DROP DATABASE IF EXISTS ad_test;

CREATE DATABASE ad_test;

USE ad_test;

----------------------------------------------------------------
-- 1. CONFIGURATION AND SECURITY TABLES
----------------------------------------------------------------
-- Branches Table
CREATE TABLE
    branches (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        address VARCHAR(255),
        phone VARCHAR(20),
        email VARCHAR(100)
    );

-- Roles Table
CREATE TABLE
    roles (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(50) UNIQUE NOT NULL,
        description TEXT
    );

-- Permissions Table (for assigning specific actions)
CREATE TABLE
    permissions (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(50) UNIQUE NOT NULL,
        description TEXT
    );

-- Intermediate table for the many-to-many relationship between roles and permissions
CREATE TABLE
    role_permissions (
        role_id BIGINT NOT NULL,
        permission_id BIGINT NOT NULL,
        PRIMARY KEY (role_id, permission_id),
        FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (permission_id) REFERENCES permissions (id) ON DELETE CASCADE ON UPDATE CASCADE
    );

-- Users Table (using UUID)
CREATE TABLE
    users (
        id CHAR(36) PRIMARY KEY, -- UUID Identifier (e.g., '550e8400-e29b-41d4-a716-446655440000')
        username VARCHAR(50) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL, -- Stored encrypted
        full_name VARCHAR(100) NOT NULL,
        phone_number VARCHAR(20),
        role_id BIGINT NOT NULL,
        branch_id BIGINT NOT NULL,
        creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (branch_id) REFERENCES branches (id) ON DELETE CASCADE ON UPDATE CASCADE
    );

----------------------------------------------------------------
-- 5. PAYMENT METHODS AND CATALOG TABLES
----------------------------------------------------------------
-- Payment Types Table
CREATE TABLE
    payment_types (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(50) UNIQUE NOT NULL
    );

-- Purchase Type Catalog Table
CREATE TABLE
    purchase_type_catalog (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(50) UNIQUE NOT NULL
    );

-- Accounts Payable Status Catalog Table
CREATE TABLE
    accounts_payable_status_catalog (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(50) UNIQUE NOT NULL
    );

-- Accounts Receivable Status Catalog Table
CREATE TABLE
    accounts_receivable_status_catalog (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(50) UNIQUE NOT NULL
    );

----------------------------------------------------------------
-- 2. CUSTOMER TABLES AND LOYALTY POINTS PROGRAM
----------------------------------------------------------------
-- Customer Categories Table
CREATE TABLE
    customer_categories (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(50) UNIQUE NOT NULL,
        description TEXT,
        minimum_frequency BIGINT, -- Minimum purchases in a period
        minimum_amount DECIMAL(12, 2), -- Minimum spending in a period
        discount DECIMAL(5, 2), -- Applicable discount percentage
        inactivity_period BIGINT -- In months, to apply benefit changes
    );

-- Customers Table (using UUID)
CREATE TABLE
    customers (
        id CHAR(36) PRIMARY KEY, -- UUID
        full_name VARCHAR(100) NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        phone VARCHAR(20),
        address VARCHAR(255),
        associated_company VARCHAR(100),
        category_id BIGINT,
        points BIGINT DEFAULT 0,
        inactivity_date DATE,
        FOREIGN KEY (category_id) REFERENCES customer_categories (id) ON DELETE SET NULL ON UPDATE CASCADE
    );

-- Points Transactions Table
CREATE TABLE
    points_transactions (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        customer_id CHAR(36) NOT NULL,
        points_earned BIGINT DEFAULT 0,
        points_redeemed BIGINT DEFAULT 0,
        transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        description TEXT,
        FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE ON UPDATE CASCADE
    );

----------------------------------------------------------------
-- 3. PRODUCTS, INVENTORY, AND FEATURES TABLES
----------------------------------------------------------------
-- SAT Keys Table
CREATE TABLE
    sat_keys (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        key VARCHAR(50) UNIQUE NOT NULL,
        description VARCHAR(255)
    );

-- Product Categories Table
CREATE TABLE
    product_categories (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        category_name VARCHAR(50) UNIQUE NOT NULL,
        sat_key BIGINT,
        description VARCHAR(200),
        FOREIGN KEY (sat_key) REFERENCES sat_keys (id) ON DELETE SET NULL ON UPDATE CASCADE
    );

-- Standards Catalog Table
CREATE TABLE
    standards_catalog (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        standard VARCHAR(100) UNIQUE NOT NULL
    );

-- Products Table
CREATE TABLE
    products (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        category_id BIGINT NOT NULL,
        description TEXT,
        sat_key BIGINT, -- Reference to sat_keys
        standard_id BIGINT, -- Reference to standards_catalog
        FOREIGN KEY (standard_id) REFERENCES standards_catalog (id) ON DELETE SET NULL ON UPDATE CASCADE,
        FOREIGN KEY (category_id) REFERENCES product_categories (id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (sat_key) REFERENCES sat_keys (id) ON DELETE SET NULL ON UPDATE CASCADE
    );

-- Product Images Table (1:N relationship)
CREATE TABLE
    product_images (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        product_id BIGINT NOT NULL,
        image_path VARCHAR(255) NOT NULL,
        is_primary BOOLEAN DEFAULT FALSE,
        display_order BIGINT DEFAULT 0, -- For defining display order
        FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE ON UPDATE CASCADE
    );

-- Finishes Catalog Table
CREATE TABLE
    finishes_catalog (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(50) UNIQUE NOT NULL,
        description TEXT DEFAULT NULL
    );

-- Product Variants Table (gauges/thicknesses)
CREATE TABLE
    product_variants (
        id BIGINT PRIMARY KEY AUTO_INCREMENT,
        product_id BIGINT NOT NULL,
        measure_A DECIMAL(10, 2), -- In inches (e.g., 0.5 for 1/2")
        measure_B DECIMAL(10, 2), -- In inches
        nominal_diameter VARCHAR(20), -- Only for mechanical tubes (e.g., "1/2\"")
        piece_weight DECIMAL(10, 2) DEFAULT 0, -- Weight in kg
        length DECIMAL(10, 2) DEFAULT 6.10, -- In meters
        gauge VARCHAR(10), -- E.g., "20", "C12"
        thickness DECIMAL(10, 3), -- In inches (e.g., 0.036)
        exterior_diameter DECIMAL(10, 2), -- Only for mechanical tubes
        interior_diameter DECIMAL(10, 2), -- Only for mechanical tubes
        pieces_per_package INT, -- E.g., 231
        sku_code VARCHAR(50) UNIQUE, -- Unique identifier
        FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE ON UPDATE CASCADE
    );

-- Product Variant Finishes Table
CREATE TABLE
    product_variant_finishes (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        product_variant_id BIGINT NOT NULL,
        finish_id BIGINT NOT NULL,
        FOREIGN KEY (finish_id) REFERENCES finishes_catalog (id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (product_variant_id) REFERENCES product_variants (id) ON DELETE CASCADE ON UPDATE CASCADE
    );

-- Inventories Table
CREATE TABLE
    inventories (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        product_variant_id BIGINT NOT NULL,
        branch_id BIGINT NOT NULL,
        quantity BIGINT DEFAULT 0,
        minimum_stock BIGINT DEFAULT 10,
        maximum_stock BIGINT DEFAULT 1000,
        FOREIGN KEY (branch_id) REFERENCES branches (id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (product_variant_id) REFERENCES product_variants (id) ON DELETE CASCADE ON UPDATE CASCADE
    );

----------------------------------------------------------------
-- 4. SALES, SALES DETAILS, INVOICES, AND ORDERS TABLES
----------------------------------------------------------------
-- Sales Table (using UUID)
CREATE TABLE
    sales (
        id CHAR(36) PRIMARY KEY, -- UUID
        customer_id CHAR(36) NOT NULL,
        sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        total DECIMAL(12, 2) NOT NULL,
        payment_type_id BIGINT, -- Direct reference to payment_types table
        FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (payment_type_id) REFERENCES payment_types (id) ON DELETE SET NULL ON UPDATE CASCADE
    );

-- Sales Details Table, with UNIQUE constraint (sale_id, product_variant_id)
CREATE TABLE
    sales_details (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        sale_id CHAR(36) NOT NULL,
        product_variant_id BIGINT NOT NULL,
        quantity BIGINT NOT NULL,
        unit_price DECIMAL(12, 2) NOT NULL,
        discount_applied DECIMAL(5, 2) DEFAULT 0,
        UNIQUE (sale_id, product_variant_id),
        FOREIGN KEY (sale_id) REFERENCES sales (id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (product_variant_id) REFERENCES product_variants (id) ON DELETE CASCADE ON UPDATE CASCADE
    );

-- Invoices Table
CREATE TABLE
    invoices (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        sale_id CHAR(36) NOT NULL,
        issue_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        total DECIMAL(12, 2) NOT NULL,
        file_path VARCHAR(255),
        FOREIGN KEY (sale_id) REFERENCES sales (id) ON DELETE CASCADE ON UPDATE CASCADE
    );

-- Order Status Catalog Table
CREATE TABLE
    order_status_catalog (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(50) UNIQUE NOT NULL
    );

INSERT INTO
    order_status_catalog (name)
VALUES
    ('Pending'),
    ('On the Way'),
    ('Delivered');

-- Orders Table (using UUID)
CREATE TABLE
    orders (
        id CHAR(36) PRIMARY KEY, -- UUID
        sale_id CHAR(36) NOT NULL,
        delivery_person_id CHAR(36), -- Reference to users (UUID)
        status_id BIGINT NOT NULL, -- Reference to order_status_catalog
        assignment_date TIMESTAMP,
        delivery_date TIMESTAMP,
        FOREIGN KEY (sale_id) REFERENCES sales (id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (delivery_person_id) REFERENCES users (id) ON DELETE SET NULL ON UPDATE CASCADE,
        FOREIGN KEY (status_id) REFERENCES order_status_catalog (id) ON DELETE RESTRICT ON UPDATE CASCADE
    );

-- Order Notifications Table
CREATE TABLE
    order_notifications (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        order_id CHAR(36) NOT NULL,
        delivery_person_id CHAR(36),
        details TEXT NOT NULL,
        notification_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (delivery_person_id) REFERENCES users (id) ON DELETE SET NULL ON UPDATE CASCADE
    );

----------------------------------------------------------------
-- 6. PURCHASES, SUPPLIERS, AND PURCHASE DETAILS TABLES
----------------------------------------------------------------
-- Suppliers Table
CREATE TABLE
    suppliers (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        address VARCHAR(255),
        phone VARCHAR(20),
        email VARCHAR(100),
        contact VARCHAR(100)
    );

-- Purchases Table (using UUID)
CREATE TABLE
    purchases (
        id CHAR(36) PRIMARY KEY, -- UUID
        supplier_id BIGINT NOT NULL,
        user_id CHAR(36) NOT NULL, -- User (employee) recording the purchase
        purchase_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        total DECIMAL(12, 2) NOT NULL,
        purchase_type_id BIGINT NOT NULL, -- Reference to purchase_type_catalog
        includes_VAT BOOLEAN DEFAULT false,
        FOREIGN KEY (supplier_id) REFERENCES suppliers (id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (purchase_type_id) REFERENCES purchase_type_catalog (id) ON DELETE RESTRICT ON UPDATE CASCADE
    );

-- Purchase Details Table
CREATE TABLE
    purchase_details (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        purchase_id CHAR(36) NOT NULL,
        product_variant_id BIGINT NOT NULL,
        quantity BIGINT NOT NULL,
        unit_price DECIMAL(12, 2) NOT NULL,
        FOREIGN KEY (purchase_id) REFERENCES purchases (id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (product_variant_id) REFERENCES product_variants (id) ON DELETE CASCADE ON UPDATE CASCADE
    );

----------------------------------------------------------------
-- 7. EXPENSES AND ACCOUNTING TABLES
----------------------------------------------------------------
-- Expenses Table
CREATE TABLE
    expenses (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        branch_id BIGINT NOT NULL,
        description VARCHAR(255),
        amount DECIMAL(12, 2) NOT NULL,
        expense_date DATE NOT NULL,
        category VARCHAR(50),
        FOREIGN KEY (branch_id) REFERENCES branches (id) ON DELETE CASCADE ON UPDATE CASCADE
    );

-- Accounts Payable Table
CREATE TABLE
    accounts_payable (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        supplier_id BIGINT NOT NULL,
        purchase_id CHAR(36),
        amount DECIMAL(12, 2) NOT NULL,
        due_date DATE,
        status_id BIGINT NOT NULL, -- Reference to accounts_payable_status_catalog
        FOREIGN KEY (supplier_id) REFERENCES suppliers (id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (purchase_id) REFERENCES purchases (id) ON DELETE SET NULL ON UPDATE CASCADE,
        FOREIGN KEY (status_id) REFERENCES accounts_payable_status_catalog (id) ON DELETE RESTRICT ON UPDATE CASCADE
    );

-- Accounts Receivable Table
CREATE TABLE
    accounts_receivable (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        customer_id CHAR(36) NOT NULL,
        sale_id CHAR(36),
        amount DECIMAL(12, 2) NOT NULL,
        due_date DATE,
        status_id BIGINT NOT NULL, -- Reference to accounts_receivable_status_catalog
        FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (sale_id) REFERENCES sales (id) ON DELETE SET NULL ON UPDATE CASCADE,
        FOREIGN KEY (status_id) REFERENCES accounts_receivable_status_catalog (id) ON DELETE RESTRICT ON UPDATE CASCADE
    );

----------------------------------------------------------------
-- 8. QUOTES, SAVINGS FUND, AND SALARIES TABLES
----------------------------------------------------------------
-- Quotes Table (using UUID for id)
CREATE TABLE
    quotes (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        customer_id CHAR(36),
        user_id CHAR(36),
        date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        total DECIMAL(12, 2) NOT NULL,
        show_details BOOLEAN DEFAULT TRUE,
        FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE SET NULL ON UPDATE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE SET NULL ON UPDATE CASCADE
    );

CREATE TABLE
    quote_details (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        quote_id BIGINT NOT NULL,
        product_variant_id BIGINT NOT NULL,
        quantity BIGINT NOT NULL,
        unit_price DECIMAL(12, 2) NOT NULL,
        FOREIGN KEY (quote_id) REFERENCES quotes (id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (product_variant_id) REFERENCES product_variants (id) ON DELETE CASCADE ON UPDATE CASCADE
    );

-- Savings Fund Table
CREATE TABLE
    savings_fund (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        user_id CHAR(36) NOT NULL,
        accumulated_amount DECIMAL(12, 2) DEFAULT 0,
        update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE
    );

-- Salaries Table
CREATE TABLE
    salaries (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        user_id CHAR(36) NOT NULL,
        amount DECIMAL(12, 2) NOT NULL,
        payment_date DATE NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE
    );

----------------------------------------------------------------
-- END OF SCRIPT
----------------------------------------------------------------
