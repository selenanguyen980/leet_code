-- Prompt 1: Identify the highest-paid job title within each department based on average base salary.
-- Context: Created for a compensation analysis project to support internal salary benchmarking.
WITH avg_salary AS (
SELECT department, job_title, ROUND(AVG(base_salary)) AS avg_base_salary
FROM employee_compensation
GROUP BY department, job_title
),
ranked_titles AS (
SELECT department, job_title, avg_base_salary,
RANK() OVER (
PARTITION BY department
ORDER BY avg_base_salary DESC
) AS rnk
FROM avg_salary
)

SELECT department, job_title, avg_base_salary
FROM ranked_titles
WHERE rnk = 1
ORDER BY avg_base_salary DESC;


-- Prompt 2: You are provided with an already aggregated dataset from Amazon that contains detailed information about sales across different products and marketplaces.
-- List the top 3 sellers in each product category for January. In case of ties, rank them the same and include all sellers tied for that position.
WITH ranked_sellers AS (
SELECT seller_id, total_sales, product_category, market_place, sales_date,
RANK() OVER (
PARTITION BY product_category
ORDER BY total_sales DESC
) AS rnk
FROM sales_data
WHERE sales_date >= '2024-01-01'
AND sales_date <= '2024-02-01'
)

SELECT seller_id, total_sales, product_category, market_place, sales_date
FROM ranked_sellers
WHERE rnk <= 3;


-- Prompt 3: Find athletes who competed for different countries across multiple Olympic games. An athlete is considered to have multiple teams if they appear in the dataset representing different countries in different Olympic competitions.
-- Return all competition records for athletes who represented more than one country. Output the athlete name, country, games, sport, and medal for each of their competitions.
WITH athlete_teams AS (
SELECT name, COUNT(DISTINCT team) AS team_count
FROM olympic_games_athletes
GROUP BY name
HAVING COUNT(DISTINCT team) > 1
)

SELECT o.name, o.team, o.games, o.sport, o.medal
FROM olympic_games_athletes AS o
INNER JOIN athlete_teams AS a
ON o.name = a.name;


-- Prompt 4: Management wants to analyze only employees with official job titles. Find the job titles of the employees with the highest salary.
-- If multiple employees have the same highest salary, include all their job titles.
WITH ranked_titles AS (
SELECT t.worker_title,
RANK() OVER (
ORDER BY w.salary DESC
) AS highest_salary
FROM worker AS w
INNER JOIN title AS t
ON w.worker_id = t.worker_ref_id
)

SELECT worker_title
FROM ranked_titles
WHERE highest_salary = 1;


-- Prompt 5: Count the number of unique users per day who logged in from either a mobile device or web. Output the date and the corresponding number of users.
WITH total_logs AS (
SELECT user_id, log_date
FROM mobile_logs
UNION ALL
SELECT user_id, log_date
FROM web_logs
)

SELECT COUNT(DISTINCT user_id) AS n_users, log_date
FROM total_logs
GROUP BY log_date;


-- Prompt 6: Return the total number of comments received for each user in the 30-day period up to and including 2020-02-10.
-- Don't output users who haven't received any comment in the defined time period.
SELECT user_id, SUM(number_of_comments) AS number_of_comments
FROM fb_comments_count
WHERE created_at >= '2020-02-10' - INTERVAL 30 DAY
AND created_at <= '2020-02-10'
GROUP BY user_id;


-- Prompt 7: Calculate the average score for each project, but only include projects where more than one team member has provided a score.
-- Your output should include the project ID and the calculated average score for each qualifying project.
SELECT project_id, AVG(score) AS avg_score
FROM project_data
GROUP BY project_id
HAVING COUNT(DISTINCT team_member_id) > 1;


-- Prompt 8: Count the unique activity types for each user, ensuring users with no activities are also included.
-- The output should show each user's ID and their activity type count, with zero for users who have no activities.
SELECT u.user_id, COUNT(DISTINCT a.activity_type) AS n_activities
FROM user_profiles AS u
LEFT JOIN activity_log AS a
ON u.user_id = a.user_id
GROUP BY u.user_id;


-- Prompt 9: You're tasked with analyzing a Spotify-like dataset that captures user listening habits.
-- For each user, calculate the total listening time and the count of unique songs they've listened to.
SELECT user_id, ROUND(SUM(listen_duration)/60.0) AS total_listen_duration, COUNT(DISTINCT song_id) AS unique_song_count
FROM listening_habits
GROUP BY user_id;


-- Prompt 10: Find the average number of bathrooms and bedrooms for each city’s property types.
-- Output the result along with the city name and the property type.
SELECT city, property_type, AVG(bathrooms) AS avg_n_bathrooms, AVG(bedrooms) AS avg_n_bedrooms
FROM airbnb_search_details
GROUP BY city, property_type;


-- Prompt 11: Find the details of each customer regardless of whether the customer made an order.
-- Output the customer's first name, last name, and the city along with the order details.
SELECT c.first_name, c.last_name, c.city, o.order_details
FROM customers AS c
LEFT JOIN orders AS o
ON c.id = o.cust_id
ORDER BY c.first_name, o.order_details ASC;
