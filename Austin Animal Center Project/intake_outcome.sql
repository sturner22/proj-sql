create table aac_intakes_2 (
    animal_id varchar(250) 
   ,intake_date date
   ,intake_type varchar(250)
   ,intake_condition varchar(250)
   ,animal_type varchar(250)
   ,age_in_weeks numeric(6,2)
   ,breed varchar(250)
	
)
;

create table aac_outcomes (
    animal_id varchar(250) 
   ,outcome_date date
   ,dob date
   ,outcome_type varchar(250)
   ,outcome_subtype varchar(250)
   ,animal_type varchar(250)
   ,breed varchar(250)
)
;

/* create a table that ranks each intake date for each animal_id. For example, if one animal has 3 intakes,
the earliest intake date will be ranked as 1, the next as 2, etc.
*/

create temporary table ranked_intake as ( 
select
    i.animal_id
   ,i.intake_date
   ,i.intake_type
   ,i.intake_condition
   ,i.animal_type
   ,i.age_in_weeks
   ,i.breed
   ,rank() over(partition by i.animal_id order by i.intake_date) as intake_number

from 
    aac_intakes_2 i 
	
order by 
    i.animal_id
   ,intake_number
)
;

/* create another temporary table to rank each outcome date for each animal_id (same as I did for intake)
I will use these ranks to join the tables so I have one record including the intake date and the outcome date
*/

create temporary table ranked_outcome as (
select
    o.animal_id
   ,o.outcome_date
   ,o.dob
   ,o.outcome_type
   ,o.outcome_subtype
   ,o.animal_type
   ,o.breed
   ,rank() over(partition by o.animal_id order by o.outcome_date) as outcome_number

from 
    aac_outcomes o 

order by
    o.animal_id
   ,outcome_number

)
;

/* Now, I am going to join the ranked_intake and ranked_outcome tables on animal_id and the respective 
intake/outcome rank number. I using a left join so only animal_ids that are in the intake table are pulled in 
from the outcomes table. I am also only including dogs and cats in my analysis.
*/

create temporary table intake_to_outcome as (
select
    i.animal_id
   ,i.intake_date
   ,o.outcome_date
   ,i.intake_type
   ,o.outcome_type
   ,o.outcome_subtype
   ,i.intake_condition
   ,i.animal_type
   ,i.age_in_weeks
   ,i.breed
   
from ranked_intake i 
    left join ranked_outcome o
	    on i.animal_id = o.animal_id and 
           i.intake_number = o.outcome_number and 
	       o.outcome_date >= i.intake_date
	
where
    i.animal_type in ('Dog','Cat') 
)
;

/* Next, I am going to create age categories (bins) for dogs and cats, so I can analyze various metrics, such 
as length of stay, number of intakes, type of outcome, etc. against the age of the animal at time of intake. 
I did some online research to determine what "life stage" dogs and cats are considered in when they reach a certain 
age. This is not exact, but may provide some interesting information about the relationship between age and 
interaction with the shelter system.
*/

create temporary table aac_intake_to_outcome as (
select
    i.animal_id
   ,i.intake_date
   ,i.outcome_date
   ,i.intake_type
   ,i.outcome_type
   ,i.outcome_subtype
   ,i.intake_condition
   ,i.animal_type
   ,i.age_in_weeks
   ,i.breed
   ,case when i.animal_type = 'Dog' and i.age_in_weeks between 0.00 and 7.99 then 'Newborn (0-8 weeks)'
         when i.animal_type = 'Dog' and i.age_in_weeks between 8.00 and 51.99 then 'Puppy (8 weeks-1 year)'
		 when i.animal_type = 'Dog' and i.age_in_weeks between 52.00 and 207.99 then 'Young Adult (1-4 years)'
		 when i.animal_type = 'Dog' and i.age_in_weeks between 208.00 and 363.99 then 'Mature Adult (4-7 years)'
		 when i.animal_type = 'Dog' and i.age_in_weeks >= 364.00 then 'Senior (7 years and older)'
		 when i.animal_type = 'Cat' and i.age_in_weeks between 0.00 and 3.99 then 'Newborn (0-4 weeks)'
		 when i.animal_type = 'Cat' and i.age_in_weeks between 4.00 and 51.99 then 'Kitten (4 weeks-1 year)'
		 when i.animal_type = 'Cat' and i.age_in_weeks between 52.00 and 207.99 then 'Young Adult (1-4 years)'
		 when i.animal_type = 'Cat' and i.age_in_weeks between 208.00 and 571.99 then 'Mature Adult (4-11 years)'
		 when i.animal_type = 'Cat' and i.age_in_weeks between 572.00 and 799.99 then 'Senior (11-15 years)'
		 when i.animal_type = 'Cat' and i.age_in_weeks >= 780 then 'Geriatric (15 years and older)'
		 else 'uncategorized'
		 end as age_category_at_intake
from 
    intake_to_outcome i
)
;

/* The following query looks at the average, min, and max length of stay (in days), group by age category. 
*/

select
    a.animal_type
   ,a.age_category_at_intake
   ,round(avg(a.outcome_date - a.intake_date),2) as average_days_in_shelter
   ,max(a.outcome_date - a.intake_date) as max_days_in_shelter
   ,min(a.outcome_date - a.intake_date) as min_days_in_shelter
   ,count(a.animal_id) as total_animals_in_category

from 
    aac_intake_to_outcome a

group by 
    a.animal_type
   ,a.age_category_at_intake

order by 
    a.animal_type desc
   ,average_days_in_shelter desc
;

/* This query produced some unexpected results: negative numbers for min length of stay. I wrote additional 
queries to investigate this issue, and found that there are 135 records where the outcome_date is before the 
intake_date, resulting in a negative number. For many of these records, it looks like the intake_date is likely
prior to the minimum date in the dataset (10/1/2013), so that intake record is just missing. There may also be data entry
errors. I modified my join in my original temporary table to include another condition: outcome_date >= intake_date. 
This eliminated the inaccurate records
*/

/* This query produced expected results. For both dogs and cats, older animals have longer average lengths 
of stay from intake to outcome as compared to younger animals. 
*/

/* Other relationships to explore: age and intake type and outcome type; length of stay and outcome type;
age and intake condition; length of stay and breed. Since I have the data in the format I need for further analysis, 
I will explore my additional questions by creating visualizations in Tableau 
*/

