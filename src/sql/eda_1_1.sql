SELECT COUNT(*) AS total_linhas
FROM 'data/raw/orders.csv';

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