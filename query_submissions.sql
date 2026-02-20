-- Prompt 1: You are provided with an already aggregated dataset from Amazon that contains detailed information about sales across different products and marketplaces.
-- Your task is to list the top 3 sellers in each product category for January. In case of ties, rank them the same and include all sellers tied for that position.
WITH ranked_sellers AS (
    SELECT
        seller_id,
        total_sales,
        product_category,
        market_place,
        sales_date,
        RANK() OVER (
            PARTITION BY product_category
            ORDER BY total_sales DESC
        ) AS rnk
    FROM sales_data
    WHERE sales_date >= '2024-01-01'
      AND sales_date < '2024-02-01'
)
SELECT
    seller_id,
    total_sales,
    product_category,
    market_place,
    sales_date
FROM ranked_sellers
WHERE rnk <= 3;


-- Prompt 2: Find athletes who competed for different countries across multiple Olympic games.
-- An athlete is considered to have multiple teams if they appear in the dataset representing different countries in different Olympic competitions.
WITH athlete_teams AS (
    SELECT
        name,
        COUNT(DISTINCT team) AS team_count
    FROM olympic_games_athletes
    GROUP BY name
    HAVING COUNT(DISTINCT team) > 1
)
SELECT
    o.name,
    o.team,
    o.games,
    o.sport,
    o.medal
FROM olympic_games_athletes AS o
INNER JOIN athlete_teams AS a
    ON o.name = a.name;


-- Prompt 3: Order all countries by the year they first participated in the Olympics. Output the National Olympics Committee (NOC) name along with the desired year.
-- Sort records in ascending order by year, and alphabetically by NOC.
WITH ranked_years AS (
    SELECT
        noc,
        year,
        ROW_NUMBER() OVER (
            PARTITION BY noc
            ORDER BY year
        ) AS rn
    FROM olympics_athletes_events
)
SELECT
    noc,
    year
FROM ranked_years
WHERE rn = 1
ORDER BY year ASC, noc ASC;


-- Prompt 4: As a data scientist at Amazon Prime Video, you are tasked with enhancing the in-flight entertainment experience for Amazon’s airline partners.
-- For flight 101, find movies whose runtime is less than or equal to the flight's duration.
SELECT
    f.flight_id,
    m.movie_id,
    m.duration
FROM flight_schedule AS f
INNER JOIN entertainment_catalog AS m
    ON f.flight_duration >= m.duration
WHERE f.flight_id = 101;


-- Prompt 5: Rank the top five customers by total purchase value. If multiple customers have the same total purchase value, treat them as ties and include all tied customers in the result.
-- Ensure that the ranking does not skip numbers due to ties (e.g., if two customers share rank 2, the next rank should be 3).
WITH ranked_customers AS (
    SELECT
        customer_id,
        total_purchase_value,
        DENSE_RANK() OVER (
            ORDER BY total_purchase_value DESC
        ) AS rnk
    FROM customer_purchase
)
SELECT
    customer_id,
    total_purchase_value,
    rnk
FROM ranked_customers
WHERE rnk <= 5;


-- Prompt 6: Rank guests based on their ages. Output the guest id along with the corresponding rank.
-- Order records by the age in descending order.
SELECT
    guest_id,
    RANK() OVER (
        ORDER BY age DESC
    ) AS rnk
FROM airbnb_guests;


-- Prompt 7: Return a list of users with status free who didn’t make any calls in Apr 2020.
SELECT
    u.user_id
FROM rc_users AS u
LEFT JOIN rc_calls AS c
    ON u.user_id = c.user_id
   AND c.call_date >= '2020-04-01'
   AND c.call_date < '2020-05-01'
WHERE c.call_id IS NULL
  AND u.status = 'free';


-- Prompt 8: Identify the products that exist in the inventory but have never been sold.
-- Return the product ID and product name for each unsold product.
SELECT
    i.product_id,
    i.product_name
FROM inventory_current_stock AS i
LEFT JOIN sales_transactions AS s
    ON i.product_id = s.product_id
   AND s.quantity_sold > 0
WHERE s.product_id IS NULL;


-- Prompt 9: Count the number of unique users per day who logged in from either a mobile device or web.
-- Output the date and the corresponding number of users.
WITH total_logs AS (
    SELECT user_id, log_date FROM mobile_logs
    UNION ALL
    SELECT user_id, log_date FROM web_logs
)
SELECT
    log_date,
    COUNT(DISTINCT user_id) AS n_users
FROM total_logs
GROUP BY log_date;


-- Prompt 10: Return the total number of comments received for each user in the 30-day period up to and including 2020-02-10.
-- Don't output users who haven't received any comment in the defined time period.
SELECT
    user_id,
    SUM(number_of_comments) AS number_of_comments
FROM fb_comments_count
WHERE created_at >= '2020-02-10' - INTERVAL 30 DAY
  AND created_at <= '2020-02-10'
GROUP BY user_id;


-- Prompt 11: Calculate the average score for each project, but only include projects where more than one team member has provided a score.
-- Your output should include the project ID and the calculated average score for each qualifying project.
SELECT
    project_id,
    AVG(score) AS avg_score
FROM project_data
GROUP BY project_id
HAVING COUNT(DISTINCT team_member_id) > 1;


-- Prompt 12: Count the unique activity types for each user, ensuring users with no activities are also included.
-- The output should show each user's ID and their activity type count, with zero for users who have no activities.
SELECT
    u.user_id,
    COUNT(DISTINCT a.activity_type) AS n_activities
