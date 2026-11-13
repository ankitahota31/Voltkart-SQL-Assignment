
/*Q5: Split customers into
four quartiles by lifetime completed spend, and for each quartile report how many 
customers fall in it and their average spend*/
with CustomerLifeSpend as
(
select c.customer_id,sum(o.order_total) as lifetime_spend
from dbo.dim_customer as c 
join
dbo.fact_orders as o
on c.customer_id=o.customer_id
and o.order_status='completed'
group by c.customer_id
),
SpendQuartiles as
(
select lifetime_spend,NTILE(4) over
(order by lifetime_spend desc) as spend_quartile
from CustomerLifeSpend
)
select AVG(lifetime_spend) as avg_lifetime_spend,spend_quartile,
count(*) as customer_count from SpendQuartiles
group by spend_quartile
go