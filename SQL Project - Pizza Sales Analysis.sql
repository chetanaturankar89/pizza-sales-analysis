/*
Problem Statement:
A pizza delivery company wants to optimize its operations and increase profitability by leveraging historical order data.
The company has provided datasets containing order details, pizza information, and category classifications. 
Your task is to perform a thorough SQL-based analysis to answer key business questions, 
ranging from basic sales metrics to advanced revenue insights.
*/

-- Creating database
create database pizzahut;

-- use DB 
use pizzahut;

-- Tables has been created in another script 
-- Checking tables 
select * from pizzas;
select * from pizza_types;
select * from order_details;
select * from orders ;

-- ******************************************************Basic Questions****************************************************************************

-- 1. Retrieve the total number of orders placed.

SELECT 
    COUNT(*) total_orders
FROM
    orders;
    
-- The total number of orders placed  : 21350 

-- --------------------------------------------------------------------------------------------------------------------------------------

-- 2. Calculate the total revenue generated from pizza sales.
-- Revenue = Price x Quantity. 

SELECT 
    round(SUM(price * quantity),2) total_revenue
FROM
    pizzas pz
        INNER JOIN
    order_details od ON pz.pizza_id = od.pizza_id
;  
-- Total revenue generated from pizza sales. 817860.05

-- --------------------------------------------------------------------------------------------------------------------------------------

-- 3. Identify the highest-priced pizza.

SELECT 
    name, price AS highest_priced_pizza
FROM
    pizzas pz
         JOIN
    pizza_types pt ON pz.pizza_type_id = pt.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- The Greek Pizza is highest-priced pizza with price 35.95

-- --------------------------------------------------------------------------------------------------------------------------------------

-- 4. Identify the most common pizza size ordered.

SELECT 
    size, COUNT(od.order_details_id) order_count 
FROM
    pizzas pz 
join 
    order_details od 
on pz.pizza_id = od.pizza_id
GROUP BY pz.size
order by order_count desc limit 1;

-- size L pizza ordered a lot with order_count --> 18526

-- --------------------------------------------------------------------------------------------------------------------------------------

-- 5. List the top 5 most ordered pizza types along with their quantities.
-- select * from order_details; 
-- top 5 -- limit 5
-- most ordered pizza type -- pizza type id -- select * from pizzas

SELECT 
    name Pizza_Name, SUM(od.quantity) sum_of_pizza_quantity
FROM
    pizza_types pt
        JOIN
    pizzas pz ON pz.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = pz.pizza_id
GROUP BY pt.name
ORDER BY sum_of_pizza_quantity DESC
LIMIT 5;

-- Below are the top 5 most ordered pizza types along with their quantities.
/*
+-----------------------------+------------------------+
| Pizza_Name                 | sum_of_pizza_quantity  |
+-----------------------------+------------------------+
| The Classic Deluxe Pizza   | 2453                   |
| The Barbecue Chicken Pizza | 2432                   |
| The Hawaiian Pizza         | 2422                   |
| The Pepperoni Pizza        | 2418                   |
| The Thai Chicken Pizza     | 2371                   |
+-----------------------------+------------------------+
*/

-- --------------------------------------------------------------------------------------------------------------------------------------

-- *******************************************Intermediate Questions*********************************************************************

-- 1. Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
     category , SUM(od.quantity) total_quantity
FROM
    pizza_types pt
        JOIN
    pizzas pz ON pz.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = pz.pizza_id
GROUP BY category
ORDER BY total_quantity desc;

-- total quantity of each pizza category ordered.
/*
+----------+----------------+
| category | total_quantity |
+----------+----------------+
| Classic  | 14888          |
| Supreme  | 11987          |
| Veggie   | 11649          |
| Chicken  | 11050          |
+----------+----------------+
*/

-- --------------------------------------------------------------------------------------------------------------------------------------

-- 2. Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(time) hour_of_time, COUNT(order_id) count_of_ord_id
FROM
    orders
GROUP BY hour_of_time
order by hour_of_time;

-- +--------------+------------------+
-- | hour_of_time | count_of_ord_id  |
-- +--------------+------------------+
-- |      9       |        1         |
-- |     10       |        8         |
-- |     11       |      1231        |
-- |     12       |      2520        |
-- |     13       |      2455        |
-- |     14       |      1472        |
-- |     15       |      1468        |
-- |     16       |      1920        |
-- |     17       |      2336        |
-- |     18       |      2399        |
-- |     19       |      2009        |
-- |     20       |      1642        |
-- |     21       |      1198        |
-- |     22       |       663        |
-- |     23       |        28        |
-- +--------------+------------------+

-- --------------------------------------------------------------------------------------------------------------------------------------

-- 3. Find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name) distribution_of_pizzas
FROM
    pizza_types
GROUP BY category;

-- +----------+------------------------+
-- | category | distribution_of_pizzas |
-- +----------+------------------------+
-- | Chicken  |           6            |
-- | Classic  |           8            |
-- | Supreme  |           9            |
-- | Veggie   |           9            |
-- +----------+------------------------+

