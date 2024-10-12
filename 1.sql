CREATE DATABASE pizza_runner;

USE pizza_runner;

CREATE SCHEMA IF NOT EXISTS pizza_runner;
USE pizza_runner;

-- Create 'runners' table
DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INT,
  registration_date DATE
);

INSERT INTO runners (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');

-- Create 'customer_orders' table
DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INT,
  customer_id INT,
  pizza_id INT,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);


INSERT INTO customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES 
  (1, 101, 1, '', '', '2020-01-01 18:05:02'),
  (2, 101, 1, '', '', '2020-01-01 19:00:52'),
  (3, 102, 1, '', '', '2020-01-02 23:51:23'),
  (3, 102, 2, '', NULL, '2020-01-02 23:51:23'),
  (4, 103, 1, '4', '', '2020-01-04 13:23:46'),
  (4, 103, 1, '4', '', '2020-01-04 13:23:46'),
  (4, 103, 2, '4', '', '2020-01-04 13:23:46'),
  (5, 104, 1, NULL, '1', '2020-01-08 21:00:29'),
  (6, 101, 2, NULL, NULL, '2020-01-08 21:03:13'),
  (7, 105, 2, NULL, '1', '2020-01-08 21:20:29'),
  (8, 102, 1, NULL, NULL, '2020-01-09 23:54:33'),
  (9, 103, 1, '4', '1,5', '2020-01-10 11:22:59'),
  (10, 104, 1, NULL, NULL, '2020-01-11 18:34:49'),
  (10, 104, 1, '2,6', '1,4', '2020-01-11 18:34:49');

-- Create 'runner_orders' table
DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INT,
  runner_id INT,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  (1, 1, '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  (2, 1, '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  (3, 1, '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  (4, 2, '2020-01-04 13:53:03', '23.4', '40', NULL),
  (5, 3, '2020-01-08 21:10:57', '10', '15', NULL),
  (6, 3, NULL, NULL, NULL, 'Restaurant Cancellation'),
  (7, 2, '2020-01-08 21:30:45', '25km', '25mins', NULL),
  (8, 2, '2020-01-10 00:15:02', '23.4 km', '15 minute', NULL),
  (9, 2, NULL, NULL, NULL, 'Customer Cancellation'),
  (10, 1, '2020-01-11 18:50:20', '10km', '10minutes', NULL);

-- Create 'pizza_names' table
DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INT,
  pizza_name TEXT
);

INSERT INTO pizza_names (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');

-- Create 'pizza_recipes' table
DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INT,
  toppings TEXT
);

INSERT INTO pizza_recipes (pizza_id, toppings)
VALUES
  (1, '1,2,3,4,5,6,8,10'),
  (2, '4,6,7,9,11,12');

-- Create 'pizza_toppings' table
DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INT,
  topping_name TEXT
);

