/* Analysis questions:
1. Which countries have the most ski resorts? Are there noticeable clusters?
2. Which resorts have the highest mountain peaks and elevation changes?
3. What are the best resorts for beginners? What about experts? 
*/

-- Question 1: Which countries have the most ski resorts? Are there noticeable clusters? 

SELECT
continent,
country,
COUNT(DISTINCT id) AS num_resorts
FROM resorts
GROUP BY continent, country 
ORDER BY 3 DESC;

/* Question 2: Which resorts have the highest mountain peaks and elevation changes? 
The column highest_point represents the highest mountain point at the resort in meters.
The column lowest_point represents the lowest point it is possible to ski in meters. 
*/

-- Overall highest point. This result is sorted by highest_point in descending order
SELECT
resort,
country,
highest_point
FROM resorts
ORDER by 3 DESC;

-- Resort with the highest moutain peak per country 
SELECT 
resort,
country,
highest_point
FROM
(SELECT 
resort, 
country,
highest_point,
dense_rank() OVER (partition by country ORDER by highest_point DESC) AS place
FROM resorts) AS peak_rank
WHERE place = 1
ORDER BY highest_point DESC;

-- Greatest elevation change: 
SELECT
resort,
country,
highest_point-lowest_point AS elevation_change
FROM resorts
ORDER BY 3 DESC;

/* Question 3: What are the best resorts for beginners? What about experts? 
*/

-- Resorts with most to least beginner slopes:
SELECT
resort,
country,
beginner_slopes
FROM resorts
ORDER BY 3 DESC;

-- Average beginner slopes by country: 
SELECT
country,
ROUND(AVG(beginner_slopes),0) AS beginner_slopes_avg
FROM resorts
GROUP BY country
ORDER BY 2 DESC;

-- Total beginner slopes by country:
SELECT
country,
SUM(beginner_slopes) AS total_beginner_slopes
FROM resorts
GROUP BY 1
ORDER BY 2 DESC;

-- Resorts with most to least difficult slopes: 
SELECT 
resort,
country,
difficult_slopes
FROM resorts
ORDER BY 3 DESC;

-- Average difficult slopes by country:
SELECT
country,
ROUND(AVG(difficult_slopes),0) AS difficult_slopes_avg
FROM resorts
GROUP BY 1
ORDER BY 2 DESC;

-- Total difficult slopes by country:
SELECT 
country,
SUM(difficult_slopes) AS total_difficult_slopes
FROM resorts
GROUP BY 1
ORDER BY 2 DESC;

/* Other questions: 
1. Which resorts are most expensive? Least expensive? What is the average cost of a day pass for an adult by country? 
The price_euros column represents the cost of a 1-day ski pass for an adult in the main season. Note: There are some resorts 
that show a 0 value in price_euros. Unknown if this is accurate. 
2. What are the start and end months of the main season? Are there patterns by country? 
*/

-- Cost of a ski pass by resort, most to least expensive
SELECT 
resort,
country,
price_euros
FROM resorts
ORDER BY 3 DESC;

-- Average cost of a daily ski pass by country
SELECT
country,
ROUND(AVG(price_euros),2) AS avg_cost
FROM resorts
GROUP BY 1
ORDER BY 2 DESC;

-- Ski season patterns by country:
SELECT 
country,
season_start,
season_end,
COUNT(DISTINCT id) AS total_resorts
FROM resorts
GROUP BY 1,2,3
ORDER BY 1 DESC, 4 DESC;

-- Adding rank to seasons by country, in order to select the most common start/end months by country
SELECT
	* 
FROM 
(SELECT
*,
dense_rank() OVER(partition by country order by total_resorts DESC) AS most_common_season
FROM
(SELECT 
country,
season_start,
season_end,
COUNT(DISTINCT id) AS total_resorts
FROM resorts
GROUP BY 1,2,3
ORDER BY 1 DESC, 4 DESC) AS seasons
) AS ranked_order
WHERE most_common_season = 1;

-- resorts with ski seasons that start in May, June, or July:
SELECT
resort,
country,
season_start,
season_end
FROM resorts
WHERE season_start IN ("May","June","July")
ORDER BY 2; 

-- Other queries to retrieve data for the Excel Dashboard:

-- Country-level stats: 
SELECT
country,
COUNT(DISTINCT id) AS number_of_resorts,
ROUND(AVG(price_euros),2) AS average_cost,
ROUND(AVG(beginner_slopes),0) AS average_beginner_slopes,
ROUND(AVG(intermediate_slopes),0) AS average_intermediate_slopes,
ROUND(AVG(difficult_slopes),0) AS average_difficult_slopes
FROM resorts
GROUP BY 1
ORDER BY 2 DESC;

SELECT * FROM resorts;

-- resort-level stats: 
SELECT
resort,
country,
highest_point,
highest_point-lowest_point AS elevation_change,
price_euros,
beginner_slopes,
difficult_slopes,
season_start,
season_end
FROM resorts;

	