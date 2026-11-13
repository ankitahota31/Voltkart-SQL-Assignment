--Q2:customers who registered but never bought
select c.customer_id,c.customer_name
from dbo.dim_customer as c
where not exists( 
	select 1 from fact_orders as o
	where o.customer_id=c.customer_id
)
GO
