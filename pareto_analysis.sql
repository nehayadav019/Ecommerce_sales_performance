/*
6.Pareto Analysis (80/20 Rule)
Identify the top revenue-driving products by calculating cumulative contribution to total sales.
Helps determine which 20% of products generate ~80% of total revenue*/


WITH prod AS (
    SELECT
        p.product_name,
        SUM(oi.quantity * oi.price_per_unit) AS total_sales
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.product_name
    ORDER BY total_sales DESC
)
SELECT
    product_name,
    total_sales,
    ROUND((
        SUM(total_sales) OVER (ORDER BY total_sales DESC)
        * 100.0 / SUM(total_sales) OVER ())::numeric , 2
    ) AS cumulative_percent
FROM prod;
