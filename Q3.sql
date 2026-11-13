--Q3:For every category, return the top 3 products by completed revenue.
with productRevenue as
( 
select c.category_name,p.product_name,
sum(oi.line_amount) as Total_revenue
from dbo.fact_order_items as oi
join dbo.fact_orders as o
on oi.order_id=o.order_id
join
dbo.dim_product as p
on p.product_id=oi.product_id
join
dbo.dim_category as c
on c.category_id=p.category_id
where o.order_status='completed'
group by c.category_name,p.product_name

),
ProductRanking as
(
select category_name,
product_name,
Total_revenue,
RANK() over (
partition by category_name
order by Total_revenue desc) as Revenue_rank
from productRevenue
)
select category_name,
product_name,
Total_revenue,
Revenue_rank
from ProductRanking
where Revenue_rank<=3
order by category_name,product_name,Revenue_rank desc
GO
