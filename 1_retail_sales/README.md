# Retail Sales AnalysProject Overview
---
## Project Overview
---

**Project Title:** Retail Sales Analysis
**Level:** Beginner
**Database:** p1_retail_db
---
## Objectives

1. Set up a retail sales database: Create and populate a retail sales database with the provided sales data.
2. Data Cleaning: Identify and remove any records with missing or null values.
3. Exploratory Data Analysis (EDA): Perform basic exploratory data analysis to understand the dataset.
4. Business Analysis: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure
### 1. Database Setup
 - **Database Creation:** The project starts by creating a database named p1_retail_db.
 - **Table Creation:** A table named *retail_sales* is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

 ```sql
CREATE DATABASE p1_retail_db;

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
 ```

 ### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.

```sql
SELECT COUNT(*) FROM retail_sales;
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;
SELECT DISTINCT category FROM retail_sales;

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
```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Write a SQL query to analyze sales patterns by day of the week to see which days are performing best.**:
```sql
SELECT 
    TO_CHAR(sale_date, 'Day') AS day_of_week,
    SUM(total_sale) AS weekly_sales
FROM retail_sales
GROUP BY TO_CHAR(sale_date, 'Day')
ORDER BY weekly_sales DESC;
```

2. **Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022**:
```sql
SELECT 
  *
FROM retail_sales
WHERE 
    category = 'Clothing'
    AND 
    TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
    AND
    quantity >= 4
```
**Alterante approach**
```sql
SELECT *
FROM retail_sales
WHERE category = 'Clothing'
  AND EXTRACT(YEAR FROM sale_date) = 2022
  AND EXTRACT(MONTH FROM sale_date) = 11
  AND quantity >= 4;
```


3. **Write a SQL query to calculate the total sales adn average sales for each category.**:
```sql
SELECT 
    category,
    SUM(total_sale) AS net_sale,
    AVG(total_sale) AS avg_sale,
    COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category;
```


4. **Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.**:
```sql
SELECT
    ROUND(AVG(age), 2) as avg_age
FROM retail_sales
WHERE category = 'Beauty'
```


5. **Write a SQL query to find all transactions where the total_sale is greater than 1000.**:
```sql
SELECT * FROM retail_sales
WHERE total_sale > 1000
```


6. **Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.**:
```sql
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
```


7. **Write a SQL query to calculate the average sale for each month. Find out best selling month in each year**:
```sql
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
```


8. **Write a SQL query to find the top 5 customers based on the highest total sales **:
```sql
SELECT 
    customer_id,
    SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5
```


9. **Write a SQL query to find the number of unique customers who purchased items from each category.**:
```sql
SELECT 
    category,    
    COUNT(DISTINCT customer_id) as unique_customers
FROM retail_sales
GROUP BY category
```


10. **Write a SQL query to identify customers who have made multiple purchases and count how many times each customer has shopped. **:
```sql
SELECT 
    customer_id,
    COUNT(*) AS purchase_count
FROM retail_sales
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY purchase_count DESC;
```


11. **Write a SQL query to distinguish between new and returning customers by tagging customers with only one transaction as “new” and others as “returning.”**:

```sql
SELECT 
    CASE WHEN purchase_count = 1 THEN 'New' ELSE 'Returning' END AS customer_type,
    COUNT(*) AS num_customers
FROM (
    SELECT customer_id, COUNT(*) AS purchase_count
    FROM retail_sales
    GROUP BY customer_id
) AS customer_summary
GROUP BY customer_type;
```


11. **Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)**:
```sql
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
```

**Alternate approach**
```sql
SELECT
    SUM(CASE WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 1 ELSE 0 END) AS morning_orders,
    SUM(CASE WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 1 ELSE 0 END) AS afternoon_orders,
    SUM(CASE WHEN EXTRACT(HOUR FROM sale_time) > 17 THEN 1 ELSE 0 END) AS evening_orders
FROM retail_sales;
```


12.  **Write a SQL query to calculate the profit margin for each sale and then analyze the average margin by product category.**:
```sql
SELECT 
    category,
    ROUND(AVG((total_sale - cogs) / total_sale * 100)::numeric, 2) AS avg_profit_margin
FROM retail_sales
GROUP BY category
ORDER BY avg_profit_margin DESC;
```

13. **Write a SQL query to segment customers into age groups (for example, <20, 20-29, 30-39, etc.) and calculate the average spending per group.**:

```sql
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
```

14. ** Write a SQL query to examine the distribution of sales by hour to determine peak business hours.**:
```sql
SELECT 
    EXTRACT(HOUR FROM sale_time) AS sale_hour,
    SUM(total_sale) AS sales_volume,
    COUNT(*) AS transactions
FROM retail_sales
GROUP BY EXTRACT(HOUR FROM sale_time)
ORDER BY sale_hour;
```

## Findings

- **Customer Demographics**: The dataset includes customers from various age groups, with sales distributed across different categories such as Clothing and Beauty.
- **High-Value Transactions**: Several transactions had a total sale amount greater than 1000, indicating premium purchases.
- **Sales Trends**: Monthly analysis shows variations in sales, helping identify peak seasons.
- **Customer Insights**: The analysis identifies the top-spending customers and the most popular product categories.

## Reports

- **Sales Summary**: A detailed report summarizing total sales, customer demographics, and category performance.
- **Trend Analysis**: Insights into sales trends across different months and shifts.
- **Customer Insights**: Reports on top customers and unique customer counts per category.

## Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.

## How to Use

1. **Clone the Repository**: Clone this project repository from GitHub.
2. **Set Up the Database**: Run the SQL scripts provided in the `retail_schema.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries provided in the `retail_problem.sql` file to perform your analysis.


## Author - Michal Puškáč

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

- **LinkedIn**:[LinkedIn](linkedin.com/in/michal-puškáč-94b925179)
- **GitHub**: [GitHub](github.com/michalpuskac)