/* This sql file contains my analysis of Austin Animal Center's intake data. I obtained this dataset from 
the City of Austin's open data portal on 6/13/2023. The data contains intake data for October 2013 to present
*/

--  Step 1: create a table and import data

create table aac_intakes (
    animal_id varchar(25)
   ,intake_date date
   ,animal_name varchar(50)
   ,found_location varchar(255)
   ,intake_type varchar(50)
   ,intake_condition varchar(50)
   ,animal_type varchar(50)
   ,sex_upon_intake varchar(50)
   ,age_upon_intake varchar(50)
   ,breed varchar(255)
   ,color varchar(255)
)
;

-- selecting all fields from table after data import to ensure it loaded as expected.

select 
	*
from
	aac_intakes
;

/* Total number of intakes, grouped by year. I will make this a temporary table 
so I can use it easily in other queries. Note: I am only including dogs and cats, 
since these animal types typically are of most interest to the public and other
stakeholders. In addition, I am excluding 2013 and 2023 since both of these years
have incomplete data. 
*/

create temporary table intakes_by_yr as (
    select
        date_part('year',a.intake_date) as intake_yr
	   ,count(a.animal_id) as num_intakes

	from
        aac_intakes a
	
	where	( 
			animal_type = 'Dog'
		or	animal_type = 'Cat'
			)
		and (
			date_part('year',a.intake_date) not in (
												'2013'
									  		   ,'2023'
												   )
			)

	group by 
		date_part('year',a.intake_date)

	order by 
		intake_yr
)
;

-- view table intakes_by_yr:

select
	*
from
	intakes_by_yr
;

-- Running total of intakes by year

select
    i.intake_yr
   ,sum(i.num_intakes) over(order by i.intake_yr) as running_total_by_yr

from
    intakes_by_yr i
;

/* I want to find the percent change in intakes year over year. 
My first step is to create a table that includes the prior year's number 
of intakes in the same row for each year's number of intakes, so I can then do the 
math in the next step. Note, I am excluding 2013 and 2023 due to incomplete data
for those years 
*/

create temporary table yr_prior_yr_intakes as (
    select
        i.intake_yr
	   ,cast(i.num_intakes as numeric) as num_intakes
	   ,lag(cast((i.num_intakes) as numeric)) over(order by i.intake_yr) 
			as prior_yr_num_intakes

	 from
        intakes_by_yr i
	 where 
        i.intake_yr not in(
							2013 --incomplete data for year
						   ,2023 -- incomplete data for year
						  )
)
;

-- view temporary table results:

select
	*
from 
	yr_prior_yr_intakes
;

/* My second step is to calculate the percent change for intakes from the previous 
year. The calculation is completed in the third item in the select clause
*/

select
    p.intake_yr
   ,p.num_intakes
   ,(round((p.num_intakes-p.prior_yr_num_intakes)/p.prior_yr_num_intakes,3))*100 
		  as pct_change

from
    yr_prior_yr_intakes p
;


/* Now I want to look at number of intakes separately for dogs and cats. 
First, I will get the counts of dog and cat intakes into separate columns 
use count-case, and create a temporary table for the result. 
*/

create temporary table dog_cat_intakes as (
    select
	    date_part('year',a.intake_date) as intake_yr
       ,count(case when a.animal_type= 'Dog' then a.animal_id else null end) as dog_intakes
       ,count(case when a.animal_type= 'Cat' then a.animal_id else null end) as cat_intakes

    from
        aac_intakes a

    group by
        date_part('year',a.intake_date)
    order by
        intake_yr
)
;

/* My second step is to repeat the process I completed above to pull in the prior 
year's intakes into the same row; this time I'll just need to do it twice
*/

create temporary table yr_prior_dog_cat_intakes as (
    select
        dc.intake_yr
	   ,cast(dc.dog_intakes as numeric) as dog_intakes
	   ,lag(cast((dc.dog_intakes) as numeric)) over(order by dc.intake_yr) 
			as prior_yr_dog_intakes
	   ,cast(dc.cat_intakes as numeric) as cat_intakes
	   ,lag(cast((dc.cat_intakes) as numeric)) over(order by dc.intake_yr) 
			as prior_yr_cat_intakes

     from
		dog_cat_intakes dc
     where 
		dc.intake_yr not in(
						    2013 --incomplete data for year
						   ,2023 -- incomplete data for year
						  )
)
;

