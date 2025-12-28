/* 
3.Monthly Sales Trend
Query Monthly Total Sales Over the Past year.
*/	 
	 
select * from orders ;
select max(order_date) as last_date from orders ;

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