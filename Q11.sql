-- Q11:For each customer, find the longest run of consecutive calendar months in which they placed at least one completed order
with customermonths as
(
select distinct customer_id, datefromparts(year(order_date), month(order_date), 1) as order_month
from dbo.fact_orders
where order_status = 'completed'
),
customerranking as
(
select customer_id, order_month, row_number() over(partition by customer_id order by order_month) as month_number
from customermonths
),
streaks as
(
select customer_id, datediff(month, '20000101', order_month) - month_number as streak_group
from customerranking
),
streaklengths as
(
select customer_id, streak_group, count(*) as streak_months
from streaks
group by customer_id, streak_group
)
select c.customer_id, c.customer_name, max(coalesce(sl.streak_months, 0)) as longest_streak_months
from dbo.dim_customer as c
left join streaklengths as sl on c.customer_id = sl.customer_id
group by c.customer_id, c.customer_name
order by longest_streak_months desc;