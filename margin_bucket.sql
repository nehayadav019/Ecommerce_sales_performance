/*
8.Margin Bucket Segmentation
Classify products into High, Medium, and Low margin groups based on profit percentage.
Used to evaluate product profitability beyond just sales volume.*/


WITH margins AS (
    SELECT
        p.product_name,
        SUM(oi.quantity * oi.price_per_unit) AS revenue,
        SUM(p.cogs * oi.quantity) AS cost,
        (SUM(oi.quantity * oi.price_per_unit) - SUM(p.cogs * oi.quantity)) AS profit
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.product_name
)
SELECT
    product_name,
    ROUND(((profit / revenue) * 100)::numeric, 2) AS margin_percent,
    CASE
        WHEN (profit / revenue) * 100 >= 70 THEN 'High Margin'
        WHEN (profit / revenue) * 100 >= 40 THEN 'Medium Margin'
        ELSE 'Low Margin'
    END AS margin_bucket
FROM margins
ORDER BY margin_percent DESC;




