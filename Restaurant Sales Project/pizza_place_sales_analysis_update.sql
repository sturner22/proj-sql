/* I created some additional queries to bring another useful element to the dashboard. On average, how many pizzas of each size 
are ordered on each day of the week? This is important information for the business, so they can prep the correct amount of 
each size based on the average demand per day. They don't want to have too much of one size and not sell, and waste product; 
likewise, they don't want to run out of a popular size and lose business. I created a series of queries to get to this answer--
the last query contains the final result. (Spoiler: large is the most popular every day, followed by medium)
*/

/* Note: Though I seem to have an affinity for writing subqueries, I've recently learned they are not always best practice because 
they are difficult to read and debug. So, I wrote these queries first with subqueries, and then I rewrote them below that using CTEs
*/

create temporary table total_pizzas_wkday_size
select -- final query: total count of pizzas, grouped by weekday and size 
	t.week_day
   ,t.size
   ,sum(t.num_pizzas) as total_pizzas

from

(

select -- query 2: result includes count of pizzas per order as well as the weekday and size  
	s.pizza_count*s.quantity as num_pizzas
   ,s.week_day
   ,s.size


from

(

select -- query 1: Fields from three tables were needed; select fields and join applicable tables 
	od.order_id
   ,od.pizza_id
   ,1 as pizza_count -- this column is to calculate the # of pizzas of the specific type (completed in query 2) 
   ,od.quantity
   ,o.date
   ,weekday(o.date) as week_day -- 0 = Monday; 6 = Sunday 
   ,p.size
   
from
	order_details od
    
		inner join orders o
          on od.order_id = o.order_id
          
		inner join pizzas p
          on p.pizza_id = od.pizza_id
) s -- query 1 alias

) t -- query 2 alias 

group by 
	t.week_day
   ,t.size
order by 
	t.week_day
   ,total_pizzas desc
;

-- check the results: 

select 
	*
from
	total_pizzas_wkday_size
;

-- how many of each week day occurs in the orders table?

create temporary table num_days_in_orders
select
	count(distinct o.date) as count_dates
   ,weekday(o.date) as week_day
from
	orders o
group by 
	weekday(date)
;

-- final result: average number of pizzas for each size, for each day of the week: 

select
	a.week_day
   ,a.size
   ,round(a.total_pizzas/a.count_dates,0) as avg_pizzas

from

(
select
	p.week_day
   ,p.size
   ,p.total_pizzas
   ,d.count_dates

from
	total_pizzas_wkday_size p
    
		inner join num_days_in_orders d
          on p.week_day = d.week_day
) a
;

-- Now I will rewrite the same queries as above, but with CTEs instead of subqueries. 

-- the first CTE, pizza_summary_table, grabs all of the fields needed for the calculation and joins the applicable tables

with pizza_summary_table as (
	select
		od.order_id
	   ,od.pizza_id
	   ,1 as pizza_count -- this column is to calculate the # of pizzas of the specific type (completed in query 2) 
	   ,od.quantity
	   ,o.date
	   ,weekday(o.date) as week_day -- 0 = Monday; 6 = Sunday 
	   ,p.size
   
	from
		order_details od
    
			inner join orders o
			  on od.order_id = o.order_id
			  
			inner join pizzas p
			  on p.pizza_id = od.pizza_id
)

-- the second CTE, total_pizza_count, calculates the total # of each type of pizza by weekday and size:

,total_pizza_count as (
	select 
		s.pizza_count*s.quantity as num_pizzas
	   ,s.week_day
	   ,s.size
	   
	from
		pizza_summary_table s
)

-- this query uses the second CTE to show the total pizzas, grouped by weekday and size:

select  
	t.week_day
   ,t.size
   ,sum(t.num_pizzas) as total_pizzas

from
	total_pizza_count t
group by
	t.week_day
   ,t.size
order by
	t.week_day
   ,total_pizzas desc
;

/* Average number of pizzas by weekday and size, using CTEs instead of subqueries.
Note: the table num_days_in_orders is a temp table I created in the section above
*/

with date_count_table as (
	select
		p.week_day
	   ,p.size
	   ,p.total_pizzas
	   ,d.count_dates

	from
		total_pizzas_wkday_size p
		
			inner join num_days_in_orders d
			  on p.week_day = d.week_day
)

select
	d.week_day
   ,d.size
   ,round(d.total_pizzas/d.count_dates,0) as avg_pizzas

from
	date_count_table d
;


