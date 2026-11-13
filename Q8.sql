
--Q8: Perform an incremental load into fact_orders: 
--declare variables &table for action and count before load
declare @rows_before int;
declare @rows_after int;

declare @mergeaudit table
( merge_action nvarchar(10),
  orderid int
)
-- count before load
select @rows_before=count(*) from dbo.fact_orders;

--incremental load into fact_orders
merge into dbo.fact_orders as tgt
using dbo.stg_orders_incr as stg
on tgt.order_id=stg.order_id

when matched and
( isnull(tgt.order_status,'')<> isnull(stg.order_status,'')
or isnull(tgt.order_total,0)<> isnull(stg.order_total,0)
)
then update set
tgt.order_status= stg.order_status,
tgt.order_total=stg.order_total

when not matched by target then
insert (order_id, order_date,customer_id,sales_rep_id,order_status, order_total)
values(stg.order_id, stg.order_date, stg.customer_id, stg.sales_rep_id, stg.order_status, stg.order_total)

output
$action,inserted.order_id
into @mergeaudit (merge_action, orderid);

--rows after
select @rows_after=count(*) from dbo.fact_orders;

--verify row counts before & after
select @rows_before as rows_before, @rows_after as rows_after, 
@rows_after-@rows_before as rows_processed;

--verify how many records were updated vs inserted
select merge_action,count(*) from @mergeaudit
group by merge_action;

--sample of updated records

select o.order_id,
o.order_date,
o.order_status,
o.order_total,
m.merge_action
from
dbo.fact_orders as o join @mergeaudit as m
on o.order_id=m.orderid where m.merge_action='update';

