-- Prompt 1: Identify the highest-paid job title within each department based on average base salary.
-- Context: Created for a compensation analysis project to support internal salary benchmarking.
WITH avg_salary AS (
    SELECT
        department,
        job_title,
        ROUND(AVG(base_salary)) AS avg_base_salary
    FROM employee_compensation
    GROUP BY department, job_title
),
ranked_titles AS (
    SELECT
        department,
        job_title,
        avg_base_salary,
        RANK() OVER (
            PARTITION BY department
            ORDER BY avg_base_salary DESC
        ) AS rnk
    FROM avg_salary
)
SELECT
    department,
    job_title,
    avg_base_salary
FROM ranked_titles
WHERE rnk = 1
ORDER BY avg_base_salary DESC;


-- Prompt 2: List the top 3 sellers in each product category for January, including ties.
-- Output seller_id, total_sales, product_category, market_place, and sales_date.
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


-- Prompt 3: Find athletes who competed for different countries across multiple Olympic games.
-- Return all competition records for athletes who represented more than one country.
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


-- Prompt 4: Order all countries by the year they first participated in the Olympics.
-- Output NOC and year; sort by year ASC, then NOC ASC.
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


-- Prompt 5: Find the job titles of employees with the highest salary.
-- Include all titles if multiple employees share the highest salary.
WITH ranked_titles AS (
    SELECT
        t.worker_title,
        RANK() OVER (
            ORDER BY w.salary DESC
        ) AS highest_salary
    FROM worker AS w
    INNER JOIN title AS t
        ON w.worker_id = t.worker_ref_id
)
SELECT
    worker_title
FROM ranked_titles
WHERE highest_salary = 1;


-- Prompt 6: Count the number of unique users per day who logged in from mobile or web.
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


-- Prompt 7: Return the total number of comments received per user in the 30-day period ending 2020-02-10.
-- Exclude users with no comments in this time period.
SELECT
    user_id,
    SUM(number_of_comments) AS number_of_comments
FROM fb_comments_count
WHERE created_at >= '2020-02-10' - INTERVAL 30 DAY
  AND created_at <= '2020-02-10'
GROUP BY user_id;


-- Prompt 8: Measure pay variability for the Data Engineer role.
-- Context: Created for a compensation analysis project to support internal salary benchmarking.
SELECT
    job_title,
    MAX(base_salary) - MIN(base_salary) AS salary_range,
    ROUND(AVG(base_salary)) AS avg_salary,
    ROUND(STDDEV(base_salary)) AS salary_std_dev
FROM employee_compensation
WHERE lower(job_title) = 'data engineer'
GROUP BY job_title;


-- Prompt 9: Calculate the average score per project with more than one team member.
-- Output project_id and the calculated average score.
SELECT
    project_id,
    AVG(score) AS avg_score
FROM project_data
GROUP BY project_id
HAVING COUNT(DISTINCT team_member_id) > 1;


-- Prompt 10: Count unique activity types per user, including users with no activity.
-- Output each user_id and their activity type count.
SELECT
    u.user_id,
    COUNT(DISTINCT a.activity_type) AS n_activities
FROM user_profiles AS u
LEFT JOIN activity_log AS a
    ON u.user_id = a.user_id
GROUP BY u.user_id;


-- Prompt 11: Calculate total listening time (minutes) and unique song count per user.
-- Round total listening duration to the nearest whole minute.
SELECT
    user_id,
    ROUND(SUM(listen_duration) / 60.0) AS total_listen_duration,
    COUNT(DISTINCT song_id) AS unique_song_count
FROM listening_habits
GROUP BY user_id;


-- Prompt 12: Find average bathrooms and bedrooms by city and property type.
-- Output city, property_type, avg bathrooms, and avg bedrooms.
SELECT
    city,
    property_type,
    AVG(bathrooms) AS avg_n_bathrooms,
    AVG(bedrooms) AS avg_n_bedrooms
FROM airbnb_search_details
GROUP BY city, property_type;


-- Prompt 13: Find songs that ranked #1 at least once since 2005.
-- Output distinct song names only.
SELECT DISTINCT
    song_name
FROM billboard_top_100_year_end
WHERE year_rank = 1
  AND year >= 2005;


-- Prompt 14: Find customer details regardless of whether an order was made.
-- Sort by customer first name and order details in ascending order.
SELECT
    c.first_name,
    c.last_name,
    c.city,
    o.order_details
FROM customers AS c
LEFT JOIN orders AS o
    ON c.id = o.cust_id
ORDER BY c.first_name, o.order_details ASC;


-- Prompt 15: Find doctors with the last name 'Johnson' in the employee list.
-- Output first and last names only.
SELECT
    first_name,
    last_name
FROM employee_list
WHERE lower(last_name) = 'johnson'
  AND lower(profession) = 'doctor';
