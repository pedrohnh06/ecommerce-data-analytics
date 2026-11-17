
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

WITH data_referencia AS (
    SELECT 
        DATE(MAX(order_purchase_timestamp)) + 1 AS data_base
    FROM orders
),
rfm_base AS (
    SELECT
        c.customer_unique_id,
        (SELECT data_base FROM data_referencia) - DATE(MAX(o.order_purchase_timestamp)) AS recencia_dias,
        COUNT(DISTINCT o.order_id) AS qtd_pedidos,
        SUM(oi.price) AS valor_total
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
rfm_quartil AS (
    SELECT
        customer_unique_id,
        recencia_dias,
        qtd_pedidos,
        valor_total,
        NTILE(4) OVER (ORDER BY recencia_dias DESC) AS r_score,
        NTILE(4) OVER (ORDER BY qtd_pedidos ASC) AS f_score,
        NTILE(4) OVER (ORDER BY valor_Total ASC) AS m_score
    FROM rfm_base
)
SELECT *,
    CASE
        WHEN r_score = 4 
        AND f_score >= 3 
        AND m_score >= 3
        THEN 'Champions'

        WHEN r_score >= 3
        AND f_score >= 3
        THEN 'Loyal'

        WHEN r_score = 4
        AND f_Score <= 2
        AND m_score >= 3
        THEN 'Promising'

        WHEN r_score <= 2 
        AND f_score >= 3 
        AND m_score >=3
        THEN 'AT Risk'

        WHEN r_score = 1
        AND f_score = 1
        AND m_score = 1
        THEN 'Lost'

        ELSE 'Others'
    END AS segmento
FROM rfm_quartil
ORDER BY segmento, valor_total DESC
LIMIT 10;

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


-- tempo de entrega -- 

SELECT 
    customer_id,
    order_purchase_timestamp AS data_da_compra,
    order_delivered_customer_date AS data_da_entrega,
    order_estimated_delivery_date AS data_estimada,

    DATE(order_delivered_customer_date) - DATE(order_purchase_timestamp) AS tempo_entrega,
    
    CASE 
        WHEN DATE(order_delivered_customer_date) <= DATE(order_estimated_delivery_date)
        THEN 'No prazo'
        ELSE 'Fora do prazo'
    END AS status_entrega

FROM orders
WHERE order_status = 'delivered'
LIMIT 10;

-- Avaliação média por status de entrega (No prazo vs Fora do prazo) --

WITH tabela_temporaria AS (
    SELECT 
        o.order_id,
        o.customer_id,
        o.order_purchase_timestamp AS data_da_compra,
        o.order_delivered_customer_date AS data_da_entrega,
        o.order_estimated_delivery_date AS data_estimada,

        DATE(o.order_delivered_customer_date) - DATE(o.order_purchase_timestamp) AS tempo_entrega,
        
        CASE 
            WHEN DATE(o.order_delivered_customer_date) <= DATE(o.order_estimated_delivery_date)
            THEN 'No prazo'
            ELSE 'Fora do prazo'
        END AS status_entrega

    FROM orders o
    WHERE o.order_status = 'delivered'
)
SELECT 
    t.status_entrega,
    COUNT(*) AS quantidade_de_pedidos,
    ROUND(AVG(rev.review_score), 2) AS nota_media_avaliacoes
FROM tabela_temporaria t
JOIN order_reviews rev ON t.order_id = rev.order_id
GROUP BY t.status_entrega;

-- Tempo médio e taxa de atraso por estado (UF) --

WITH tabela_temporaria AS (
    SELECT 
        o.customer_id,
        o.order_purchase_timestamp AS data_da_compra,
        o.order_delivered_customer_date AS data_entrega,
        o.order_estimated_delivery_date AS data_estimada,

        DATE(o.order_delivered_customer_date) - DATE(o.order_purchase_timestamp) AS tempo_entrega,
        
        CASE 
            WHEN DATE(o.order_delivered_customer_date) <= DATE(o.order_estimated_delivery_date)
            THEN 'No prazo'
            ELSE 'Fora do prazo'
        END AS status_entrega
    FROM orders o
    WHERE o.order_status = 'delivered'
)
SELECT 
    c.customer_state,
    ROUND(AVG(t.tempo_entrega)) AS tempo_medio,
    ROUND(100.0 * SUM(CASE WHEN t.status_entrega = 'Fora do prazo' THEN 1 ELSE 0 END) / COUNT(*)) AS taxa_atraso
FROM tabela_temporaria t
JOIN customers c ON c.customer_id = t.customer_id
GROUP BY 
    c.customer_state
ORDER BY taxa_atraso DESC;

-- Análise de Sellers (Parte 1: Geografia de Origem) --

SELECT
    s.seller_state,
    SUM(oi.price) AS receita_total,
    COUNT(DISTINCT s.seller_id) AS qtd_vendedores,
    ROUND(100.0 * SUM(oi.price) / SUM(SUM(oi.price)) OVER(), 2) AS percentual_receita
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_state
ORDER BY receita_total DESC;

-- Curva ABC de Vendedores (Parte 2: Princípio de Pareto) -- 

WITH agrupamento_receita_vendedor AS (
    SELECT 
        s.seller_id,
        SUM(oi.price) AS receita_seller
    FROM sellers s
    JOIN order_items oi ON oi.seller_id = s.seller_id
    GROUP BY s.seller_id
),
receita_percentual_acumulado AS (
    SELECT
        ag.seller_id,
        ag.receita_seller,
        SUM(ag.receita_seller) OVER (ORDER BY ag.receita_seller DESC) AS receita_acumulada,
        ROUND(100.0 * SUM(ag.receita_seller) OVER (ORDER BY ag.receita_seller DESC) / SUM(ag.receita_seller) OVER (), 2) AS pct_acumulado
    FROM agrupamento_receita_vendedor ag
    ORDER BY pct_acumulado
),
tabela_classificacao_ABC AS (
    SELECT
        seller_id,
        CASE
            WHEN rpa.pct_acumulado <= 80
            THEN 'A' 

            WHEN rpa.pct_acumulado <= 95
            THEN 'B' 

            ELSE 'C'
        END AS classificacao_ABC
    FROM receita_percentual_acumulado rpa
    ORDER BY classificacao_ABC ASC
)
SELECT
    t.classificacao_ABC,
    COUNT(*) AS qtd_vendedores,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_vendedores, 
    ROUND(SUM(ag.receita_seller), 2) AS receita_total,
    ROUND(100.0 * SUM(receita_seller) / SUM(SUM(receita_seller)) OVER (), 2) AS pct_receita
FROM tabela_classificacao_ABC t
JOIN agrupamento_receita_vendedor ag ON ag.seller_id = t.seller_id
GROUP BY t.classificacao_ABC
ORDER BY t.classificacao_ABC ASC;