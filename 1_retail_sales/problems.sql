
-- Data exploration and cleaning
-- Record Count: Determine the total number of records in the dataset.
SELECT COUNT(*) FROM retail_sales;

-- Customer Count: Find out how many unique customers are in the dataset.
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;

-- Category Count: Identify all unique product categories in the dataset.
SELECT DISTINCT category FROM retail_sales;

-- Null Value Check: Check for any null values in the dataset and delete records with missing data.
SELECT * FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;

DELETE FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;


-- Analyze sales patterns by day of the week to see which days are performing best
SELECT 
    TO_CHAR(sale_date, 'Day') AS day_of_week,
    SUM(total_sale) AS weekly_sales
FROM retail_sales
GROUP BY TO_CHAR(sale_date, 'Day')
ORDER BY weekly_sales DESC;


--retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022:
SELECT 
  *
FROM retail_sales
WHERE 
    category = 'Clothing'
    AND 
    TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
    AND
    quantity >= 4

-- Alternative 
SELECT *
FROM retail_sales
WHERE category = 'Clothing'
  AND EXTRACT(YEAR FROM sale_date) = 2022
  AND EXTRACT(MONTH FROM sale_date) = 11
  AND quantity >= 4;


-- calculate the total sales adn average sales for each category.
SELECT 
    category,
    SUM(total_sale) AS net_sale,
    AVG(total_sale) AS avg_sale,
    COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category;


-- find the average age of customers who purchased items from the 'Beauty' category.:
SELECT
    ROUND(AVG(age), 2) as avg_age
FROM retail_sales
WHERE category = 'Beauty'


-- find all transactions where the total_sale is greater than 1000.
SELECT * FROM retail_sales
WHERE total_sale > 1000


-- find the total number of transactions (transaction_id) made by each gender in each category.:
SELECT 
    category,
    gender,
    COUNT(*) as total_trans
FROM retail_sales
GROUP 
    BY 
    category,
    gender
ORDER BY 1


-- calculate the average sale for each month. Find out best selling month in each year:
SELECT 
       year,
       month,
    avg_sale
FROM 
(    
SELECT 
    EXTRACT(YEAR FROM sale_date) as year,
    EXTRACT(MONTH FROM sale_date) as month,
    AVG(total_sale) as avg_sale,
    RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) as rank
FROM retail_sales
GROUP BY 1, 2
) as t1
WHERE rank = 1

-- find the top 5 customers based on the highest total sales **:
SELECT 
    customer_id,
    SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5


-- number of unique customers who purchased items from each category.:
SELECT 
    category,    
    COUNT(DISTINCT customer_id) as unique_customers
FROM retail_sales
GROUP BY category

-- identify customers who have made multiple purchases and count how many times each customer has shopped.
SELECT 
    customer_id,
    COUNT(*) AS purchase_count
FROM retail_sales
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY purchase_count DESC;

-- distinguish between new and returning customers by tagging customers with only one transaction as “new” and others as “returning.
SELECT 
    CASE WHEN purchase_count = 1 THEN 'New' ELSE 'Returning' END AS customer_type,
    COUNT(*) AS num_customers
FROM (
    SELECT customer_id, COUNT(*) AS purchase_count
    FROM retail_sales
    GROUP BY customer_id
) AS customer_summary
GROUP BY customer_type;


-- create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17):
WITH hourly_sale
AS
(
SELECT *,
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END as shift
FROM retail_sales
)
SELECT 
    shift,
    COUNT(*) as total_orders    
FROM hourly_sale
GROUP BY shift

-- Alternative
SELECT
    SUM(CASE WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 1 ELSE 0 END) AS morning_orders,
    SUM(CASE WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 1 ELSE 0 END) AS afternoon_orders,
    SUM(CASE WHEN EXTRACT(HOUR FROM sale_time) > 17 THEN 1 ELSE 0 END) AS evening_orders
FROM retail_sales;

-- Calculate the profit margin for each sale and then analyze the average margin by product category.
SELECT 
    category,
    ROUND(AVG((total_sale - cogs) / total_sale * 100)::numeric, 2) AS avg_profit_margin
FROM retail_sales
GROUP BY category
ORDER BY avg_profit_margin DESC;


-- Segment customers into age groups (for example, <20, 20-29, 30-39, etc.) and calculate the average spending per group.
SELECT 
    CASE
        WHEN age < 20 THEN '<20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50+'
    END AS age_group,
    ROUND(AVG(total_sale)::numeric, 2) AS avg_spending,
    COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY age_group
ORDER BY avg_spending DESC;

-- Examine the distribution of sales by hour to determine peak business hours.
SELECT 
    EXTRACT(HOUR FROM sale_time) AS sale_hour,
    SUM(total_sale) AS sales_volume,
    COUNT(*) AS transactions
FROM retail_sales
GROUP BY EXTRACT(HOUR FROM sale_time)
ORDER BY sale_hour;