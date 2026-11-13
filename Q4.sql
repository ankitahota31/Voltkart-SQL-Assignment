/*Q4: monthly completed revenue with a cumulative running total and the month-over-month % 
change.*/
with MonthlyTotal as
(
	select format(order_date,'yyyy-MM') as Order_month,sum(order_total) as Monthly_revenue from dbo.fact_orders
	where order_status='completed'
	group by format(order_date,'yyyy-MM')
),
MonthlyRunningTotal as
(
	select order_month, Monthly_revenue,
	sum(Monthly_revenue) over(
	order by order_month
	rows between unbounded preceding and current row
	)as Running_total,
	(
		(Monthly_revenue-lag(monthly_revenue,1)over
		(order by order_month))* 100.0
		/
		nullif(
			lag(monthly_revenue,1)over
			(order by order_month),0)
	)as mom_pct_change
from MonthlyTotal
)
select order_month, monthly_revenue,Running_total,mom_pct_change
from MonthlyRunningTotal order by Order_month