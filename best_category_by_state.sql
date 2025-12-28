/*
4.Best Selling Category by State 
Identify the best-selling product for each state*/

WITH category_sales AS (
    SELECT 
        c.state,
        cat.category_name,
        SUM(oi.quantity * oi.price_per_unit) AS total_sales
    FROM category cat
    JOIN products p ON cat.category_id = p.category_id
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.state, cat.category_name
),
ranked AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY state ORDER BY total_sales DESC) AS row_num
    FROM category_sales
)
SELECT 
    *
FROM ranked
where row_num =1
ORDER BY state;
