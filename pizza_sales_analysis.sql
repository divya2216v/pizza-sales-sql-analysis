-- =========================================
-- PIZZA SALES DATA ANALYSIS
-- =========================================

-- BASIC QUESTIONS

-- 1. Retrieve the total number of orders placed
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM orders;

-- 2. Calculate the total revenue generated from pizza sales
SELECT SUM(quantity * price) AS total_revenue
FROM order_details
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id;

-- 3. Identify the highest-priced pizza
SELECT name, price
FROM pizzas
ORDER BY price DESC
LIMIT 1;

-- 4. Identify the most common pizza size ordered
SELECT size, COUNT(*) AS order_count
FROM pizzas
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY size
ORDER BY order_count DESC
LIMIT 1;

-- 5. List the top 5 most ordered pizza types along with their quantities
SELECT pt.name, SUM(od.quantity) AS total_quantity
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;

-- =========================================
-- INTERMEDIATE QUESTIONS
-- =========================================

-- 6. Total quantity of each pizza category ordered
SELECT pt.category, SUM(od.quantity) AS total_quantity
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.category;

-- 7. Distribution of orders by hour of the day
SELECT HOUR(order_time) AS order_hour,
       COUNT(order_id) AS total_orders
FROM orders
GROUP BY order_hour
ORDER BY order_hour;

-- 8. Category-wise distribution of pizzas
SELECT pt.category, COUNT(*) AS pizza_count
FROM pizza_types pt
GROUP BY pt.category;

-- 9. Average number of pizzas ordered per day
SELECT ROUND(AVG(daily_quantity), 0) AS avg_pizzas_per_day
FROM (
    SELECT o.order_date, SUM(od.quantity) AS daily_quantity
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date
) t;

-- 10. Top 3 most ordered pizza types based on revenue
SELECT pt.name, SUM(od.quantity * p.price) AS revenue
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

-- =========================================
-- ADVANCED QUESTIONS
-- =========================================

-- 11. Percentage contribution of each pizza type to total revenue
SELECT pt.name,
       ROUND(
           (SUM(od.quantity * p.price) /
           (SELECT SUM(quantity * price)
            FROM order_details
            JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id)) * 100, 2
       ) AS revenue_percentage
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY revenue_percentage DESC;

-- 12. Cumulative revenue generated over time
SELECT order_date,
       SUM(daily_revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM (
    SELECT o.order_date,
           SUM(od.quantity * p.price) AS daily_revenue
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    GROUP BY o.order_date
) t;

-- 13. Top 3 pizza types based on revenue for each category
SELECT category, name, revenue
FROM (
    SELECT pt.category,
           pt.name,
           SUM(od.quantity * p.price) AS revenue,
           RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS rn
    FROM pizza_types pt
    JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
    JOIN order_details od ON p.pizza_id = od.pizza_id
    GROUP BY pt.category, pt.name
) t
WHERE rn <= 3;
