Prompt: Find the details of each customer regardless of whether the customer made an order. Output the customer's first name, last name, and the city along with the order details.
Sort records based on the customer's first name and the order details in ascending order.

SELECT c.first_name, c.last_name, c.city, o.order_details
FROM customers AS c
LEFT JOIN orders AS o
ON c.id = o.cust_id
ORDER BY c.first_name, o.order_details ASC;


Prompt: Find the average number of bathrooms and bedrooms for each city’s property types. Output the result along with the city name and the property type.

SELECT city, property_type, AVG(bathrooms) AS n_bathrooms_avg, AVG(bedrooms) AS n_bedrooms_avg
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
