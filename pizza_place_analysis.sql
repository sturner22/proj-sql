/* This file contains queries and analysis observations related to a fictional pizza restaurant 
dataset. Observations and related queries for the analysis questions below are included throughout 
this file in comments. 

pizza_place_sales analysis questions: 

1. How many customers do we have each day? Are there any peak hours?

2. How many pizzas are typically in an order? Do we have any best sellers?

3. How much money did we make this year? Can we identify any seasonality in the sales?

4. Are there any pizzas we should take off the menu, or any promotions we could leverage? 
*/

/* Question 1. 
- The data to answer this question is in the orders table. 
1. Count order_id and group by date 
-At a glance, most days have total orders in the 40s, 50s, and 60s. There is a spike on some holidays: July 4, 
Thanksgiving and the day after Thanksgiving, and seemingly random, October 15. 
2. Calculate total orders by month
- July had the highest count of orders. 
3. Calculate average orders by day of week 
 -Friday had the highest count of orders, on average, and Sunday had the lowest. 
4. Calculate average orders by hour of day 
- Peak hours are during lunchtime, between 12pm to 2 pm, and then again (slightly lower) during dinner time, between 
5pm to 7 pm. 
Insights:
- The overall average daily number of orders was 59.63. 
- Fridays were the busiest on average, with 70.76 orders (average) and Sundays were the least busy, with 50.46 orders (average)
- Typical lunch and dinner hours brought in the most orders on average. The busiest hours were between 12 pm and 2 pm, 
and  again between 5 pm and 7 pm. 
*/

SELECT * FROM orders;

-- Average orders per day, overall:

SELECT
	COUNT(DISTINCT order_id)/COUNT(DISTINCT date) AS average_daily_orders
FROM orders;

-- Total orders by date: 

SELECT
	date,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY date;

-- Total orders by month: 

CREATE TEMPORARY TABLE total_orders_by_month
SELECT
	MONTH(date) AS month,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY 1;

SELECT * FROM total_orders_by_month;

-- Average number of orders, by day of week:

CREATE TEMPORARY TABLE avg_orders_by_weekday
SELECT 
	ROUND(COUNT(DISTINCT CASE WHEN day_of_week = 0 THEN order_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN day_of_week = 0 THEN date ELSE NULL END),0) AS avg_monday_orders,
	ROUND(COUNT(DISTINCT CASE WHEN day_of_week = 1 THEN order_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN day_of_week = 1 THEN date ELSE NULL END),0) AS avg_tuesday_orders,
	ROUND(COUNT(DISTINCT CASE WHEN day_of_week = 2 THEN order_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN day_of_week = 2 THEN date ELSE NULL END),0) AS avg_wednesday_orders,
	ROUND(COUNT(DISTINCT CASE WHEN day_of_week = 3 THEN order_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN day_of_week = 3 THEN date ELSE NULL END),0) AS avg_thursday_orders,
	ROUND(COUNT(DISTINCT CASE WHEN day_of_week = 4 THEN order_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN day_of_week = 4 THEN date ELSE NULL END),0) AS avg_friday_orders,
	ROUND(COUNT(DISTINCT CASE WHEN day_of_week = 5 THEN order_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN day_of_week = 5 THEN date ELSE NULL END),0) AS avg_saturday_orders,
	ROUND(COUNT(DISTINCT CASE WHEN day_of_week = 6 THEN order_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN day_of_week = 6 THEN date ELSE NULL END),0) AS avg_sunday_orders
FROM 
(
SELECT 
	order_id,
    date,
    WEEKDAY(date) AS day_of_week
FROM orders) week_days;

SELECT * FROM avg_orders_by_weekday;


-- Checking out the earliest and latest orders. Orders were accepted between 9:52 am and 11:05 pm. 

SELECT 
	MAX(time) AS lastest_order,
    MIN(time) AS earliest_order
FROM orders;

-- Average count of orders by time (hour) of day: 

CREATE TEMPORARY TABLE orders_by_time_of_day
SELECT 
	hour_of_day,
    ROUND(COUNT(DISTINCT order_id)/COUNT(DISTINCT date),2) AS avg_orders
FROM 
(
SELECT 
	order_id,
    date,
    HOUR(time) AS hour_of_day
FROM orders) hours
GROUP BY 1
ORDER BY 1;

SELECT * FROM orders_by_time_of_day;

/* Since the average orders for the 9 am and 10 am hour were both 1.00, I QA'd this with the below queries 
and found that only one order was placed in the 9 am hour (it was almost 10 am, perhaps the pizza place opens at 10 am 
and received an order early) and there were 8 orders placed during the am hour, on 8 distinct dates */

