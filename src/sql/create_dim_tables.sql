DROP TABLE IF EXISTS dim_products CASCADE;

CREATE TABLE dim_products AS
SELECT 
    pv.id AS product_variant_id,    
    pv.sku AS sku,                  
    p.id AS product_id,
    p.name AS product_name,
    c.name AS category_name
FROM product_variants pv
INNER JOIN products p ON pv.product_id = p.id
LEFT JOIN categories c ON p.category_id = c.id
WHERE p.is_active = True;

ALTER TABLE dim_products ADD PRIMARY KEY (product_variant_id);

DROP TABLE IF EXISTS dim_customers CASCADE;
CREATE TABLE dim_customers AS
SELECT 
    id AS customer_id,
    person_type,
    legal_name,
    trade_name
FROM customers;
ALTER TABLE dim_customers ADD PRIMARY KEY (customer_id);

DROP TABLE IF EXISTS dim_locations CASCADE;

CREATE TABLE dim_locations AS
SELECT 
    id AS location_id,
    city AS city,
    state AS state,
    country AS country
FROM locations;

ALTER TABLE dim_locations ADD PRIMARY KEY (location_id);

DROP TABLE IF EXISTS fact_orders CASCADE;

CREATE TABLE fact_orders AS
SELECT 
    oi.id AS order_item_id,             
    o.id AS order_id,                   
    o.customer_id AS customer_id,       
    o.location_id AS location_id,       
    oi.product_variant_id,              
    DATE(o.placed_at) AS date_actual,  
    o.channel AS channel,               
    o.status AS status,                 
    oi.quantity AS quantity,            
    oi.unit_price AS unit_price,        
    oi.line_total AS total_amount       
FROM order_items oi
INNER JOIN orders o ON oi.order_id = o.id
WHERE o.status = 'paid';               

ALTER TABLE fact_orders ADD PRIMARY KEY (order_item_id);