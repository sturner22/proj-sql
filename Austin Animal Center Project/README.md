# Austin Animal Center Intakes Analysis

This folder contains my PostgreSQL queries for an analysis of Austin Animal Center's intake data, spanning October 2013 to mid-June 2023. I obtained this dataset from [The City of Austin's open data portal](https://data.austintexas.gov/Health-and-Community-Services/Austin-Animal-Center-Intakes/wter-evkm).

Click on the files to view my sql queries. Here is a summary of some interesting insights I discovered while querying the data: 

* In 2020, intakes for dogs and cats decreased by more than 50% from the previous year. This is expected due to the impact of Covid-19 (e.g.,more people were staying home and not traveling and therefore in a better position to adopt or foster a pet), but nonetheless was interesting to see confirmed by the data. In 2021, dog intakes increased by 15% and cat intakes increased by 48% as compared to 2020.
* Between 2014 and 2022, May was the busiest month for cat intakes in 6 out of the 9 years. For dogs, there was more variability, with July as the busiest intake month for 3 out of the 9 years. In 2017, September had the highest count of dog intakes. This coincides with Hurricane Harvey, which displaced many animals in Texas.
* For dogs and cats with more than one intake between 2013 and 2023, stray is the most common intake type, followed by owner surrender.
* Pit Bull Mix or Pit Bull was the dog breed with the most intakes for every year (2014-2022) except for 2019, when labrador retriever mix was the breed with the most intakes. 

## SQL skills demonstrated in this project
* Creating tables and importing data
* Joins
* Subqueries
* Temporary tables and CTEs
* Aggregations
* Window functions

 ## Tableau Dashboard

 I created a Tableau dashboard to show my analysis of Austin Animal Center's data. View it on my [Tableau Public profile.](https://public.tableau.com/app/profile/sarah.turner4702/viz/AustinAnimalCenterIntakeData/AACDashboard)

To create this dashboard, I incorporated Austin Animal Center's outcome data along with the intake data. I cleaned the columns first in Excel, including converting the "age" column from a text field to age in weeks, using a complex IFS function. I then loaded both tables into pgAdmin4 (PostgreSQL) and used a complex join to combine the tables. I created age categories in order to make the data easier to analyze by age. See the intake_outcome SQL file to view all of my queries and commentary. 

The dashboard itself is meant to be exploratory in nature and includes records for only dogs and cats. The dashboard has four different charts and shows intake trends by year, patterns in average length of stay in the shelter based on age category, trends in intake types by year, and a Top N chart for dog breeds with the most intakes. The target audience includes members of the public or other stakeholders who are invested in companion animal welfare and want to identify trends or patterns that could spark ideas for further investigation or intervention. The goal for any animal shelter is to save as many pets as possible, and so knowing how many animals are coming in, how they are ending up in the shelter (e.g. stray, owner surrender, etc.) and how long they are staying may give shelter stakeholders insight into how they can maximize space and programs to help these animals find forever homes. 

## Tableau skills demonstrated in this project 
* Parameters
* Parameter actions
* Table calculations
* LOD calculations
* Calculated fields (conditional statements, statistical summaries)
  
