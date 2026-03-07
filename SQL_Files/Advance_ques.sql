use store
 ----Q1 Calculate the moving average of order values for each customer over their order history
select * from 
(select customers as Sample_customer, order_date, round(avg(per_order_revenue) over(partition by customers order by order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),2) as moving_avg from
(select c.customer_unique_id as customers, ot.order_purchase_date as order_date ,ov.total_value as per_order_revenue from order_item oi join order_value ov on oi.order_id=ov.order_id join orders ot on oi.order_id=ot.order_id join customers c on ot.customer_id=c.customer_id group by oi.order_id, c.customer_unique_id, ot.order_purchase_date order by customers, order_date asc) as base) as base2 where Sample_customer='8d50f5eadf50201ccdcedfb9e2ac8455'

----Q2 Calculate the cumulative sales per month for each year
select order_year,order_month, (sum(sale) over(partition by order_year order by order_year,order_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) as moving_total from
(select year(ot.order_purchase_date) as order_year,month(ot.order_purchase_date) as order_month,sum(ov.total_value) as Sale from orders ot join order_value ov on ot.order_id=ov.order_id group by order_year,order_month order by order_year asc,order_month asc) as base limit 10

----Q3 Calculate the year-over-year growth rate of total sales.
select yearly_order,yearly_sale,concat(round((yearly_sale-lag(yearly_sale) over(order by yearly_order))/lag(yearly_sale) over(order by yearly_order)*100,2),'%') as yoy_growth_percent from
(select yearly_order, sum(total_sale) as yearly_sale from 
(select year(order_purchase_date) as yearly_order, ov.total_value as total_sale from orders ot join order_value ov on ot.order_id=ov.order_id group by yearly_order, ot.order_id, ov.total_value) as base group by yearly_order) as base


----Q4 Calculate the retention rate of customers, defined as the percentage of customers who make another purchase within 6 months of their first purchase.

WITH first_purchase AS (
    SELECT 
        c.customer_unique_id,
        MIN(o.order_purchase_date) AS first_purchase_date
    FROM orders o
    JOIN customers c 
        ON o.customer_id = c.customer_id
    WHERE o.order_status NOT IN ('canceled','unavailable')
    GROUP BY c.customer_unique_id
),

retained_customers AS (
    SELECT DISTINCT
        fp.customer_unique_id
    FROM first_purchase fp
    JOIN orders o
        ON o.order_purchase_date > fp.first_purchase_date
        AND o.order_purchase_date <= DATE_ADD(fp.first_purchase_date, INTERVAL 180 DAY)
    JOIN customers c
        ON o.customer_id = c.customer_id
        AND c.customer_unique_id = fp.customer_unique_id
    WHERE o.order_status NOT IN ('canceled','unavailable')
)

SELECT (COUNT(*)/(select count(distinct customer_unique_id) from customers))*100 AS retained_customers
FROM retained_customers;




----Q5 Identify the top 3 customers who spent the most money in each year.
select year_list,customers as top_3_customer from
(select *, (dense_rank() over(partition by year_list order by total_spent desc)) as customer_ranking from 
(select Year(ot.order_purchase_date) as year_list,c.customer_unique_id as customers,sum(ov.total_value) as total_spent from orders ot join order_value ov on ot.order_id=ov.order_id join customers c on ot.customer_id=c.customer_id group by year_list, customers) as base) as base1 where customer_ranking<=3 order by year_list, customer_ranking


WITH first_purchase AS (
    SELECT 
        c.customer_unique_id,
        MIN(o.order_purchase_date) AS first_purchase_date
    FROM orders o
    JOIN customers c 
        ON o.customer_id = c.customer_id
    WHERE o.order_status NOT IN ('canceled','unavailable')
    GROUP BY c.customer_unique_id
),

retained_customers AS (
    SELECT DISTINCT
        fp.customer_unique_id
    FROM first_purchase fp
    JOIN orders o
        ON o.order_purchase_date > fp.first_purchase_date
        AND o.order_purchase_date <= DATE_ADD(fp.first_purchase_date, INTERVAL 180 DAY)
    JOIN customers c
        ON o.customer_id = c.customer_id
        AND c.customer_unique_id = fp.customer_unique_id
    WHERE o.order_status NOT IN ('canceled','unavailable')
)

SELECT COUNT(*) AS retained_customers
FROM retained_customers;






