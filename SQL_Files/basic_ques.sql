use store
----Q1 List all unique cities where customers are located**/
SELECT
    customer_city as Top10_city
FROM
    customers group by customer_city order by count(customer_city) desc limit 10

----Q2 Count the number of orders placed in 2017**/
SELECT 
    COUNT(order_id) as Orders_2017
FROM
    orders_table
WHERE
    YEAR(order_purchase_date) = '2017'

----Q3 Find the total sales per category. 
SELECT 
    p.product_category AS category,
    ROUND(SUM(a.product_revenue), 2) AS rev
FROM
    (SELECT 
        oi.order_id,
            oi.product_id,
            oi.price,
            ((oi.price / op.price_value) * ov.total_value) AS product_revenue
    FROM
        order_item oi
    JOIN order_value ov ON oi.order_id = ov.order_id
    JOIN (SELECT 
        order_id, ROUND(SUM(price), 2) AS price_value
    FROM
        order_item
    GROUP BY order_id) AS op ON oi.order_id = op.order_id) AS a
        JOIN
    products p ON a.product_id = p.product_id
GROUP BY p.product_category
ORDER BY rev DESC
LIMIT 10

----Q4 Calculate the percentage of orders that were paid in installments.
SELECT 
    round(COUNT(DISTINCT (CASE
            WHEN payment_installments > 1 THEN order_id
        END)) / COUNT(DISTINCT (order_id)) * 100,1) AS installment_percent
FROM
    payments
----Q5 Count the number of customers from each state
SELECT 
    customer_state AS Top10_state,
    COUNT(distinct customer_unique_id) AS total_customers
FROM
    customers c join orders ot on c.customer_id=ot.customer_id where ot.order_status not in ('Canceled','Unavailable')
GROUP BY customer_state order by total_customers desc limit 10



SELECT 
    p.product_category AS category,
    ROUND(SUM(oi.price), 2) AS total_sales
FROM order_item oi
JOIN products p 
    ON oi.product_id = p.product_id
GROUP BY p.product_category
ORDER BY total_sales DESC
LIMIT 10;