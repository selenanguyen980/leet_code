Prompt: Find the details of each customer regardless of whether the customer made an order. Output the customer's first name, last name, and the city along with the order details.
Sort records based on the customer's first name and the order details in ascending order.

SELECT c.first_name, c.last_name, c.city, o.order_details
FROM customers AS c
LEFT JOIN orders AS o
ON c.id = o.cust_id
ORDER BY c.first_name, o.order_details ASC;


Prompt: Find the average number of bathrooms and bedrooms for each city’s property types. Output the result along with the city name and the property type.

SELECT city, property_type, AVG(bathrooms) AS avg_n_bathrooms, AVG(bedrooms) AS avg_n_bedrooms
FROM airbnb_search_details
GROUP BY city, property_type;


Prompt: Count the number of unique users per day who logged in from either a mobile device or web. Output the date and the corresponding number of users.

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


Prompt: Find athletes who competed for different countries across multiple Olympic games. An athlete is considered to have multiple teams if they appear in the dataset representing different countries in different Olympic competitions.
Return all competition records for athletes who represented more than one country. Output the athlete name, country, games, sport, and medal for each of their competitions.

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


Prompt: Calculate the average score for each project, but only include projects where more than one team member has provided a score. Your output should include the project ID and the calculated average score for each qualifying project.

SELECT project_id, AVG(score) AS avg_score
FROM project_data
GROUP BY project_id
HAVING COUNT(DISTINCT team_member_id) > 1;


Prompt: Count the unique activity types for each user, ensuring users with no activities are also included. The output should show each user's ID and their activity type count, with zero for users who have no activities.

SELECT u.user_id, COUNT(DISTINCT a.activity_type) AS n_activities
FROM user_profiles AS u
LEFT JOIN activity_log AS a
ON u.user_id = a.user_id
GROUP BY u.user_id;

