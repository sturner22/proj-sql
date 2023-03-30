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

After completing the analysis in SQL, I exported some tables as csv files and created a dashboard in Excel to visually represent the insights gathered from the data. There are two hidden worksheets in front of the pizza_place_dashboard worksheet that contain the data used in the charts, graphs, and functions on the dashboard. See next session for a summary of insights. 

### Insights gathered from the Pizza Place sales analysis