SELECT
date,
COUNT(order_id) 
FROM orders
WHERE hour(time) = 9
GROUP BY 1;

SELECT
date,
COUNT(order_id) 
FROM orders
WHERE hour(time) = 10
GROUP BY 1;

/* Question 2: How many pizzas are typically in an order? Any best sellers?
- The data to answer this question exists in multiple tables: order details, pizzas, and pizza_types. 
Insights: The average number of pizzas per order was 2. The most pizzas in single order was 28!
The best selling pizza was "the big meat", size small, with 1,914 sales. The type of pizza that sold the 
least was "the greek", size XXL, with only 28 sales. Note, these totals do factor in size. When the size of the pizza was not
included, the "classic_dlx" pizza type was the best seller, with 2,453 sales, and the "brie_carre" had the least sales with 490. 
Other thoughts: it would be interesting to pull in the list of ingredients, and also to see what size of pizza is most 
commonly ordered. 
* Update: I also counted the total pizza orders and grouped by size. Large is the most popular size, followed by medium. 
Interestingly, a total of 28 XXL pizzas were sold, and as determined by the first query that took into account pizza type
and size, all of those were the greek pizza. 
*/

-- creating temporary table to count how many pizzas are in each distinct order. 

CREATE TEMPORARY TABLE pizzas_per_order
SELECT
	order_id,
	SUM(distinct_pizza*quantity) AS pizzas_in_order
FROM
(
SELECT
	1 AS distinct_pizza,
    order_details_id,
    order_id,
    pizza_id,
    quantity
FROM order_details) distinct_pizza_table
GROUP BY order_id
ORDER BY pizzas_in_order DESC;

SELECT * FROM pizzas_per_order;

-- The average, max, and min pizzas in an order 

SELECT
	AVG(pizzas_in_order) AS average_pizzas,
    MAX(pizzas_in_order) AS max_pizzas,
    MIN(pizzas_in_order) AS min_pizzas
FROM pizzas_per_order;

-- total number of each pizza sold. This query includes both the type of pizza and the size
-- *Update: I turned the below query into a temporary table and brought in the total revenue 

CREATE TEMPORARY TABLE pizza_revenues
SELECT
	pizza_id,
    SUM(which_pizza*quantity) AS total_sold
FROM 
(

SELECT 
	1 AS which_pizza,
    pizza_id,
    quantity
FROM order_details) which_pizza_table
GROUP BY pizza_id
ORDER BY total_sold DESC;

SELECT * FROM pizza_revenues;

CREATE TEMPORARY TABLE pizza_orders_revenue
SELECT
	pizzas.pizza_type_id,
	pizza_revenues.pizza_id,
    pizza_revenues.total_sold,
    pizza_revenues.total_sold*pizzas.price AS total_revenue
FROM pizza_revenues
	LEFT JOIN pizzas
		ON pizza_revenues.pizza_id = pizzas.pizza_id
ORDER BY 3 DESC;

SELECT * FROM pizza_orders_revenue;


-- here is a count of total pizzas sold grouped by pizza_type_id, which includes all sizes for that pizza type. 

SELECT
	pizza_type_id,
    SUM(which_pizza*quantity) AS total_pizzas_ordered
FROM 
(
SELECT
	1 AS which_pizza,
    order_details.pizza_id,
    order_details.quantity,
    pizzas.pizza_type_id
FROM order_details
	LEFT JOIN pizzas
		ON order_details.pizza_id = pizzas.pizza_id) AS pizza_counts
GROUP BY pizza_type_id
ORDER BY 2 DESC;

-- I made the above query into a temporary table and pulled in the ingredients column from pizza_types

CREATE TEMPORARY TABLE popular_pizzas
SELECT
	pizza_type_id,
    SUM(which_pizza*quantity) AS total_pizzas_ordered
FROM 
(
SELECT
	1 AS which_pizza,
    order_details.pizza_id,
    order_details.quantity,
    pizzas.pizza_type_id
FROM order_details
	LEFT JOIN pizzas
		ON order_details.pizza_id = pizzas.pizza_id) AS pizza_counts
GROUP BY pizza_type_id
ORDER BY 2 DESC;

SELECT * FROM popular_pizzas;
SELECT * FROM pizza_types;

/* This query includes the ingredients for each pizza type, along with how many each sold. It's just 
an interesting additional bit of info */

DROP TABLE pizza_ingredients_categories; -- I ended up making several updates to this table and recreating it 

