--top_products
CREATE OR REPLACE VIEW vw_top_products AS
SELECT
    p.product_id,
    p.product_name,
    COUNT(o.order_id) AS total_orders,
    SUM(oi.quantity * oi.price_per_unit) AS total_sales
FROM order_items oi
JOIN products p 
    ON oi.product_id = p.product_id
JOIN orders o 
    ON oi.order_id = o.order_id
GROUP BY  p.product_id, p.product_name
ORDER BY total_sales DESC
LIMIT 10;

--revenue_by_category
CREATE OR REPLACE VIEW vw_revenue_by_category AS
SELECT
    c.category_id,
    c.category_name,
    ROUND(CAST(SUM(oi.quantity * oi.price_per_unit) AS numeric), 2) AS total_sales_by_category,
    ROUND(
        CAST(
            SUM(oi.quantity * oi.price_per_unit) * 100.0 /
            (SELECT SUM(quantity * price_per_unit) FROM order_items)
        AS numeric), 2
    ) AS percent_contribution
FROM category c
JOIN products p 
    ON c.category_id = p.category_id
JOIN order_items oi
    ON oi.product_id = p.product_id
GROUP BY
    c.category_id, c.category_name
ORDER BY
    total_sales_by_category DESC;

select * from orders ;
select max(order_date) as last_date from orders ;

--monthly_trend
CREATE OR REPLACE VIEW vw_monthly_trend AS
With monthly_sales as (
Select
    DATE_TRUNC('month', o.order_date) As month_start,
    SUM(oi.quantity * oi.price_per_unit) As current_month_sales
    FROM orders o
    JOIN order_items oi 
    ON o.order_id = oi.order_id
    GROUP BY month_start),

sales_with_prev as (
    SELECT 
        month_start,
        current_month_sales,
        LAG(current_month_sales) Over (ORDER BY month_start) as last_month_sales
    FROM monthly_sales
),

growth_calc AS (
    SELECT 
        month_start,
        current_month_sales,
        last_month_sales,
        ROUND(( (
                (current_month_sales - last_month_sales)
                / NULLIF(last_month_sales, 0)
              ) * 100)::numeric, 2
        ) as mom_growth_percent
    from sales_with_prev )

Select * FROM growth_calc
Order by month_start;


--best_category_by_state
CREATE OR REPLACE VIEW vw_best_category_by_state AS
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

--profit_margin
CREATE OR REPLACE VIEW vw_profit_margin AS
With profit_margin as (
select P.product_id,
     P.product_name,
	 sum(Oi.quantity * Oi. price_per_unit) as total_revenue,
	 sum(P.COGS * Oi.quantity) as total_cost,
	 sum(Oi.quantity * Oi. price_per_unit) - sum(P.COGS * Oi.quantity) as profit,
	 (sum(Oi.quantity * Oi. price_per_unit) - sum(P.COGS * Oi.quantity)/
	  sum(Oi.quantity * Oi. price_per_unit)*100 ) as margin
from Products P
JOIN order_items Oi
ON P.product_id = Oi.product_id
JOIN orders O
ON O.order_id = Oi.order_id
group by P.product_id, P.product_name),

rank_products as ( select*,
Dense_Rank() over ( order by margin DESC ) as rank 
from profit_margin )

select * from rank_products
;

--pareto_analysis
CREATE OR REPLACE VIEW vw_pareto AS
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


--mom_growth
CREATE OR REPLACE VIEW vw_mom_growth AS
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

--margin_bucket
CREATE OR REPLACE VIEW vw_margin_bucket AS
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




