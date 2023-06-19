/* This sql file is a continuation of my analysis of Austin Animal Center's intake data, spanning October 2013 
to June 13 2023. I downloaded the dataset from the City of Austin's open data portal on 6/13/23. This file contains
queries exploring instances of repeat intakes by animal type and intake type, as queries to explore any interesting
patterns in intakes based on breed or yearly trends 
*/

/* What are the trends for intake type, year over year, for different animals?
Note: 2013 and 2023 are excluded due to incomplete data.
*/

select
	date_part('year',a.intake_date) as intake_year
   ,a.intake_type
   ,a.animal_type
   ,count(a.animal_id) as num_animals
   
from
	aac_intakes a

where
	date_part('year',a.intake_date) not in (
											  '2013' -- incomplete data
											  '2023' -- incomplete data
										   )
		                            and a.animal_type <> 'Other' -- too ambiguous

group by 
	date_part('year',a.intake_date)
   ,a.intake_type
   ,a.animal_type

order by
	intake_year,
	num_animals desc
;

/* I'm interested in knowing how many animals had more than one intake between 
2014 and 2022. Appearing more than once in the dataset might mean that the animal 
was returned by the owner, got lost and was found as a stray, etc. The following 
query will count rows and group by animal_id. I am including 2013 and 2023 in this
query since I am not looking at trends.
*/

select
	a.animal_id
   ,a.animal_type
   ,count(a.animal_id) as num_intakes

from
	aac_intakes a

group by 
	a.animal_id
   ,a.animal_type

having 
	count(a.animal_id) > 1

order by 
	num_intakes desc
;

/* Wow, there are 12,114 animals with more than one intake between 2013-2023. 
animal_id A721033 has 33 intakes! I will look into this animal further to learn more
*/

select
	*
from
	aac_intakes a
where 
	a.animal_id = 'A721033'
order by
	date_part('year',a.intake_date)
;

/* A721033 is a dog named Lil Bit, and between December 2016 and March 2019, he 
went through intake 33 times. Usually the intake type is public assist (not sure 
what this means) or stray. 
*/

/* The next query will look at most common intake_types by animal type for animals
with more than one intake between 2013-2023
*/

select
    a.animal_type
   ,a.intake_type
   ,count(a.animal_id) as num_intakes

from
	aac_intakes a

group by 
    a.animal_type
   ,a.intake_type

having 
	count(a.animal_id) > 1

order by 
    num_intakes desc
;

/* Dogs have the most repeat intakes, followed by cats. Stray is the most common
intake type, followed by owner surrender
*/

-- I'm curious now, what does animal_type other include? 

select 
	distinct 
		a.breed
from
	aac_intakes a
where
	a.animal_type = 'Other'
;

/* The answer: a variety of rabbits, bats, raccoons, hamsters, snakes, foxes, 
coyotes; 131 distinct animal types/breeds are included in 'Other' animal_type!
*/

/* What is the average duration between intakes for dogs, and how does it differ
based on intake types: stray, owner surrender, and public assist?
*/

-- Step 1: create temp table to include animal_ids of dogs with > 1 intake

create temporary table dogs_w_multiple_intakes as (
	select 
		a.animal_id
	   ,count(a.animal_id) as num_intakes

	from 
		aac_intakes a

	where 
		a.animal_type = 'Dog'

	group by 
		a.animal_id

	having
		count(a.animal_id) > 1
)
;
-- Step 2: assign row numbers for each intake, for each animal_id. Join to temporary table created above. 

create temporary table row_num_intake_dts as (
	select
		row_number() over(partition by a.animal_id order by a.intake_date) as intake_num
	   ,a.animal_id
	   ,a.animal_type
	   ,a.intake_type
	   ,a.intake_date

	from 
		aac_intakes a
	  inner join dogs_w_multiple_intakes i
			on a.animal_id = i.animal_id
)
;

-- Step 3: Pull in the next intake date into the same row, and create a temporary table. 

create temporary table all_intake_dates as (
with intake_and_next_intake as (
select
	r.intake_num
   ,r.animal_id
   ,r.intake_type
   ,r.intake_date
   ,lead(intake_date) over(partition by r.animal_id order by r.intake_date) as next_intake_dt

from
	row_num_intake_dts r
)

select
	i.intake_num
   ,i.animal_id
   ,i.intake_type
   ,i.intake_date
   ,i.next_intake_dt

from 
	intake_and_next_intake i	

where
	next_intake_dt is not null
)
;

-- Step 4: Find the difference in days between intakes for each animal id

create temporary table date_diff_intakes as (
select
    ad.intake_num
   ,ad.animal_id
   ,ad.intake_type
   ,ad.intake_date
   ,ad.next_intake_dt
   ,ad.next_intake_dt-ad.intake_date as days_between_intakes

from
	all_intake_dates ad
order by
	days_between_intakes asc
	,ad.intake_type 
)
;
select * from date_diff_intakes

-- Step 5: Group the results of date_diff_intakes by intake_type

select
	dd.intake_type
   ,avg(dd.days_between_intakes) as avg_btwn_intakes

from 
	date_diff_intakes dd

group by
	dd.intake_type

order by 
	avg_btwn_intakes desc
;

/* conclusion: public assist intake type has the most number of days between intakes, on average,
followed by stray intake tape. Overall, the result of this process turned out to be not very interesting
after all! I think this type of calculation may be more useful if I were interested in looking into a particular
animal in more depth, versus a category of intakes. 
*/

/* Finally, on the theme of dog intakes, are there any interesting correlations for dog intakes and breed? 
Has this changed at all between 2014 and 2022? 
*/

-- Step 1: Create a table to count intakes by year and dog breed

create temporary table breed_intakes_by_year as (
select
	date_part('year',a.intake_date) as intake_yr
   ,a.breed
   ,count(a.animal_id) as num_intakes

from
	aac_intakes a
	
where 
	animal_type = 'Dog'
	and date_part('year',a.intake_date) not in (
												  '2013' -- incomplete data
								                 ,'2023' -- incomplete data
											   )

group by 
	date_part('year',a.intake_date)
   ,a.breed

order by 
	intake_yr
   ,num_intakes desc
)
;

-- Step 2: select max of count of intakes for each year

with row_num_breed_intakes as (
	select
		row_number() over(partition by b.intake_yr order by b.num_intakes desc) as row_num
	   ,b.intake_yr
	   ,b.breed
	   ,b.num_intakes

	from 	
		breed_intakes_by_year b
)

select
	rb.row_num
   ,rb.intake_yr
   ,rb.breed
   ,rb.num_intakes

from 
	row_num_breed_intakes rb

where 
	rb.row_num = 1

/* Conclusion: Pit Bull Mix was the breed with the most intakes for every year (2014-2022) except for 2019,
when labrador retriever mix was the breed with the most intakes. However, interesting to note, the total 
Pit Bull Mix intakes for the most recent two full years of data, 2021 and 2022, decreased more than 50% from 
the first full year of data, 2014. 
*/


