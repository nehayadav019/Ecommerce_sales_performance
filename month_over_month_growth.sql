/*
7.Month-over-Month (MoM) Growth
Calculate monthly sales performance and compare each month against the previous month.
Shows trend direction (increase or decrease) and helps identify seasonal or monthly patterns.*/


WITH ms AS (
    SELECT
        DATE_TRUNC('month', o.order_date)::date AS month_start,
        SUM(oi.quantity * oi.price_per_unit) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY month_start
)
SELECT
    month_start,
    revenue,
    ROUND((
        (revenue - LAG(revenue) OVER (ORDER BY month_start))
        / NULLIF(LAG(revenue) OVER (ORDER BY month_start), 0) * 100)::numeric
        ,2
    ) AS mom_growth_percent
FROM ms
ORDER BY month_start;