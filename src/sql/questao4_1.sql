/*
-- sem duplicidade
SELECT id, person_type, legal_name, trade_name, tax_id, state_registration, email, phone, is_active, created_at, updated_at, count(*) as records
FROM customers
GROUP BY id, person_type, legal_name, trade_name, tax_id, state_registration, email, phone, is_active, created_at, updated_at
HAVING count(*) > 1;

-- sem duplicidade
SELECT id, name, description, brand_id, category_id, ncm_code, unit_of_measure, is_active, created_at, updated_at, count(*) as records
FROM products
GROUP BY id, name, description, brand_id, category_id, ncm_code, unit_of_measure, is_active, created_at, updated_at
HAVING count(*) > 1;

-- sem duplicidade
SELECT id, name, slug, parent_category_id, is_active, created_at, updated_at, count(*) as records
FROM categories
GROUP BY id, name, slug, parent_category_id, is_active, created_at, updated_at
HAVING count(*) > 1;

-- sem duplicidade
SELECT id, product_id, sku, barcode_ean, sale_price, cost_price, weight_kg, icms_rate, ipi_rate, is_active, created_at, updated_at, count(*) as records
FROM product_variants
GROUP BY id, product_id, sku, barcode_ean, sale_price, cost_price, weight_kg, icms_rate, ipi_rate, is_active, created_at, updated_at
HAVING count(*) > 1;

-- sem duplicidade
SELECT id, order_number, channel, customer_id, salesperson_id, location_id, status, subtotal, discount_amount, total, placed_at, created_at, updated_at, count(*) as records
FROM orders
GROUP BY id, order_number, channel, customer_id, salesperson_id, location_id, status, subtotal, discount_amount, total, placed_at, created_at, updated_at
HAVING count(*) > 1;

-- sem duplicidade
SELECT id, order_id, product_variant_id, quantity, unit_price, icms_rate, ipi_rate, line_total, count(*) as records
FROM order_items
GROUP BY id, order_id, product_variant_id, quantity, unit_price, icms_rate, ipi_rate, line_total
HAVING count(*) > 1;


-- Apenas salesperson_id contém nulls. Para a análise pedida, não interfere em nada
SELECT 
    SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS id_nulls,
    SUM(CASE WHEN order_number IS NULL THEN 1 ELSE 0 END) AS order_number_nulls,
    SUM(CASE WHEN channel IS NULL THEN 1 ELSE 0 END) AS channel_nulls,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id_nulls,
    SUM(CASE WHEN salesperson_id IS NULL THEN 1 ELSE 0 END) AS salesperson_id_nulls,
    SUM(CASE WHEN location_id IS NULL THEN 1 ELSE 0 END) AS location_id_nulls,
    SUM(CASE WHEN status IS NULL THEN 1 ELSE 0 END) AS status_nulls,
    SUM(CASE WHEN subtotal IS NULL THEN 1 ELSE 0 END) AS subtotal_nulls,
    SUM(CASE WHEN discount_amount IS NULL THEN 1 ELSE 0 END) AS discount_amount_nulls,
    SUM(CASE WHEN total IS NULL THEN 1 ELSE 0 END) AS total_nulls,
    SUM(CASE WHEN placed_at IS NULL THEN 1 ELSE 0 END) AS placed_at_nulls,
    SUM(CASE WHEN created_at IS NULL THEN 1 ELSE 0 END) AS created_at_nulls,
    SUM(CASE WHEN updated_at IS NULL THEN 1 ELSE 0 END) AS updated_at_nulls
FROM orders;
*/


-- Faturamento Total, Frequência e Ticket Médio
WITH clientes_ativos AS (
    SELECT id, legal_name
    FROM customers
    WHERE is_active = true 
),
metricas_financeiras AS(
    SELECT 
        c.id as customer_id, 
        c.legal_name as customer_name, 
        SUM(o.total) as faturamento_total, 
        COUNT(DISTINCT o.id) as frequencia_compra, 
        ROUND((SUM(o.total) / COUNT(o.id))::numeric, 2) as ticket_medio
    FROM clientes_ativos c
    JOIN orders o ON c.id = o.customer_id
    WHERE o.placed_at <= NOW() AND status = 'paid'
    GROUP BY c.id, c.legal_name
),
metricas_categorias AS (
    SELECT 
        o.customer_id,
        COUNT(DISTINCT c.id) AS categorias_distintas
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.id
    JOIN product_variants as pv ON pv.id = oi.product_variant_id
    JOIN products  p ON p.id = pv.product_id
    JOIN categories c ON c.id = p.category_id
    WHERE o.status = 'paid'
        AND (c.is_active = true OR (c.is_active = false AND o.placed_at < c.updated_at))
    GROUP BY o.customer_id
)
SELECT f.customer_id, f.customer_name, f.ticket_medio, c.categorias_distintas
FROM metricas_financeiras f
JOIN metricas_categorias c ON f.customer_id = c.customer_id
WHERE c.categorias_distintas >= 13
ORDER BY f.ticket_medio DESC, f.customer_id ASC 
LIMIT 10

/*
SELECT 
    cat.name AS categoria_campea,
    SUM(oi.quantity) AS quantidade_total_itens
FROM top_10 t10
JOIN orders o ON t10.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.id
JOIN product_variants pv ON pv.id = oi.product_variant_id
JOIN products p ON p.id = pv.product_id
JOIN categories cat ON cat.id = p.category_id
WHERE o.status = 'paid'
GROUP BY cat.name
ORDER BY quantidade_total_itens DESC
LIMIT 10;
*/