-- --------------------------------------------------------------------------------------------------------------------------------------

-- 4.Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT round(avg(quantity),0) avg_pizza
FROM (
    SELECT 
        date, 
        SUM(quantity) AS quantity
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.date
) AS ord_quantity;

-- The average number of pizzas ordered per day is 138

-- --------------------------------------------------------------------------------------------------------------------------------------

-- 5. Determine the top 3 most ordered pizza types based on revenue.
-- revenue = quantity * price

SELECT 
    name, SUM(od.quantity * pz.price) revenue
FROM
    pizza_types pt
        JOIN
    pizzas pz ON pt.pizza_type_id = pz.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = pz.pizza_id
GROUP BY name
ORDER BY revenue DESC
LIMIT 3
;

-- The top 3 most ordered pizza types based on revenue.
-- +------------------------------+----------+
-- |           name              | revenue  |
-- +------------------------------+----------+
-- | The Thai Chicken Pizza      | 43434.25 |
-- | The Barbecue Chicken Pizza  | 42768.00 |
-- | The California Chicken Pizza| 41409.50 |
-- +------------------------------+----------+


-- ***********************************************Advanced Questions*************************************************

-- 1. Calculate the percentage contribution of each pizza type to total revenue.
-- using SUM(...) OVER () window function

SELECT 
    pt.category, 
    ROUND(
        SUM(od.quantity * pz.price) * 100.0 / 
        SUM(SUM(od.quantity * pz.price)) OVER (), 
        2
    ) AS percentage_revenue
FROM 
    pizza_types pt
JOIN 
    pizzas pz ON pt.pizza_type_id = pz.pizza_type_id
JOIN 
    order_details od ON pz.pizza_id = od.pizza_id
GROUP BY 
    pt.category
ORDER BY 
    percentage_revenue DESC;

-- This query calculates the percentage contribution of each pizza category to the total revenue, ordered from highest to lowest.

/*
+----------+---------------------+
| category | percentage_revenue |
+----------+---------------------+
| Classic  | 26.91              |
| Supreme  | 25.46              |
| Chicken  | 23.96              |
| Veggie   | 23.68              |
+----------+---------------------+
*/

-- --------------------------------------------------------------------------------------------------------------------------------------

-- 2. Analyze the cumulative revenue generated over time.
-- cumulative -- genearting everyday and increasing 

WITH daily_revenue AS (
    SELECT 
        o.date,
        SUM(od.quantity * pz.price) AS daily_total
    FROM order_details od
    JOIN pizzas pz ON od.pizza_id = pz.pizza_id
    JOIN orders o ON o.order_id = od.order_id
    GROUP BY o.date
)
SELECT 
    date,
    daily_total,
    SUM(daily_total) OVER (ORDER BY date) AS cumulative_revenue
FROM daily_revenue;

-- --------------------------------------------------------------------------------------------------------------------------------------

-- -- Calculate daily and cumulative revenue over time using window functions.

-- 3. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

WITH pizza_category AS (
    SELECT 
        pt.category,
        pt.name,
        SUM(od.quantity * pz.price) AS revenue,
        RANK() OVER (
            PARTITION BY pt.category 
            ORDER BY SUM(od.quantity * pz.price) DESC
        ) AS rnk
    FROM pizza_types pt 
    JOIN pizzas pz ON pt.pizza_type_id = pz.pizza_type_id
    JOIN order_details od ON pz.pizza_id = od.pizza_id
    GROUP BY pt.category, pt.name
)

SELECT * 
FROM pizza_category 
WHERE rnk <= 3;


/*
Top 3 most revenue-generating pizza types for each category:

| category | name                          | revenue   | rnk |
|----------|-------------------------------|-----------|-----|
| Chicken  | The Thai Chicken Pizza        | 43434.25  | 1   |
| Chicken  | The Barbecue Chicken Pizza    | 42768.00  | 2   |
| Chicken  | The California Chicken Pizza  | 41409.50  | 3   |
| Classic  | The Classic Deluxe Pizza      | 38180.50  | 1   |
| Classic  | The Hawaiian Pizza            | 32273.25  | 2   |
| Classic  | The Pepperoni Pizza           | 30161.75  | 3   |
| Supreme  | The Spicy Italian Pizza       | 34831.25  | 1   |
| Supreme  | T

-- --------------------------------------------------------------------------------------------------------------------------------------

/* Pizza Sales Analysis Project (SQL)

Summary:
Analyzed a pizza sales dataset using SQL to uncover key business insights. 
Covered end-to-end reporting from basic metrics to advanced analytics using joins, aggregation, window functions, and CTEs.

Key Highlights:

Calculated total orders and total revenue from pizza sales.
Identified highest-priced pizza and most commonly ordered pizza size.
Determined top 5 most ordered pizza types by quantity.
Performed category-wise and hourly order distribution analysis.
Calculated daily revenue and cumulative revenue trends using window functions.
Ranked and retrieved top 3 revenue-generating pizza types for each category.

Skills Used: SQL, Window Functions, CTEs, Aggregation, Ranking
 */