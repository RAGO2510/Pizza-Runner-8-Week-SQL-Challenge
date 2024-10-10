# Pizza-Runner-8-Week-SQL-Challenge

![2](https://github.com/user-attachments/assets/bf925c46-14ab-44f0-9419-fc82d8f0820c)

## Business Task

Danny is expanding his new Pizza Empire and at the same time, he wants to Uberize it, so Pizza Runner was launched!

Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.

## ER Diagram

![Er](https://github.com/user-attachments/assets/f2ebc920-5a2f-4805-84fe-26a86e31058b)


## Data Cleaning & Transformation
Table: customer_orders

Looking at the customer_orders table below, we can see that there are

In the exclusions column, there are missing/ blank spaces ' ' and null values.
In the extras column, there are missing/ blank spaces ' ' and null values.

![Cust_orders](https://github.com/user-attachments/assets/3f34cd1a-6349-419f-b155-d96a2dd10313)

-- Replacing blanks with NULL.
  
UPDATE customer_orders
SET exclusions = NULL
WHERE exclusions = '' ;

UPDATE customer_orders
SET extras = NULL
WHERE extras = '' ;

Table: Cleaning runner_orders table

SELECT * FROM runner_orders;

![Cust_orders](https://github.com/user-attachments/assets/a400a600-ca0b-44fc-9173-8b07bc891f44)

-- Replacing 'km' with '' so that the column can be converted to a float later and triming the data to replace white spaces.

UPDATE runner_orders
SET distance = replace(distance, 'km', '');

UPDATE runner_orders
SET distance = TRIM(distance);

SELECT * FROM runner_orders;

-- Replacing all instances of 'minutes', 'minute' and 'mins' with '', this can be done in multiple steps or in a single steps using nested replace query like belo and triming the data to replace white spaces.

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


-- Normalize pizza_recipes by creating a new table linking pizza_id and individual topping_id.

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

# Analytics 

-- *A. Pizza Metrics* --

-- 1. How many pizzas were ordered?

SELECT COUNT(*) AS total_pizza_ordered
FROM customer_orders;

![A1](https://github.com/user-attachments/assets/52188ffb-fca6-4596-8b7e-cca056b73e5a)



-- 2. How many unique customer orders were made?

SELECT COUNT(DISTINCT(order_id)) AS unique_orders
FROM customer_orders;

![A2](https://github.com/user-attachments/assets/e03bed2f-863d-47cf-8f38-96ff752f3d0f)


-- 3. How many successful orders were delivered by each runner?

SELECT runner_id, COUNT(*) AS succesful_orders
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY 1;

![A3](https://github.com/user-attachments/assets/039e4ca3-b5e9-41f8-b331-d1ca34e4809c)



-- 4. How many of each type of pizza was delivered?

SELECT o.pizza_id,pn.pizza_name,  COUNT(*) AS total_delivered
FROM runner_orders r
JOIN customer_orders o
ON o.order_id = r.order_id
JOIN pizza_names pn
ON o.pizza_id = pn.pizza_id
WHERE cancellation IS NULL
GROUP BY 1, 2;

![A4](https://github.com/user-attachments/assets/671f37f1-7dfa-4a04-bae6-b98a08fd00b5)


-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT o.customer_id,pn.pizza_name, COUNT(*) AS total_pizza_category_ordered
FROM customer_orders o
JOIN pizza_names pn
ON o.pizza_id = pn.pizza_id
GROUP BY 1, 2
ORDER BY 1;

![A5](https://github.com/user-attachments/assets/00ed541d-11ca-41d7-9c2c-046337aa97a6)


-- 6. What was the maximum number of pizzas delivered in a single order?

SELECT o.order_id, COUNT(*) AS max_num_pizza_delivered
FROM runner_orders r
JOIN customer_orders o
ON o.order_id = r.order_id
WHERE cancellation IS NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

![A6](https://github.com/user-attachments/assets/35daa2f4-c579-469d-91ab-123cd4be973d)


-- 7.  For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT o.customer_id, 
			SUM(CASE WHEN exclusions IS NOT  NULL OR extras IS NOT  NULL THEN 1 ELSE 0 END) AS total_changed_pizza_delivered,
			SUM(CASE WHEN exclusions IS NULL AND extras IS NULL THEN 1 ELSE 0 END)AS total_unchanged_pizza_delivered
FROM runner_orders r
JOIN customer_orders o
ON o.order_id = r.order_id
WHERE r.cancellation IS NULL 
GROUP BY 1;

![A7](https://github.com/user-attachments/assets/f3672808-c76c-4886-87aa-6b8512d25e4d)



-- 8. How many pizzas were delivered that had both exclusions and extras?

SELECT COUNT(*) AS total_pizzas_with_exclusion_and_inclusion
FROM runner_orders r
JOIN customer_orders o
ON o.order_id = r.order_id
WHERE r.cancellation IS NULL AND exclusions IS NOT  NULL AND extras IS NOT  NULL;

![A8](https://github.com/user-attachments/assets/449a2654-1c6a-47b5-8262-6b47a8b95865)


-- 9.  What was the total volume of pizzas ordered for each hour of the day?

SELECT HOUR(order_time) AS hour_of_day, COUNT(*) AS total_pizzas
FROM customer_orders
GROUP BY 1
ORDER BY 1;

![A9](https://github.com/user-attachments/assets/d7bd005c-d274-4df1-8c0c-e246069becea)



-- 10. What was the volume of orders for each day of the week?

SELECT DAYNAME(order_time) AS day_of_week, COUNT(*) AS total_pizzas
FROM customer_orders
GROUP BY 1
ORDER BY 1;

![A10](https://github.com/user-attachments/assets/3ffa2e97-c4bd-4783-84f6-4443a07fd84a)


-- *B. Runner and Customer Experience* --


-- B1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT WEEK(registration_date, 1) AS week_, COUNT(*) AS total_runner_signed_up 
FROM runners
GROUP BY 1;

![B1](https://github.com/user-attachments/assets/154895c4-e354-45c8-8583-88ce459e94c5)


--B2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

SELECT runner_id, ROUND(AVG(MINUTE(TIMEDIFF(pickup_time, order_time))),2) AS avg_pickup_time
FROM customer_orders c
LEFT JOIN runner_orders r
	ON c.order_id = r.order_id
GROUP BY 1;

![B2](https://github.com/user-attachments/assets/a644cba0-fbd4-44f1-b917-b23e945a5041)



-- B3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

SELECT c.order_id, COUNT(*) AS total_pizzas, ROUND(AVG(MINUTE(TIMEDIFF(pickup_time, order_time))),2) AS avg_pickup_time
FROM customer_orders c
LEFT JOIN runner_orders r
	ON c.order_id = r.order_id
GROUP  BY 1;

![B3](https://github.com/user-attachments/assets/8adb10c1-105c-4410-a501-c3d84f098a6c)


-- B4. What was the average distance travelled for each customer?

SELECT c.customer_id, ROUND(AVG(distance),2) AS avg_distance_in_km
FROM customer_orders c
JOIN runner_orders r
ON c.order_id = r.order_id
WHERE distance IS NOT NULL
GROUP BY c.customer_id;

![B4](https://github.com/user-attachments/assets/6c223126-32b3-49c9-822c-c18286e51880)


-- B5. What was the difference between the longest and shortest delivery times for all orders?

SELECT (MAX(duration) - MIN(duration)) AS diff
FROM runner_orders;

![B5](https://github.com/user-attachments/assets/4a1ba04c-4831-4959-895a-82e27e78c0fa)


-- B6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT runner_id, c.order_id,  ROUND(AVG(distance/(duration/60)),1) AS avg_speed_km_per_hr
FROM customer_orders c
JOIN runner_orders r
ON c.order_id = r.order_id
WHERE duration IS NOT NULL
GROUP BY c.order_id,r.runner_id
ORDER BY runner_id ;

![B6](https://github.com/user-attachments/assets/30896d2d-f374-4604-8ed0-68dcf394ccfa)



-- B7. What is the successful delivery percentage for each runner?

SELECT runner_id, 
			ROUND(100 * SUM(CASE WHEN cancellation IS NULL THEN 1 ELSE 0 END)/ COUNT(*),0)  AS succesful_deliveries_percentage
FROM runner_orders
GROUP BY 1;


-- ** C. Ingredient Optimisation** --

-- What are the standard ingredients for each pizza?

SELECT pizza_id, GROUP_CONCAT(topping_name SEPARATOR ', ') AS standard_ingridients
FROM pizza_recipe_toppings p
JOIN pizza_toppings pt
ON pt.topping_id = p.topping_id
GROUP BY pizza_id;

-- What was the most commonly added extra?

SELECT *
FROM customer_orders c
JOIN pizza_toppings pt
ON pt.topping_id = c.extras
WHERE c.extras IS NOT NULL;
