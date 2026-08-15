CREATE TABLE IF NOT EXISTS addresses (
    id SERIAL PRIMARY KEY,
    customer_id BIGINT,
    address_type VARCHAR(255),
    postal_code VARCHAR(255),
    street VARCHAR(255),
    number BIGINT,
    complement VARCHAR(255),
    district VARCHAR(255),
    city VARCHAR(255),
    state VARCHAR(255),
    country VARCHAR(255),
    is_primary BOOLEAN
);

CREATE TABLE IF NOT EXISTS attributes (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    data_type VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS brands (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    country VARCHAR(255),
    is_active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    slug VARCHAR(255),
    parent_category_id VARCHAR(255),
    is_active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS customers (
    id SERIAL PRIMARY KEY,
    person_type VARCHAR(255),
    legal_name VARCHAR(255),
    trade_name VARCHAR(255),
    tax_id VARCHAR(255),
    state_registration VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(255),
    is_active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS employees (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(255),
    cpf BIGINT,
    email VARCHAR(255),
    role VARCHAR(255),
    primary_location_id BIGINT,
    hire_date TIMESTAMP,
    termination_date VARCHAR(255),
    is_active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS fiscal_invoices (
    id SERIAL PRIMARY KEY,
    order_id BIGINT,
    nfe_number VARCHAR(255),
    nfe_access_key VARCHAR(255),
    series BIGINT,
    issued_at TIMESTAMP,
    status VARCHAR(255),
    total_amount DECIMAL,
    xml_storage_uri VARCHAR(255),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS goods_receipts (
    id SERIAL PRIMARY KEY,
    purchase_order_id BIGINT,
    received_by_employee_id BIGINT,
    received_at TIMESTAMP,
    notes VARCHAR(255),
    created_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS goods_receipt_items (
    id SERIAL PRIMARY KEY,
    goods_receipt_id BIGINT,
    purchase_order_item_id BIGINT,
    quantity_received DECIMAL
);

CREATE TABLE IF NOT EXISTS locations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    location_type VARCHAR(255),
    postal_code VARCHAR(255),
    street VARCHAR(255),
    number BIGINT,
    complement VARCHAR(255),
    district VARCHAR(255),
    city VARCHAR(255),
    state VARCHAR(255),
    country VARCHAR(255),
    is_active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(255),
    channel VARCHAR(255),
    customer_id BIGINT,
    salesperson_id VARCHAR(255),
    location_id BIGINT,
    status VARCHAR(255),
    subtotal DECIMAL,
    discount_amount DECIMAL,
    total DECIMAL,
    placed_at TIMESTAMP,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS order_items (
    id SERIAL PRIMARY KEY,
    order_id BIGINT,
    product_variant_id BIGINT,
    quantity BIGINT,
    unit_price DECIMAL,
    icms_rate DECIMAL,
    ipi_rate DECIMAL,
    line_total DECIMAL
);

CREATE TABLE IF NOT EXISTS payments (
    id SERIAL PRIMARY KEY,
    order_id BIGINT,
    method VARCHAR(255),
    installments BIGINT,
    amount DECIMAL,
    status VARCHAR(255),
    paid_at TIMESTAMP,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    description VARCHAR(255),
    brand_id BIGINT,
    category_id BIGINT,
    ncm_code BIGINT,
    unit_of_measure VARCHAR(255),
    is_active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS product_suppliers (
    product_variant_id BIGINT,
    supplier_id BIGINT,
    supplier_sku VARCHAR(255),
    last_quoted_cost DECIMAL,
    lead_time_days BIGINT,
    is_preferred BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS product_variants (
    id SERIAL PRIMARY KEY,
    product_id BIGINT,
    sku VARCHAR(255),
    barcode_ean VARCHAR(255),
    sale_price DECIMAL,
    cost_price DECIMAL,
    weight_kg DECIMAL,
    icms_rate DECIMAL,
    ipi_rate DECIMAL,
    is_active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS purchase_orders (
    id SERIAL PRIMARY KEY,
    po_number VARCHAR(255),
    supplier_id BIGINT,
    buyer_id BIGINT,
    destination_location_id BIGINT,
    status VARCHAR(255),
    currency VARCHAR(255),
    subtotal DECIMAL,
    total DECIMAL,
    placed_at TIMESTAMP,
    expected_delivery_at TIMESTAMP,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS purchase_order_items (
    id SERIAL PRIMARY KEY,
    purchase_order_id BIGINT,
    product_variant_id BIGINT,
    quantity_ordered BIGINT,
    unit_cost DECIMAL,
    line_total DECIMAL
);

CREATE TABLE IF NOT EXISTS returns (
    id SERIAL PRIMARY KEY,
    return_number VARCHAR(255),
    order_id BIGINT,
    customer_id BIGINT,
    received_at_location_id BIGINT,
    status VARCHAR(255),
    reason VARCHAR(255),
    total_refund_amount DECIMAL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS return_items (
    id SERIAL PRIMARY KEY,
    return_id BIGINT,
    order_item_id BIGINT,
    quantity BIGINT,
    action VARCHAR(255),
    exchange_variant_id VARCHAR(255),
    unit_refund_amount DECIMAL
);

CREATE TABLE IF NOT EXISTS stock_levels (
    product_variant_id BIGINT,
    location_id BIGINT,
    quantity_on_hand DECIMAL,
    reorder_point VARCHAR(255),
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stock_movements (
    id SERIAL PRIMARY KEY,
    product_variant_id BIGINT,
    location_id BIGINT,
    movement_type VARCHAR(255),
    quantity DECIMAL,
    reference_table VARCHAR(255),
    reference_id VARCHAR(255),
    employee_id VARCHAR(255),
    notes VARCHAR(255),
    occurred_at TIMESTAMP,
    created_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS suppliers (
    id SERIAL PRIMARY KEY,
    legal_name VARCHAR(255),
    trade_name VARCHAR(255),
    country VARCHAR(255),
    tax_id VARCHAR(255),
    tax_id_type VARCHAR(255),
    email VARCHAR(255),
    phone BIGINT,
    contact_name VARCHAR(255),
    is_active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS variant_attribute_values (
    product_variant_id BIGINT,
    attribute_id BIGINT,
    value VARCHAR(255)
);

