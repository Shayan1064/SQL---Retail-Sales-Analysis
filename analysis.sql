
  --   ************* Retail Sales SQL Project (Shayan Hassan) **************


-- Create database
CREATE DATABASE p1_retail_db;

-- Create retail_sales table
CREATE TABLE retail_sales
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,
    cogs FLOAT,
    total_sale FLOAT
);


-- 1. DATA EXPLORATION & CLEANING


-- Total number of transactions
SELECT COUNT(*) FROM retail_sales;

-- Total unique customers
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;

-- List of unique product categories
SELECT DISTINCT category FROM retail_sales;

-- Check rows with missing values
SELECT *
FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;

-- Delete rows with missing values
DELETE FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;


-- 2. DATA ANALYSIS & BUSINESS INSIGHTS


-- Sales made on 2022-11-05
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Clothing sales (quantity >= 4) in Nov 2022
SELECT *
FROM retail_sales
WHERE 
    category = 'Clothing'
    AND EXTRACT(YEAR FROM sale_date) = 2022
    AND EXTRACT(MONTH FROM sale_date) = 11
    AND quantity >= 4;

-- Total sales and total orders by category
SELECT 
    category,
    SUM(total_sale) AS net_sale,
    COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category;

-- Average age of customers in Beauty category
SELECT
    ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';

-- Transactions with total sale greater than 1000
SELECT *
FROM retail_sales
WHERE total_sale > 1000;

-- Total transactions by gender in each category
SELECT 
    category,
    gender,
    COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY category;

-- Best selling month highest average sale in each year
SELECT 
    year,
    month,
    avg_sale
FROM 
(    
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        AVG(total_sale) AS avg_sale,
        RANK() OVER(
            PARTITION BY EXTRACT(YEAR FROM sale_date) 
            ORDER BY AVG(total_sale) DESC
        ) AS rank
    FROM retail_sales
    GROUP BY 1, 2
) AS t1
WHERE rank = 1;

-- Top 5 customers based on highest total sales
SELECT 
    customer_id,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;

-- Unique customers per category
SELECT 
    category,    
    COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category;

-- Number of orders by sales shift (Morning, Afternoon, Evening)
WITH hourly_sale AS
(
    SELECT *,
        CASE
            WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS shift
    FROM retail_sales
)
SELECT 
    shift,
    COUNT(*) AS total_orders    
FROM hourly_sale
GROUP BY shift;