/* Finally, I will calculate the percent change for both dog and cat intakes
from the previous year. 
*/

select
    p.intake_yr
   ,p.dog_intakes
   ,(round((p.dog_intakes-p.prior_yr_dog_intakes)/p.prior_yr_dog_intakes,3))*100 
		  as pct_change_dogs
   ,p.cat_intakes
   ,(round((p.cat_intakes-p.prior_yr_cat_intakes)/p.prior_yr_cat_intakes,3))*100 
		  as pct_change_cats

from
    yr_prior_dog_cat_intakes p
;

/* What months are the busiest for dog and cat intakes? Are there any monthly trends year over year?
Note: I excluded 2013 because the data starts in October. I decided to keep 2023 so I can compare the intake
totals from Jan-May to the intake totals from previous years. However, I will exclude 2023 if looking at 
year-over-year trends.
*/

-- Step 1: Create a table to count intakes, grouped by year and then month


create temporary table year_month_intakes as (
    select	
        date_part('year',a.intake_date) as intake_yr
       ,date_part('month',a.intake_date) as intake_month
       ,a.animal_type
       ,count(a.animal_id) as total_intakes

    from 
        aac_intakes a

    where
         date_part('year',a.intake_date) <> '2013' -- only 3 months of data for 2013
	
    and 
	   (
          a.animal_type = 'Dog'
	  or  a.animal_type = 'Cat'
	   )
	

    group by 
        date_part('year',a.intake_date) 
       ,date_part('month',a.intake_date)
       ,a.animal_type

    order by
        intake_yr asc
       ,intake_month asc
)
;

-- Step 2: Create a table that includes the month with the highest dog intakes, for each year 

create temporary table highest_monthly_dog_intakes as (
    select 
        y.intake_yr
       ,y.intake_month
       ,y.animal_type
       ,y.total_intakes

    from 
        year_month_intakes y

    where 
        (y.intake_yr
        ,y.total_intakes) IN (
							    select
								  intake_yr
							     ,max(total_intakes)
							    from
								  year_month_intakes
							    where 
								  animal_type = 'Dog'
							    group by 
								  intake_yr
   						  )
    order by
        y.intake_yr asc
       ,y.intake_month asc
)
;

-- Step 3: Repeat step 2, but for cats 

create temporary table highest_monthly_cat_intakes as (
    select 
        y.intake_yr
       ,y.intake_month
       ,y.animal_type
       ,y.total_intakes

    from 
        year_month_intakes y

    where 
        (y.intake_yr
        ,y.total_intakes) IN (
							    select
								  intake_yr
							     ,max(total_intakes)
							    from
								  year_month_intakes
							    where 
								  animal_type = 'Cat'
							    group by 
								  intake_yr
   						    )
    order by
        y.intake_yr asc
       ,y.intake_month asc
)
;

-- Step 4: Join the dog and cat tables together on intake_yr

select
    d.intake_yr
   ,d.intake_month as busiest_dog_month
   ,d.animal_type
   ,d.total_intakes as dog_intakes
   ,c.intake_month as busiest_cat_month
   ,c.animal_type
   ,c.total_intakes as cat_intakes

from 
    highest_monthly_dog_intakes d
		
        inner join highest_monthly_cat_intakes c
			on d.intake_yr = c.intake_yr
;

/* Insights: May was the busiest intake month for cats for 6 out of 9 years in the dataset (excluding 2023). June
was the next busiest cat intake month. The exception was 2020, in which September saw the most cat intakes. For 
dogs, there is more variability, with July appearing as the busiest intake month in 3 of the 9 years (again, excluding
2023). September was the busiest dog intake month in 2017; this coincides with Hurricane Harvey, which displaced
a lot of animals in Texas. Interestingly, October was the busiest dog intake month in 2018. January was the busiest
for dogs in 2020, likely due to the impact of Covid for much of the rest of the year
*/
	