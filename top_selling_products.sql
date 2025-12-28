--EDA

SELECT * FROM category;
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM order_items;
SELECT * FROM orders;
SELECT * FROM payments;
SELECT * FROM shipping;
SELECT * FROM sellers;
SELECT * FROM inventory;

SELECT DISTINCT payment_status
FROM payments ;

SELECT *
FROM shipping
WHERE return_date IS NOT NULL;

SELECT *
FROM shipping
WHERE return_date IS NULL;

--6747
SELECT *
FROM orders
where order_id = 6747 ;

SELECT *
FROM payments
where order_id = 6747 ;

---------

/*
1.Top Selling Products
Top 10 Products by total sales value.*/

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