CREATE TEMPORARY TABLE pizza_ingredients_categories
SELECT
	pizza_types.category,
	popular_pizzas.pizza_type_id,
    pizza_types.pizza_name,
    popular_pizzas.total_pizzas_ordered,
    pizza_types.ingredients
FROM popular_pizzas
	LEFT JOIN pizza_types
		ON popular_pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY 4 DESC;

SELECT * FROM pizza_ingredients_categories;

-- which size of pizza is the most popular to order? The least? 

/* Joining order_details to pizzas, to pull in the size and use in GROUP BY clause in final query. We are joining both tables on 
a foreign key, but, the value in the size column is expected to repeat, so this is fine to do in this case. */

CREATE TEMPORARY TABLE pizza_size_counts
SELECT
	pizza_size,
    SUM(which_pizza*quantity) AS total_pizzas_ordered
FROM 
(
SELECT 
	1 AS which_pizza,
    pizzas.size AS pizza_size,
    order_details.pizza_id,
    order_details.quantity
FROM order_details
	LEFT JOIN pizzas 
		ON order_details.pizza_id = pizzas.pizza_id) AS pizza_sizes_table
GROUP BY 1
ORDER BY 2 DESC;

SELECT * FROM pizza_size_counts;

/* Checking to see if there are any pizzas on the menu that sold none at all. Every pizza_type sold, there were 
some sizes of certain types that did not sell. Note: change the first column to pizza_id to see which pizza type/size combos
sold none. */

SELECT
	pizzas.pizza_type_id,
    COUNT(order_details.order_id) AS total_orders
FROM pizzas
	LEFT JOIN order_details
		ON pizzas.pizza_id = order_details.pizza_id
GROUP BY 1
ORDER BY 2;

/* Question 3: How much money did we make this year, and is there any seasonality in the sales? 
- Insights: July had the highest sales revenue, and October had the lowest sales revenue. Fall months
had lower revenue, with the exception of November, which had the fourth highest revenue of all months. There 
is no clear pattern in terms of season; likely more than one year's worth of data will be needed to trend revenue
by month/season. In terms of hourly revenue, not surprisingly, the lunch time hours (12 pm to 2 pm) and the dinner time 
hours (5 pm to 7 pm) brought in the highest revenue. 
Total revenue for 2015: 817,860.05
*/

-- The following query contains two queries, and ends in  the total cost, grouped by order_id. 

SELECT -- this is the final query, which calculates the total cost for each order 
	order_id,
    SUM(total_quantity*price) AS order_total
FROM
(
SELECT -- this is the second query, which calculates the total quantity of each type of pizza per order 
	order_id,
    SUM(which_pizza*quantity) AS total_quantity,
    price
FROM
( 
SELECT -- This is the first query, to pull in price of the pizza and add a dummy column (1) to calculate the quantity 
    order_id,
    1 AS which_pizza,
    order_details.pizza_id,
    quantity,
    pizzas.price
FROM order_details
	LEFT JOIN pizzas
		ON order_details.pizza_id = pizzas.pizza_id) AS pizza_price_table -- query 1 table alias 
GROUP BY order_id, price) AS pizza_price_table_2 -- query 2 table alias 
GROUP BY 1;

/* Next I will turn the above query into a temporary table, and join it to the orders table to bring in the date
and time of the order. This will allow trending by different time and date functions (e.g. month, hour of day) to 
further analyze trends in sales. 
*/

CREATE TEMPORARY TABLE total_sales
SELECT 
	order_id,
    SUM(total_quantity*price) AS order_total
FROM
(
SELECT 
	order_id,
    SUM(which_pizza*quantity) AS total_quantity,
    price
FROM
( 
SELECT 
    order_id,
    1 AS which_pizza,
    order_details.pizza_id,
    quantity,
    pizzas.price
FROM order_details
	LEFT JOIN pizzas
		ON order_details.pizza_id = pizzas.pizza_id) AS pizza_price_table 
GROUP BY order_id, price) AS pizza_price_table_2 
GROUP BY 1;

SELECT * FROM total_sales;

-- create another orders table, which includes the total cost, date, and time, for each order_id 

CREATE TEMPORARY TABLE orders_v2
SELECT
	orders.order_id,
    total_sales.order_total,
    orders.date,
    orders.time
FROM orders
	INNER JOIN total_sales
		ON orders.order_id = total_sales.order_id;

SELECT * FROM orders_v2;

-- total revenue by month:

CREATE TEMPORARY TABLE revenue_by_month
SELECT 
	MONTH(date) AS month,
    ROUND(SUM(order_total), 2) AS total_revenue
FROM orders_v2
GROUP BY 1
ORDER BY 1;

SELECT * FROM revenue_by_month;

