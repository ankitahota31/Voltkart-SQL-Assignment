create database Voltkart 
GO
-- database for voltkart
-- alter schema of user(ankita)
alter user [ankita]
with default_schema= dbo
Go
-- alter schema of existing table (dbo to stg)
alter schema dbo
transfer stg.fact_orders
Go

use Voltkart
Go

-- to check if all tables are present
select 'dim_category' as table_name, count(*)  as total_rows from dim_category
union all select 'dim_customer', count(*) from dim_customer
union all select 'fact_orders', count(*) from fact_orders
UNION ALL SELECT 'fact_order_items',    COUNT(*) FROM fact_order_items
UNION ALL SELECT 'dim_employee',        COUNT(*) FROM dim_employee
UNION ALL SELECT 'dim_product',         COUNT(*) FROM dim_product
UNION ALL SELECT 'stg_orders_incr',     COUNT(*) FROM stg_orders_incr
UNION ALL SELECT 'cdc_product_changes', COUNT(*) FROM cdc_product_changes
Go


-- Q1:top 20 order values by value
select top 20 o.order_id, 
o.order_date,
c.customer_name,
e.employee_name as sales_rep_name,
o.order_total
from dbo.fact_orders as o

join dim_employee as e 
on e.employee_id=o.sales_rep_id

join dbo.dim_customer as c 
on c.customer_id=o.customer_id

where o.order_status='completed'
order by o.order_total desc;
Go










