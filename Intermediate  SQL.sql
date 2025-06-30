CREATE DATABASE CTES;

CREATE TABLE sales_data(
sale_id INT,
employee_id INT,
region varchar(25),
sale_amount INT,
sale_date DATE);


INSERT INTO sales_data
VALUES
       (1 ,101, "West",500,"2024-01-05"),
	   (2 ,102, "East",700,"2024-01-06"),
       (3 ,101, "West",400,"2024-01-07"),
       (4 ,103, "North",1000,"2024-01-08"),
	   ( 5 ,101, "West",650,"2024-01-10"),
	   (6 ,102, "Eest",800,"2024-01-11");
SELECT* from sales_data;

/*Get top sale per Employee*/
WITH Ranked_sales AS (
SELECT*,
ROW_NUMBER() OVER(PARTITION BY employee_id ORDER BY sale_amount DESC) AS RN
FROM sales_data)
SELECT*
FROM Ranked_sales
WHERE RN = 1;

/* Total sales and Average sales per employee */
WITH employee_totals AS (
SELECT employee_id,
SUM(sale_amount) AS total_sales,
AVG(sale_amount) AS avg_sales
FROM sales_data
GROUP BY employee_id)
SELECT*
FROM employee_totals
WHERE avg_sales > 600;

/*Using roll up to add subtotals and grand total*/
SELECT region,employee_id,
SUM(sale_amount) AS total_sales
FROM sales_data
GROUP BY ROLLUP(region,employee_id);

/* Using cube to include combinations
SELECT region,employee_id,
SUM(sale_amount) AS total_sales
FROM sales_data
GROUP BY CUBE(region,employee_id); */

SELECT sale_date,
EXTRACT(MONTH FROM sale_date) AS month,
DATEDIFF("month",sale_date) AS month_start,
CURRENT_DATE - sale_date AS days_ago
FROM sales_data;

SELECT*,
CASE 
WHEN sale_amount >= 800 THEN "High"
WHEN sale_amount >= 500 THEN "Medium"
ELSE "Low"
END AS sale_category
FROM sales_data;

SELECT*,
sale_amount - LAG(sale_amount)
OVER(PARTITION BY employee_id ORDER BY sale_date) AS sale_change
FROM sales_data;

SELECT employee_id,region,sale_amount,
  SUM(sale_amount) OVER (PARTITION BY region) AS total_by_region
  FROM sales_data; 
  
  SELECT sale_date,
  EXTRACT(YEAR FROM sale_date) AS year,
  EXTRACT(MONTH FROM sale_date) AS month
  FROM sales_data;

SELECT employee_id,sale_date,sale_amount,
LAG(sale_amount) OVER (PARTITION BY employee_id ORDER BY sale_date) AS prev_sale,
LEAD(sale_amount) OVER (PARTITION BY employee_id ORDER BY sale_date) AS next_sale
FROM sales_data; 