-- Prompt 1: Identify the highest-paid job title within each department based on average base salary.
-- Context: Created for a compensation analysis project to support internal salary benchmarking.
WITH avg_salary AS (
    SELECT
        department,
        job_title,
        ROUND(AVG(base_salary)) AS avg_base_salary
    FROM employee_compensation
    GROUP BY
        department,
        job_title
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


-- Prompt 2: You are provided with an already aggregated dataset from Amazon that contains detailed information about sales across different products and marketplaces.
-- List the top 3 sellers in each product category for January. In case of ties, rank them the same and include all sellers tied for that position.
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


-- Prompt 4: Management wants to analyze only employees with official job titles.
-- Find the job titles of the employees with the highest salary.
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


-- Prompt 5: Count the number of unique users per day who logged in from either a mobile device or web.
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


-- Prompt 6: Return the total number of comments received for each user in the 30-day period up to and including 2020-02-10.
SELECT
    user_id,
    SUM(number_of_comments) AS number_of_comments
FROM fb_comments_count
WHERE created_at >= '2020-02-10' - INTERVAL 30 DAY
  AND created_at <= '2020-02-10'
GROUP BY user_id;


-- Prompt 7: Measure pay variability for the Data Engineer role.
-- Context: Created for a compensation analysis project to support internal salary benchmarking.
SELECT
    job_title,
    MAX(base_salary) - MIN(base_salary) AS salary_range,
    ROUND(AVG(base_salary)) AS avg_salary,
    ROUND(STDDEV(base_salary)) AS salary_std_dev
FROM employee_compensation
WHERE lower(job_title) = 'data engineer'
GROUP BY job_title;


-- Prompt 8: Calculate the average score for each project, but only include projects where more than one team member has provided a score.
SELECT
    project_id,
    AVG(score) AS avg_score
FROM project_data
GROUP BY project_id
HAVING COUNT(DISTINCT team_member_id) > 1;


-- Prompt 9: Count the unique activity types for each user, ensuring users with no activities are also included.
SELECT
    u.user_id,
    COUNT(DISTINCT a.activity_type) AS n_activities
FROM user_profiles AS u
LEFT JOIN activity_log AS a
    ON u.user_id = a.user_id
GROUP BY u.user_id;


-- Prompt 10: Analyze user listening habits.
-- Calculate total listening time (minutes) and unique song count per user.
SELECT
    user_id,
    ROUND(SUM(listen_duration) / 60.0) AS total_listen_duration,
    COUNT(DISTINCT song_id) AS unique_song_count
FROM listening_habits
GROUP BY user_id;


-- Prompt 11: Find the average number of bathrooms and bedrooms for each city’s property types.
SELECT
    city,
    property_type,
    AVG(bathrooms) AS avg_n_bathrooms,
    AVG(bedrooms) AS avg_n_bedrooms
FROM airbnb_search_details
GROUP BY
    city,
    property_type;


-- Prompt 12: Find all the songs that were top-ranked (at first position) at least once since the year 2005.
SELECT DISTINCT
    song_name
FROM billboard_top_100_year_end
WHERE year_rank = 1
  AND year >= 2005;


-- Prompt 13: Find the details of each customer regardless of whether the customer made an order.
SELECT
    c.first_name,
    c.last_name,
    c.city,
    o.order_details
FROM customers AS c
LEFT JOIN orders AS o
    ON c.id = o.cust_id
ORDER BY
    c.first_name,
    o.order_details ASC;


-- Prompt 14: Find doctors with the last name of 'Johnson' in the employee list.
SELECT
    first_name,
    last_name
FROM employee_list
WHERE lower(last_name) = 'johnson'
  AND lower(profession) = 'doctor';
