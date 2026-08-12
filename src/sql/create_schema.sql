CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    order_id INT,
    method VARCHAR(255),
    installments INT,
    amount DECIMAL,
    status VARCHAR(255),
    paid_at TIMESTAMP,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE product_suppliers (
    product_variant_id INT,
    supplier_id INT,
    supplier_sku VARCHAR(255),
    last_quoted_cost DECIMAL,
    lead_time_days INT,
    is_preferred BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE purchase_order_items (
    id SERIAL PRIMARY KEY,
    purchase_order_id INT,
    product_variant_id INT,
    quantity_ordered INT,
    unit_cost DECIMAL,
    line_total DECIMAL
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(255),
    channel VARCHAR(255),
    customer_id INT,
    salesperson_id VARCHAR(255),
    location_id INT,
    status VARCHAR(255),
    subtotal DECIMAL,
    discount_amount DECIMAL,
    total DECIMAL,
    placed_at TIMESTAMP,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE suppliers (
    id SERIAL PRIMARY KEY,
    legal_name VARCHAR(255),
    trade_name VARCHAR(255),
    country VARCHAR(255),
    tax_id INT,
    tax_id_type VARCHAR(255),
    email VARCHAR(255),
    phone INT,
    contact_name VARCHAR(255),
    is_active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE return_items (
    id SERIAL PRIMARY KEY,
    return_id INT,
    order_item_id INT,
    quantity INT,
    action VARCHAR(255),
    exchange_variant_id VARCHAR(255),
    unit_refund_amount DECIMAL
);

CREATE TABLE product_variants (
    id SERIAL PRIMARY KEY,
    product_id INT,
    sku VARCHAR(255),
    barcode_ean INT,
    sale_price DECIMAL,
    cost_price DECIMAL,
    weight_kg DECIMAL,
    icms_rate DECIMAL,
    ipi_rate DECIMAL,
    is_active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE stock_levels (
    product_variant_id INT,
    location_id INT,
    quantity_on_hand DECIMAL,
    reorder_point VARCHAR(255),
    updated_at TIMESTAMP
);

CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INT,
    product_variant_id INT,
    quantity INT,
    unit_price DECIMAL,
    icms_rate DECIMAL,
    ipi_rate DECIMAL,
    line_total DECIMAL
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    description VARCHAR(255),
    brand_id INT,
    category_id INT,
    ncm_code INT,
    unit_of_measure VARCHAR(255),
    is_active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(255),
    cpf INT,
    email VARCHAR(255),
    role VARCHAR(255),
    primary_location_id INT,
    hire_date TIMESTAMP,
    termination_date VARCHAR(255),
    is_active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE fiscal_invoices (
    id SERIAL PRIMARY KEY,
    order_id INT,
    nfe_number VARCHAR(255),
    nfe_access_key INT,
    series INT,
    issued_at TIMESTAMP,
    status VARCHAR(255),
    total_amount DECIMAL,
    xml_storage_uri VARCHAR(255),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE variant_attribute_values (
    product_variant_id INT,
    attribute_id INT,
    value DECIMAL
);

CREATE TABLE goods_receipt_items (
    id SERIAL PRIMARY KEY,
    goods_receipt_id INT,
    purchase_order_item_id INT,
    quantity_received DECIMAL
);

CREATE TABLE brands (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    country VARCHAR(255),
    is_active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE stock_movements (
    id SERIAL PRIMARY KEY,
    product_variant_id INT,
    location_id INT,
    movement_type VARCHAR(255),
    quantity DECIMAL,
    reference_table VARCHAR(255),
    reference_id VARCHAR(255),
    employee_id VARCHAR(255),
    notes VARCHAR(255),
    occurred_at TIMESTAMP,
    created_at TIMESTAMP
);

CREATE TABLE locations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    location_type VARCHAR(255),
    postal_code VARCHAR(255),
    street VARCHAR(255),
    number INT,
    complement VARCHAR(255),
    district VARCHAR(255),
    city VARCHAR(255),
    state VARCHAR(255),
    country VARCHAR(255),
    is_active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    slug VARCHAR(255),
    parent_category_id VARCHAR(255),
    is_active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE returns (
    id SERIAL PRIMARY KEY,
    return_number VARCHAR(255),
    order_id INT,
    customer_id INT,
    received_at_location_id INT,
    status VARCHAR(255),
    reason VARCHAR(255),
    total_refund_amount DECIMAL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE attributes (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    data_type VARCHAR(255)
);

CREATE TABLE addresses (
    id SERIAL PRIMARY KEY,
    customer_id INT,
    address_type VARCHAR(255),
    postal_code VARCHAR(255),
    street VARCHAR(255),
    number INT,
    complement VARCHAR(255),
    district VARCHAR(255),
    city VARCHAR(255),
    state VARCHAR(255),
    country VARCHAR(255),
    is_primary BOOLEAN
);

CREATE TABLE goods_receipts (
    id SERIAL PRIMARY KEY,
    purchase_order_id INT,
    received_by_employee_id INT,
    received_at TIMESTAMP,
    notes VARCHAR(255),
    created_at TIMESTAMP
);

CREATE TABLE purchase_orders (
    id SERIAL PRIMARY KEY,
    po_number VARCHAR(255),
    supplier_id INT,
    buyer_id INT,
    destination_location_id INT,
    status VARCHAR(255),
    currency VARCHAR(255),
    subtotal DECIMAL,
    total DECIMAL,
    placed_at TIMESTAMP,
    expected_delivery_at TIMESTAMP,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    person_type VARCHAR(255),
    legal_name VARCHAR(255),
    trade_name VARCHAR(255),
    tax_id INT,
    state_registration INT,
    email VARCHAR(255),
    phone INT,
    is_active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

