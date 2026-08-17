CREATE TABLE dim_date(
  date_id           INT NOT NULL,
  date_actual       DATE NOT NULL,
  year_actual       INT NOT NULL,
  month_actual      INT NOT NULL,
  day_of_month      INT NOT NULL,
  day_name          VARCHAR(15) NOT NULL, 
  day_name_abbrev   VARCHAR(3) NOT NULL,
  day_of_week       INT NOT NULL
);

ALTER TABLE public.dim_date ADD CONSTRAINT d_date_date_id_pk PRIMARY KEY (date_id);

CREATE INDEX dim_date_date_actual_idx ON d_date(date_actual);

INSERT INTO dim_date
WITH limites AS (
    SELECT 
        DATE(MIN(placed_at)) as start_date, 
        DATE(MAX(placed_at)) as end_date
    FROM orders 
    WHERE placed_at <= NOW()
),
calendario AS (
    SELECT generate_series(
        (SELECT start_date FROM limites), 
        (SELECT end_date FROM limites), 
        '1 day'::interval
    )::date AS datum
)
SELECT 
    TO_CHAR(datum, 'YYYYMMDD')::INT AS date_id,
    datum AS date_actual,
    EXTRACT(YEAR FROM datum)::INT AS year_actual,
    EXTRACT(MONTH FROM datum)::INT AS month_actual,
    EXTRACT(DAY FROM datum)::INT AS day_of_month,
    
    CASE EXTRACT(ISODOW FROM datum)::INT
        WHEN 1 THEN 'Segunda-feira'
        WHEN 2 THEN 'Terça-feira'
        WHEN 3 THEN 'Quarta-feira'
        WHEN 4 THEN 'Quinta-feira'
        WHEN 5 THEN 'Sexta-feira'
        WHEN 6 THEN 'Sábado'
        WHEN 7 THEN 'Domingo'
    END AS day_name, 
    
    CASE EXTRACT(ISODOW FROM datum)::INT
        WHEN 1 THEN 'Seg'
        WHEN 2 THEN 'Ter'
        WHEN 3 THEN 'Qua'
        WHEN 4 THEN 'Qui'
        WHEN 5 THEN 'Sex'
        WHEN 6 THEN 'Sáb'
        WHEN 7 THEN 'Dom'
    END AS day_name_abbrev, 
    
    EXTRACT(ISODOW FROM datum)::INT AS day_of_week
FROM calendario
ORDER BY date_id ASC;


WITH faturamento_diario AS (
    SELECT 
        d.date_actual,
        d.day_name AS dia_semana,
        d.day_of_week,
        COALESCE(SUM(o.total), 0) AS total_do_dia
    FROM dim_date d
    LEFT JOIN orders o 
        ON d.date_id = TO_CHAR(o.placed_at, 'YYYYMMDD')::INT 
        AND o.channel = 'pos' 
        AND o.status = 'paid'
    WHERE d.date_actual <= NOW()
    GROUP BY 
        d.date_actual, 
        d.day_name, 
        d.day_of_week
)
SELECT 
    dia_semana, 
    ROUND(AVG(total_do_dia), 2) AS media_vendas_dia
FROM faturamento_diario
GROUP BY 
    dia_semana, 
    day_of_week
ORDER BY 
    media_vendas_dia ASC;
