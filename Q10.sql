--Q10.Query optimisation. Original query with statistics 
SET STATISTICS IO ON;
SET STATISTICS TIME ON;


   SELECT o.customer_id, COUNT(*) AS orders_2024,
           (SELECT SUM(oi.line_amount)
              FROM fact_order_items oi
              JOIN fact_orders o2 ON o2.order_id = oi.order_id
             WHERE o2.customer_id = o.customer_id) AS lifetime_value
    FROM fact_orders o
    WHERE YEAR(o.order_date) = 2024
    GROUP BY o.customer_id;

--new query with index and optimisation
CREATE NONCLUSTERED INDEX IX_fact_orders_order_date
ON dbo.fact_orders(order_date)
INCLUDE(customer_id);

CREATE NONCLUSTERED INDEX IX_fact_order_items_order
ON dbo.fact_order_items(order_id)
INCLUDE(line_amount);

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

WITH Orders2024 AS
(
    SELECT
        customer_id,
        COUNT(*) AS orders_2024
    FROM dbo.fact_orders
    WHERE order_date >= '20240101'
      AND order_date < '20250101'
    GROUP BY customer_id
),
LifetimeRevenue AS
(
    SELECT
        o.customer_id,
        SUM(oi.line_amount) AS lifetime_value
    FROM dbo.fact_orders o
    INNER JOIN dbo.fact_order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.customer_id
)
SELECT
    o.customer_id,
    o.orders_2024,
    lr.lifetime_value
FROM Orders2024 o
LEFT JOIN LifetimeRevenue lr
    ON o.customer_id = lr.customer_id;