FROM user_profiles AS u
LEFT JOIN activity_log AS a
    ON u.user_id = a.user_id
GROUP BY u.user_id;


-- Prompt 13: You're tasked with analyzing a Spotify-like dataset that captures user listening habits.
-- For each user, calculate the total listening time and the count of unique songs they've listened to.
SELECT
    user_id,
    ROUND(SUM(listen_duration) / 60.0) AS total_listen_duration,
    COUNT(DISTINCT song_id) AS unique_song_count
FROM listening_habits
GROUP BY user_id;


-- Prompt 14: Find the average number of bathrooms and bedrooms for each city’s property types.
-- Output the result along with the city name and the property type.
SELECT
    city,
    property_type,
    AVG(bathrooms) AS avg_n_bathrooms,
    AVG(bedrooms) AS avg_n_bedrooms
FROM airbnb_search_details
GROUP BY city, property_type;


-- Prompt 15: Find all the songs that were top-ranked (at first position) at least once since the year 2005.
SELECT DISTINCT
    song_name
FROM billboard_top_100_year_end
WHERE year_rank = 1
  AND year >= 2005;


-- Prompt 16: Find the details of each customer regardless of whether the customer made an order.
-- Output the customer's first name, last name, and the city along with the order details.
SELECT
    c.first_name,
    c.last_name,
    c.city,
    o.order_details
FROM customers AS c
LEFT JOIN orders AS o
    ON c.id = o.cust_id
ORDER BY c.first_name, o.order_details ASC;


-- Prompt 17: Find doctors with the last name of 'Johnson' in the employee list.
-- The output should contain both their first and last names.
SELECT
    first_name,
    last_name
FROM employee_list
WHERE lower(last_name) = 'johnson'
  AND lower(profession) = 'doctor';


-- Prompt 18: Determine whether hosts or guests leave higher review scores on average.
-- Return the group (host or guest) with the higher average score and the corresponding average rounded to 2 decimal places.
SELECT from_type,
   AVG(review_score) AS high_avg_score
FROM airbnb_reviews
WHERE from_type = 'guest'
    OR from_type = 'host'
GROUP BY from_type
ORDER BY high_avg_score DESC
LIMIT 1;


-- Prompt 19: Find the number of relationships that user  with id == 1 is not part of.
SELECT COUNT(*) AS relationships_without_user1
FROM facebook_friends
WHERE user1 <> 1
    AND user2 <> 1;


-- Prompt 20: Find the total number of searches for houses in Westlake neighborhood with a TV among the amenities.
SELECT COUNT(id) AS n_searches
FROM airbnb_search_details
WHERE property_type = 'House'
    AND neighbourhood = 'Westlake'
    AND amenities LIKE '%TV%';


-- Prompt 21: Find the gender that has made the most number of doctor appointments.
-- Output the gender along with the corresponding number of appointments.
SELECT
    gender,
    COUNT(appointmentid) AS n_appointments
FROM medical_appointments
GROUP BY gender
HAVING gender = 'F';


-- Prompt 22: Find the total number of records that belong to each variety in the dataset.
-- Output the variety along with the corresponding number of records. Order records by the variety in ascending order.
SELECT
    variety,
    COUNT(*)
FROM iris
GROUP BY variety;


-- Prompt 23: Find the total number of housing units completed for each year.
-- Output the year along with the total number of housings. Order the result by year in ascending order.
SELECT DISTINCT
    year,
    SUM(south + west + midwest + northeast) AS total_n_housings
FROM housing_units_completed_us
GROUP BY year
ORDER BY year ASC;


-- Prompt 24: Find how many reviews exist for each review score given to 'Hotel Arena'.
-- Output the hotel name ('Hotel Arena'), each review score, and the number of reviews for that score.
SELECT
    hotel_name,
    reviewer_score,
    COUNT(reviewer_score) AS score_count
FROM hotel_reviews
WHERE lower(hotel_name) = 'hotel arena'
GROUP BY hotel_name,
    reviewer_score;


-- Prompt 25: Find the total AdWords earnings for each business type.
-- Output the business types along with the total earnings.
SELECT
    business_type,
    SUM(adwords_earnings) AS total_earnings
FROM google_adwords_earnings
GROUP BY business_type;


-- Prompt 26: Find the number of Yelp businesses that sell pizza.
SELECT
    COUNT(business_id) AS n_of_businesses
FROM yelp_business
WHERE categories LIKE '%pizza%';


-- Prompt 27: Find employees who started in June and have even-numbered employee IDs.
SELECT *
FROM worker
WHERE joining_date >= '2014-06-01'
  AND joining_date < '2014-07-01'
  AND worker_id % 2 = 0;


-- Prompt 28: Find employees who started in February and have odd-numbered employee IDs.
SELECT *
FROM worker
WHERE joining_date >= '2014-02-01'
  AND joining_date < '2014-03-01'
  AND worker_id % 2 = 1;


-- Prompt 29: Find the number of crime occurrences for each day of the week.
-- Output the day alongside the corresponding crime count.
SELECT
    day_of_week,
    COUNT(incidnt_num) AS n_of_occurrences
FROM sf_crime_incidents_2014_01
GROUP BY day_of_week;


-- Prompt 30: What is the total sales revenue of Samantha and Lisa?
SELECT
    SUM(sales_revenue) AS total_revenue
FROM sales_performance
WHERE salesperson = 'Samantha'
   OR salesperson = 'Lisa';
