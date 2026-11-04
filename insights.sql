--Receita e volume por categoria--

SELECT 
    p.product_category_name,
    SUM(oi.price) AS receita_total,
    COUNT(*) AS qtd_items,
    AVG(oi.price) AS preco_medio,
    SUM(oi.price) / COUNT(*) AS receita_media_por_item
FROM 
    order_items oi
JOIN products p
ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY receita_total DESC
LIMIT 10;

--Evolução temporal da receita (mensal)--

SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS mes,
    SUM(oi.price) AS receita_mensal
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY mes
ORDER BY mes;

--RFM (Recência, Frequência, Valor Monetário) por cliente--

WITH recencia AS (
    SELECT
        MAX(o.order_purchase_timestamp) AS ultima_compra,
        CURRENT_DATE - DATE(MAX(o.order_purchase_timestamp)) AS dias_desde_ultima
    FROM customers c
    JOIN orders o 
    ON c.customer_id = o.customer_id
    GROUP BY c.customer_id;
),
frequencia AS (
    SELECT 
        c.customers,
        COUNT(o.order_id) AS qnt_pedidos
    FROM customers c 
    JOIN orders o 
    ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
),
monetario AS (
    SELECT 
        c.customer_id,
        SUM(oi.price) AS valor_total
    FROM customers c 
    JOIN orders o 
    ON c.customer_id = o.customer_id
    JOIN order_items oi
    ON o.order_id = oi.order_id
)

SELECT r.customer_id,
    r.dias_desde_ultima,
    f.qnt_pedidos,
    m.valor_total,
    NTILE(4) OVER (ORDER BY r.dias_desde_ultima DESC) AS recencia_quartil,
    NTILE(4) OVER (ORDER BY f.qnt_pedidos ASC) AS frequencia_quartil,
    NTILE(4) OVER (ORDER BY m.valor_total DESC) AS monetario_quartil,
    CASE 
        WHEN NTILE(4) OVER (ORDER BY r.dias_desde_ultima DESC) = 1
        AND NTILE(4) OVER (ORDER BY f.qnt_pedidos ASC) = 4
        AND NTILE(4) OVER (ORDER BY m.valor_total DESC) = 4
        THEN 'Best'
        ELSE 'Other'
    END AS segmento
FROM recencia r 
JOIN frequencia f ON r.customer_id = f.customer_id
JOIN monetario m ON r.customer_id = m.customer_id
ORDER BY valor_total DESC
LIMIT 20;

--Receita por Categoria com Avaliação-- 

WITH cat_receita AS (
    SELECT p.product_category_name,
           SUM(oi.price) AS receita
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.product_category_name
),
cat_avaliacao AS (
    SELECT p.product_category_name,
           AVG(r.review_score) AS media_nota,
           COUNT(r.review_id)  AS total_reviews
    FROM order_items oi
    JOIN order_reviews r ON oi.order_id = r.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.product_category_name
)
SELECT cr.product_category_name,
       cr.receita,
       ca.media_nota,
       ca.total_reviews
FROM cat_receita cr
LEFT JOIN cat_avaliacao ca
  ON cr.product_category_name = ca.product_category_name
ORDER BY cr.receita DESC
LIMIT 10;