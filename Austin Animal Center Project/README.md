# Austin Animal Center Intakes Analysis

This folder contains my PostgreSQL queries for an analysis of Austin Animal Center's intake data, spanning October 2013 to mid-June 2023. I obtained this dataset from [The City of Austin's open data portal](https://data.austintexas.gov/Health-and-Community-Services/Austin-Animal-Center-Intakes/wter-evkm).

Click on the files to view my sql queries. I plan to create a dashboard to showcase my analysis as well--stay tuned! In the meantime, here is a summary of some interesting insights I discovered while querying the data: 

* In 2020, intakes for dogs and cats decreased by more than 50% from the previous year. This is expected due to the impact of Covid-19, but nonetheless was interesting to see confirmed by the data. In 2021, dog intakes increased by 15% and cat intakes increased by 48% as compared to 2020.
* Between 2014 and 2022, May was the busiest month for cat intakes in 6 out of the 9 years. For dogs, there was more variability, with July as the busiest intake month for 3 out of the 9 years. In 2017, September had the highest count of dog intakes. This coincides with Hurricane Harvey, which displaced many animals in Texas.
* For dogs and cats with more than one intake between 2013 and 2023, stray is the most common intake type, followed by owner surrender.
* Pit Bull Mix was the dog breed with the most intakes for every year (2014-2022) except for 2019, when labrador retriever mix was the breed with the most intakes. However, interesting to note, the total Pit Bull Mix intakes for the most recent two full years of data, 2021 and 2022, decreased more than 50% from the first full year of data, 2014.

##### SQL skills demonstrated in this project
* Creating tables and importing data
* Joins
* Subqueries
* Temporary tables and CTEs
* Aggregations
* Window functions 
