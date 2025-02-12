DROP DATABASE IF EXISTS steel_company;
CREATE DATABASE steel_company;
USE steel_company;

----------------------------------------------------------------
-- 1. CONFIGURATION AND SECURITY TABLES
----------------------------------------------------------------

-- Branches table
CREATE TABLE branches (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(100)
);

-- Roles table
CREATE TABLE roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT
);

-- Permissions table (for specific actions)
CREATE TABLE permissions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT
);

-- Junction table for many-to-many relationship between roles and permissions
CREATE TABLE role_permissions (
    role_id BIGINT NOT NULL,
    permission_id BIGINT NOT NULL,
    PRIMARY KEY (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Users table (uses UUID)
CREATE TABLE users (
    id CHAR(36) PRIMARY KEY,  -- UUID identifier (e.g., '550e8400-e29b-41d4-a716-446655440000')
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,        -- Stored encrypted
    full_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    role_id BIGINT NOT NULL,
    branch_id BIGINT NOT NULL,
    creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE ON UPDATE CASCADE
);

----------------------------------------------------------------
-- 2. CUSTOMER AND LOYALTY PROGRAM TABLES
----------------------------------------------------------------

-- Customer categories table
CREATE TABLE customer_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    minimum_frequency BIGINT,         -- Minimum purchases in a period
    minimum_amount DECIMAL(12,2),     -- Minimum spending amount in a period
    discount DECIMAL(5,2),            -- Applicable discount percentage
    inactivity_period BIGINT          -- In months, for benefit changes
);

-- Customers table (uses UUID)
CREATE TABLE customers (
    id CHAR(36) PRIMARY KEY,  -- UUID
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(255),
    associated_company VARCHAR(100),
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
    category_id BIGINT,
    points BIGINT DEFAULT 0,
    inactivity_date DATE,
    FOREIGN KEY (category_id) REFERENCES customer_categories(id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Points transactions table
CREATE TABLE points_transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id CHAR(36) NOT NULL,
    points_earned BIGINT DEFAULT 0,
    points_redeemed BIGINT DEFAULT 0,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE ON UPDATE CASCADE
);

----------------------------------------------------------------
-- 3. PRODUCTS, INVENTORY AND CHARACTERISTICS TABLES
----------------------------------------------------------------

-- Product categories table
CREATE TABLE categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE NOT NULL,
    sat_key VARCHAR(50),             -- Tax authority product key
    description VARCHAR(200)
);

-- Products table
CREATE TABLE products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_code VARCHAR(50) UNIQUE,
    name VARCHAR(100) NOT NULL,
    category_id BIGINT NOT NULL,
    description TEXT,
    purchase_price DECIMAL(12,2) NOT NULL,
    sale_price DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Product images table (1:N relationship)
CREATE TABLE product_images (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    image_path VARCHAR(255) NOT NULL,
    is_main BOOLEAN DEFAULT FALSE,
    display_order BIGINT DEFAULT 0,  -- For display order
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Specifications table
CREATE TABLE specifications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    attribute VARCHAR(100) NOT NULL,
    value VARCHAR(100) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Weights and dimensions table
CREATE TABLE weights_dimensions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    length DECIMAL(10,2),
    kg_per_meter DECIMAL(10,2),
    piece_weight DECIMAL(10,2),
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Standards catalog
CREATE TABLE standards_catalog (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    standard VARCHAR(100) UNIQUE NOT NULL
);

-- Product-standards relationship
CREATE TABLE product_standards (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    standard_id BIGINT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (standard_id) REFERENCES standards_catalog(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Finishes table
CREATE TABLE finishes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    finish VARCHAR(100),
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Inventory table
CREATE TABLE inventory (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    branch_id BIGINT NOT NULL,
    quantity BIGINT DEFAULT 0,
    minimum_stock BIGINT DEFAULT 10,
    maximum_stock BIGINT DEFAULT 1000,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE ON UPDATE CASCADE
);

----------------------------------------------------------------
-- 4. SALES, SALES DETAIL, INVOICES AND ORDERS TABLES
----------------------------------------------------------------

-- Sales table (uses UUID)
CREATE TABLE sales (
    id CHAR(36) PRIMARY KEY,  -- UUID
    customer_id CHAR(36) NOT NULL,
    sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(12,2) NOT NULL,
    payment_type_id BIGINT,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (payment_type_id) REFERENCES payment_types(id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Sales detail table with UNIQUE constraint (sale_id, product_id)
CREATE TABLE sales_detail (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sale_id CHAR(36) NOT NULL,
    product_id BIGINT NOT NULL,
    quantity BIGINT NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    applied_discount DECIMAL(5,2) DEFAULT 0,
    UNIQUE (sale_id, product_id),
    FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Invoices table
CREATE TABLE invoices (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sale_id CHAR(36) NOT NULL,
    issue_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(12,2) NOT NULL,
    file_path VARCHAR(255),
    FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Order status catalog
CREATE TABLE order_status_catalog (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

INSERT INTO order_status_catalog (name) VALUES ('Pending'), ('In Transit'), ('Delivered');

-- Orders table (uses UUID)
CREATE TABLE orders (
    id CHAR(36) PRIMARY KEY,  -- UUID
    sale_id CHAR(36) NOT NULL,
    delivery_person_id CHAR(36),  -- Reference to users (UUID)
    status_id BIGINT NOT NULL,
    assignment_date TIMESTAMP,
    delivery_date TIMESTAMP,
    FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (delivery_person_id) REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (status_id) REFERENCES order_status_catalog(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Order notifications table
CREATE TABLE order_notifications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id CHAR(36) NOT NULL,
    delivery_person_id CHAR(36),
    details TEXT NOT NULL,
    notification_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (delivery_person_id) REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE
);

----------------------------------------------------------------
-- 5. PAYMENT METHODS AND CATALOG TABLES
----------------------------------------------------------------

-- Payment types table
CREATE TABLE payment_types (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

-- Purchase type catalog
CREATE TABLE purchase_type_catalog (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

-- Accounts payable status catalog
CREATE TABLE ap_status_catalog (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

-- Accounts receivable status catalog
CREATE TABLE ar_status_catalog (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

----------------------------------------------------------------
-- 6. PURCHASES, SUPPLIERS AND PURCHASE DETAIL TABLES
----------------------------------------------------------------

-- Suppliers table
CREATE TABLE suppliers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(100),
    contact VARCHAR(100)
);

-- Purchases table (uses UUID)
CREATE TABLE purchases (
    id CHAR(36) PRIMARY KEY,  -- UUID
    supplier_id BIGINT NOT NULL,
    user_id CHAR(36) NOT NULL,  -- User (employee) who records the purchase
    purchase_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(12,2) NOT NULL,
    purchase_type_id BIGINT NOT NULL,
    includes_VAT BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (purchase_type_id) REFERENCES purchase_type_catalog(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Purchase detail table
CREATE TABLE purchase_detail (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    purchase_id CHAR(36) NOT NULL,
    product_id BIGINT NOT NULL,
    quantity BIGINT NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (purchase_id) REFERENCES purchases(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE ON UPDATE CASCADE
);

----------------------------------------------------------------
-- 7. EXPENSES AND ACCOUNTING TABLES
----------------------------------------------------------------

-- Expenses table
CREATE TABLE expenses (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    branch_id BIGINT NOT NULL,
    description VARCHAR(255),
    amount DECIMAL(12,2) NOT NULL,
    expense_date DATE NOT NULL,
    category VARCHAR(50),
    FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Accounts payable table
CREATE TABLE accounts_payable (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    supplier_id BIGINT NOT NULL,
    purchase_id CHAR(36),
    amount DECIMAL(12,2) NOT NULL,
    due_date DATE,
    status_id BIGINT NOT NULL,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (purchase_id) REFERENCES purchases(id) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (status_id) REFERENCES ap_status_catalog(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Accounts receivable table
CREATE TABLE accounts_receivable (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id CHAR(36) NOT NULL,
    sale_id CHAR(36),
    amount DECIMAL(12,2) NOT NULL,
    due_date DATE,
    status_id BIGINT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (status_id) REFERENCES ar_status_catalog(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

----------------------------------------------------------------
-- 8. QUOTES, SAVINGS FUND AND SALARIES TABLES
----------------------------------------------------------------

-- Quotes table (uses UUID)
CREATE TABLE quotes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id CHAR(36),
    user_id CHAR(36),
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(12,2) NOT NULL,
    show_detail BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Savings fund table
CREATE TABLE savings_fund (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    accumulated_amount DECIMAL(12,2) DEFAULT 0,
    update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Salaries table
CREATE TABLE salaries (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    payment_date DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
);

----------------------------------------------------------------
-- END OF SCRIPT
----------------------------------------------------------------