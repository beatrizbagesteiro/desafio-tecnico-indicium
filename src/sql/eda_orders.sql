SELECT * 
FROM 'data/raw/orders.csv' 
LIMIT 100;

-- Total de linhas
SELECT COUNT(*) AS total_linhas
FROM 'data/raw/orders.csv';

-- Total de colunas
SELECT COUNT(*) AS total_colunas
FROM (DESCRIBE 'data/raw/orders.csv');

-- Informações sobre as colunas
DESCRIBE 'data/raw/orders.csv';

-- Intervalo de datas (2020-2026)
SELECT 
    MIN(created_at) AS menor_data,
    MAX(created_at) AS maior_data
FROM 'data/raw/orders.csv';

-- Análise da coluna 'total'
SELECT 
    MIN(total) AS valor_minimo,
    MAX(total) AS valor_maximo,
    AVG(total) AS valor_medio
FROM 'data/raw/orders.csv';

-- Não existe pedidos duplicados nessa tabela
SELECT COUNT(DISTINCT order_number) 
FROM 'data/raw/orders.csv';

-- Valores nulos
-- Única coluna que possui valores nulos é sales_person_id
SELECT 
    COUNTIF(id IS NULL) as id_nulls,
    COUNTIF(order_number IS NULL) as order_number_nulls,
    COUNTIF(channel IS NULL) as channel_nulls,
    COUNTIF(customer_id IS NULL) as customer_id_nulls,
    COUNTIF(salesperson_id IS NULL) as salesperson_id_nulls,
    COUNTIF(location_id IS NULL) as location_id_nulls,
    COUNTIF(status IS NULL) as status_nulls,
    COUNTIF(subtotal IS NULL) as subtotal_nulls,
    COUNTIF(discount_amount IS NULL) as discount_amount_nulls,
    COUNTIF(total IS NULL) as total_nulls,
    COUNTIF(placed_at IS NULL) as placed_at_nulls,
    COUNTIF(created_at IS NULL) as created_at_nulls,
    COUNTIF(updated_at IS NULL) as updated_at_nulls
FROM 'data/raw/orders.csv';

-- Não tem inconsistencia
SELECT status 
FROM 'data/raw/orders.csv'
GROUP BY status;

-- Não tem inconsistencia
SELECT channel 
FROM 'data/raw/orders.csv'
GROUP BY channel;

-- Análise customer_id
SELECT 
    c.is_active, 
    c.created_at, 
    c.updated_at, 
    o.customer_id, 
    o.placed_at, 
    o.updated_at 
FROM 'data/raw/orders.csv' AS o 
JOIN 'data/raw/customers.csv' AS c ON o.customer_id = c.id
WHERE c.is_active = false AND o.placed_at > c.updated_at; 

-- Analise de pedidos com datas futuras
SELECT order_number, placed_at, created_at, updated_at
FROM 'data/raw/orders.csv'
WHERE NOW() < placed_at;

-- Análise location_id 
-- Tudo de acordo
SELECT 
    l.is_active, 
    l.created_at, 
    l.updated_at, 
    o.location_id, 
    o.placed_at, 
    o.updated_at 
FROM 'data/raw/orders.csv' AS o 
JOIN 'data/raw/locations.csv' AS l ON o.location_id = l.id
WHERE l.is_active = false AND o.placed_at > l.updated_at; 

-- Análise da coluna "total"
SELECT 
    order_number, 
    subtotal, 
    discount_amount, 
    total
FROM 'data/raw/orders.csv'
WHERE ROUND(subtotal - discount_amount, 2) <> ROUND(total, 2);

SELECT 
    order_number, 
    subtotal, 
    discount_amount, 
    total
FROM 'data/raw/orders.csv'
WHERE discount_amount < 0;

SELECT 
    order_number, 
    subtotal, 
    discount_amount, 
    total
FROM 'data/raw/orders.csv'
WHERE discount_amount > subtotal;

SELECT 
    order_number, 
    subtotal, 
    discount_amount, 
    total
FROM 'data/raw/orders.csv'
WHERE total < 0;

-- Verificar se os cálculos estão aplicados corretamente
WITH aux AS (
    SELECT 
        o.order_id,
        SUM(pv.sale_price * o.quantity) AS total_bruto
    FROM 'data/raw/order_items.csv' as o
    JOIN 'data/raw/product_variants.csv' as pv ON pv.id = o.product_variant_id
    GROUP BY o.order_id
)
SELECT 
    ord.id, 
    aux.total_bruto,
    ord.subtotal
FROM 'data/raw/orders.csv' AS ord
JOIN aux ON ord.id = aux.order_id 
WHERE ROUND(aux.total_bruto, 2) <> ROUND(ord.subtotal, 2);

-- Retorna valores que estão acima ou abaixo dos limites calculados
-- Precio não contabilizar as datas futuras e pedidos de clientes com cadastro desativado?
WITH quartis AS (
    SELECT 
        QUANTILE_CONT(total, 0.25) AS q1,
        QUANTILE_CONT(total, 0.75) AS q3 
    FROM 'data/raw/orders.csv'
    WHERE status IN ('paid', 'confirmed')
),
limites AS (
    SELECT 
        q1, 
        q3, 
        (q3 - q1) AS iqr,
        (q1 - 1.5 * (q3 - q1)) AS limite_inferior,
        (q3 + 1.5 * (q3 - q1)) AS limite_superior
    FROM quartis
)
SELECT 
    o.id, 
    o.total
FROM 'data/raw/orders.csv' AS o
CROSS JOIN limites AS l
WHERE o.total < l.limite_inferior OR o.total > l.limite_superior;