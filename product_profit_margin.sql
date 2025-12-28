/*
5. Product Profit Margin
Calculate the profit margin for much product (difference between price and cost of goods sold)
*/

select * from products;
select * from orders ;
select * from order_items ;

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