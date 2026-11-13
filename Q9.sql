--Q9: change feed merge for products
--table variable
declare @change_audit table
( action_performed nvarchar(10),
old_product_id int,
new_product_id int)

--change feed merge
merge into dbo.dim_product as tgt
using dbo.cdc_product_changes as src
on tgt.product_id=src.product_id

when matched and src.operation='U'
then update set
tgt.product_name=src.product_name,
tgt.category_id=src.category_id,
tgt.unit_price=src.unit_price,
tgt.unit_cost=src.unit_cost,
tgt.launch_date=src.launch_date


when matched and src.operation='D'
then delete

when not matched by target and src.operation='I'
then insert(product_id,product_name,category_id,unit_price,unit_cost,launch_date)
values(src.product_id, src.product_name,src.category_id,src.unit_price,src.unit_cost,src.launch_date)


output
$action, deleted.product_id,inserted.product_id
into @change_audit(action_performed, old_product_id,new_product_id);


--
with change_count as
(select case
        when operation='U' then 'Products_updated'
		when operation='D' then 'Products_ deleted'
		when operation='I' then 'Products_added'
		end as operation
from dbo.cdc_product_changes
)

select count(*) as count,operation from change_count
group by operation
