# Pizza Place Sales SQL Project 

This repository contains SQL files and a dashboard for the analysis of a year's worth of sales data from a fictional pizza restaurant. The dataset was obtained from [Maven Analytic's Data Playground.](https://app.mavenanalytics.io/datasets?order=-fields.dateUpdated)

## File descriptions

#### pizza_place_sales_db.sql

This file contains the SQL queries I wrote to build the database in the MySQL workbench. To get the data in the correct format for MySQL, I used Excel to edit data types/formats and text (e.g. putting the dates into "YYYY-MM-DD" format and adding quotes around text values) and then opened the csv file in Notepad to complete additional edits before copying and pasting the data into MySQL workbench. One of the tables had thousands of rows, and I found this method very speedy and easy to get the data from the csv file into MySQL workbench. 

#### pizza_place_sales_analysis.sql

This file contains the SQL queries I wrote to analyze the data. I included comments to detail the analysis questions, explain the queries, and detail my insights and observations from the data. 

#### pizza_place_sales_analysis_queries.txt & pizza_place_sales_create_db.txt

These two files are identical versions of the SQL files, just saved as plain text. 

#### EER diagram pizza_place_sales.jpg & pizza_place_sales_EER.mwb

This is the EER diagram I created in MYSQL workbench. 

#### pizza place sales dashboard.xlsx

After completing the analysis in SQL, I exported some tables as csv files and created a dashboard in Excel to visually represent the insights gathered from the data. There are three hidden worksheets that contain the data used in the charts, graphs, and functions on the dashboard. See next session for a summary of insights. 

### Insights gathered from the Pizza Place sales analysis

* Peak hours at the restaurant are during lunchtime, from 12pm to 2pm, and again during dinner, 5pm to 7pm. Fridays were the busiest, with an average of 70 orders, and Sundays were the least busy on average, with around 50 orders. The busiest month of the year was July. 
* A little over a third (~38%) of orders contained one pizza. The largest order of all contained 28 pizzas. Large was the most popular size, followed by medium. 
* The best-selling pizza overall was "The Big Meat", size small, with 1,914 orders. The pizza type (all sizes included) that sold the most was The Classic Delux, with 2,453 sales 
* The highest revenue was seen in July, and the lowest in October. 
* The "Brie Carre" pizza, in the Supreme category, was the least ordered pizza type every month, although it did bring in orders each month. It is only available in one size, small. 