-- creating another table to include total revenue and total orders, grouped by month

SELECT 
	MONTH(date) AS month,
    SUM(order_total) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders_v2
GROUP BY 1;

-- total revenue by hour of the day: 

CREATE TEMPORARY TABLE revenue_by_hour
SELECT
	HOUR(time) AS hour_of_day,
    SUM(order_total) AS total_revenue
FROM orders_v2
GROUP BY 1
ORDER BY 1;

SELECT * FROM revenue_by_hour;

-- total revenue for 2015: 

SELECT
	SUM(order_total) AS total_2015_revenue
FROM orders_v2;

-- total revenue, grouped by pizza category

CREATE TEMPORARY TABLE revenue_by_category_prep
SELECT 
	order_details.order_id,
    pizzas.pizza_id,
    pizza_types.pizza_type_id,
    pizza_types.category,
    order_details.quantity,
    pizzas.price
FROM order_details
	LEFT JOIN pizzas 
		ON order_details.pizza_id = pizzas.pizza_id
	LEFT JOIN pizza_types
		ON pizzas.pizza_type_id = pizza_types.pizza_type_id;
        
SELECT * FROM revenue_by_category_prep;

CREATE TEMPORARY TABLE revenue_by_category
SELECT
	category,
    SUM(quantity*price) AS total_revenue
FROM revenue_by_category_prep
GROUP BY 1
ORDER BY 2 DESC;

SELECT * FROM revenue_by_category;

/* Do certain pizzas sell better during certain months? Or certain times of day? 
- Start with order_details; bring in pizza_type_id from the pizzas table, then bring in the date and time 
from the orders table. 
*/

CREATE TEMPORARY TABLE pizza_type_trends
SELECT 
	order_details.order_id,
    order_details.pizza_id,
    pizzas.pizza_type_id,
    quantity,
    date,
    time
FROM order_details
	LEFT JOIN pizzas 
		ON order_details.pizza_id = pizzas.pizza_id
	LEFT JOIN orders
		ON order_details.order_id = orders.order_id; 

SELECT * FROM pizza_type_trends;

/* Total sales by pizza type and month. This would be a good table to export to Excel and create an interactive 
dashboard/graph with a top N filter. 
*/

DROP TABLE pizza_trends; -- updating table by adding pizza_name column. 
CREATE TEMPORARY TABLE pizza_trends 
SELECT
	pizza_types.category AS pizza_category,
	pizza_type_trends.pizza_type_id,
    pizza_types.pizza_name,
	MONTH(date) AS month,
    SUM(quantity) AS total_sales
FROM pizza_type_trends
	LEFT JOIN pizza_types
		ON pizza_type_trends.pizza_type_id = pizza_types.pizza_type_id
GROUP BY 1,2,3,4
ORDER BY 4,5 DESC;

SELECT * FROM pizza_trends;

-- more specifically, which exact pizza (not pizza type) brought in the most sales by month? The least? 

CREATE TEMPORARY TABLE exact_pizza_trends
SELECT
	pizza_id,
    MONTH(date) AS month,
    SUM(quantity) AS total_orders
FROM 
(
SELECT 
	order_details.order_id,
    order_details.pizza_id,
    quantity,
    date,
    time
FROM order_details
	LEFT JOIN orders
		ON order_details.order_id = orders.order_id) AS exact_pizzas_table
GROUP BY 1,2
ORDER BY 2, 3 DESC;

SELECT * FROM exact_pizza_trends;

SELECT
	month,
    total_sales
FROM pizza_trends
WHERE pizza_type_id = 'brie_carre'
ORDER BY total_sales DESC;

/* Question 4: Are there any pizzas we should take off the menu, or any promotions to leverage? 
-The brie_carre has the least amount of sales, every single month. It sounds like a pizza that 
doesn't appeal as much to as many people. It does bring in some sales every month. 
It only comes in size small. Does it sell better at a certain time of day? 
pizza_id is 'brie_carre_s'
Insight: More brie_carre is ordered at 12 noon (79 total orders) and then at 5 pm (59 total orders)
Recommendation is place this pizza on a lunch special to see if it increases interest, or otherwise 
remove it from the menu due to consistently low sales. 
*/

SELECT
	order_details.pizza_id,
    HOUR(time) AS hour,
    COUNT(order_details.order_id) AS total_orders
FROM order_details
	INNER JOIN orders
		ON order_details.order_id = orders.order_id 
WHERE order_details.pizza_id = 'brie_carre_s'
GROUP BY 1,2
ORDER BY 3 DESC;


SELECT * FROM pizza_types;


