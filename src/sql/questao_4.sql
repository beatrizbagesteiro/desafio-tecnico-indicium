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