INSERT INTO pizza_toppings (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
  -- Checking all the data
  
  SELECT * FROM customer_orders;
  SELECT * FROM pizza_names;
  SELECT * FROM pizza_recipes;
  SELECT * FROM pizza_toppings;
  SELECT * FROM runner_orders;
  SELECT * FROM runners;
  
-- ** Data Cleaning ** --

-- Data cleaning is required in customer_orders and runner_orders tables.
  
  -- 1. Cleaning customer_orders table
  
SELECT * FROM customer_orders;
  
-- Replacing blanks with NULL.
  
UPDATE customer_orders
SET exclusions = NULL
WHERE exclusions = '' ;

UPDATE customer_orders
SET extras = NULL
WHERE extras = '' ;

SELECT * FROM customer_orders;
  
-- 2. Cleaning runner_orders table

SELECT * FROM runner_orders;

-- Replacing 'km' with '' so that the column can be converted to a float later and triming the data to replace white spaces.
UPDATE runner_orders
SET distance = replace(distance, 'km', '');

UPDATE runner_orders
SET distance = TRIM(distance);

SELECT * FROM runner_orders;

-- Replacing all instances of 'minutes', 'minute' and 'mins' with '', this can be done in multiple steps or in a single steps using nested replace query like below
-- and triming the data to replace white spaces.
UPDATE runner_orders
SET duration = replace(replace(replace(duration, 'minutes', ''), 'minute', ''), 'mins', '');
-- Above query can also be done using CASE statements.

UPDATE runner_orders
SET duration = TRIM(duration);

-- Replacing all blanks with NULL values in cancellation.
UPDATE runner_orders
SET cancellation = NULL
WHERE cancellation = '';

SELECT * FROM runner_orders;

-- Changing data type of pickup_time to timestamp, distance to decimal(5,1), duration to int.

ALTER TABLE runner_orders
MODIFY COLUMN pickup_time DATETIME,
MODIFY COLUMN distance DECIMAL(5,1),
MODIFY COLUMN duration INT;

SELECT * FROM runner_orders;


-- Normalize pizza_recipes by creating a new table linking pizza_id and individual topping_id
CREATE TABLE pizza_recipe_toppings (
    pizza_id INT,
    topping_id INT,
    PRIMARY KEY (pizza_id, topping_id)
);

-- Insert values from pizza_recipes into the new table (splitting by commas)
INSERT INTO pizza_recipe_toppings (pizza_id, topping_id)
VALUES 
    (1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 8), (1, 10),
    (2, 4), (2, 6), (2, 7), (2, 9), (2, 11), (2, 12);


-- ** Analytics ** --

-- *A. Pizza Metrics* --

-- 1. How many pizzas were ordered?

SELECT COUNT(*) AS total_pizza_ordered
FROM customer_orders;

-- 2. How many unique customer orders were made?

SELECT COUNT(DISTINCT(order_id)) AS unique_orders
FROM customer_orders;

-- 3. How many successful orders were delivered by each runner?

SELECT runner_id, COUNT(*) AS succesful_orders
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY 1;


-- 4. How many of each type of pizza was delivered?

SELECT o.pizza_id,pn.pizza_name,  COUNT(*) AS total_delivered
FROM runner_orders r
JOIN customer_orders o
ON o.order_id = r.order_id
JOIN pizza_names pn
ON o.pizza_id = pn.pizza_id
WHERE cancellation IS NULL
GROUP BY 1, 2;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT o.customer_id,pn.pizza_name, COUNT(*) AS total_pizza_category_ordered
FROM customer_orders o
JOIN pizza_names pn
ON o.pizza_id = pn.pizza_id
GROUP BY 1, 2
ORDER BY 1;

-- 6. What was the maximum number of pizzas delivered in a single order?

SELECT o.order_id, COUNT(*) AS max_num_pizza_delivered
FROM runner_orders r
JOIN customer_orders o
ON o.order_id = r.order_id
WHERE cancellation IS NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 7.  For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT o.customer_id, 
			SUM(CASE WHEN exclusions IS NOT  NULL OR extras IS NOT  NULL THEN 1 ELSE 0 END) AS total_changed_pizza_delivered,
			SUM(CASE WHEN exclusions IS NULL AND extras IS NULL THEN 1 ELSE 0 END)AS total_unchanged_pizza_delivered
FROM runner_orders r
JOIN customer_orders o
ON o.order_id = r.order_id
WHERE r.cancellation IS NULL 
GROUP BY 1;


-- 8. How many pizzas were delivered that had both exclusions and extras?

SELECT COUNT(*) AS total_pizzas_with_exclusion_and_inclusion
FROM runner_orders r
JOIN customer_orders o
ON o.order_id = r.order_id
WHERE r.cancellation IS NULL AND exclusions IS NOT  NULL AND extras IS NOT  NULL;

-- 9.  What was the total volume of pizzas ordered for each hour of the day?

SELECT HOUR(order_time) AS hour_of_day, COUNT(*) AS total_pizzas
FROM customer_orders
GROUP BY 1
ORDER BY 1;


-- 10. What was the volume of orders for each day of the week?

SELECT DAYNAME(order_time) AS day_of_week, COUNT(*) AS total_pizzas
FROM customer_orders
GROUP BY 1
ORDER BY 1;

-- *B. Runner and Customer Experience* --


-- B1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT WEEK(registration_date, 1) AS week_, COUNT(*) AS total_runner_signed_up 
FROM runners
GROUP BY 1;

-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

SELECT runner_id, ROUND(AVG(MINUTE(TIMEDIFF(pickup_time, order_time))),2) AS avg_pickup_time
FROM customer_orders c
LEFT JOIN runner_orders r
	ON c.order_id = r.order_id
GROUP BY 1;

-- Is there any relationship between the number of pizzas and how long the order takes to prepare?

SELECT c.order_id, COUNT(*) AS total_pizzas, ROUND(AVG(MINUTE(TIMEDIFF(pickup_time, order_time))),2) AS avg_pickup_time
FROM customer_orders c
LEFT JOIN runner_orders r
	ON c.order_id = r.order_id
GROUP  BY 1;

SELECT *
FROM runner_orders;

-- What was the average distance travelled for each customer?

SELECT c.customer_id, ROUND(AVG(distance),2) AS avg_distance_in_km
FROM customer_orders c
JOIN runner_orders r
ON c.order_id = r.order_id
WHERE distance IS NOT NULL
GROUP BY c.customer_id;

-- What was the difference between the longest and shortest delivery times for all orders?

SELECT (MAX(duration) - MIN(duration)) AS diff
FROM runner_orders;

-- What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT runner_id, c.order_id,  ROUND(AVG(distance/(duration/60)),1) AS avg_speed_km_per_hr
FROM customer_orders c
JOIN runner_orders r
ON c.order_id = r.order_id
WHERE duration IS NOT NULL
GROUP BY c.order_id,r.runner_id
ORDER BY runner_id ;


-- What is the successful delivery percentage for each runner?

SELECT runner_id, 
			ROUND(100 * SUM(CASE WHEN cancellation IS NULL THEN 1 ELSE 0 END)/ COUNT(*),0)  AS succesful_deliveries_percentage
FROM runner_orders
GROUP BY 1;

-- ** C. Ingredient Optimisation** --

-- C1. What are the standard ingredients for each pizza?

SELECT pizza_id, GROUP_CONCAT(topping_name SEPARATOR ', ') AS standard_ingridients
FROM pizza_recipe_toppings p
JOIN pizza_toppings pt
ON pt.topping_id = p.topping_id
GROUP BY pizza_id;

-- C2. What was the most commonly added extra?

SELECT pt.topping_name, COUNT(*) AS extras_count
FROM customer_orders co
JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, co.extras)
GROUP BY 1
ORDER BY 2 DESC;


-- What was the most common exclusion?

SELECT pt.topping_name, COUNT(*) AS exclusion_counts
FROM customer_orders co
JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, co.exclusions)
GROUP BY 1
ORDER BY 2 DESC;

