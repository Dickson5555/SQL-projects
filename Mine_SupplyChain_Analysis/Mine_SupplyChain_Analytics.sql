CREATE DATABASE Supply_Chain;

USE Supply_Chain;

SELECT * FROM mining_supply_sales;

-- What is the total revenue generated ..?
SELECT SUM(amount) AS Total_Revenue
      FROM mining_supply_sales;
      
      
-- 2. Which products generate the highest revenue..? 
SELECT product_name,
       SUM(amount) AS Total_Revenue
FROM mining_supply_sales
GROUP BY product_name
ORDER BY Total_Revenue DESC;     



-- 3.What are the top 5 best-selling products by quantity..?  
SELECT  product_name,
        SUM(quantity) AS Total_Quantity_Sold
FROM mining_supply_sales
GROUP BY product_name
ORDER BY Total_Quantity_Sold DESC 
LIMIT 5;   



-- 4.Which products contribute above-average revenue..?   
SELECT product_name,
      SUM(amount) AS product_revenue
FROM mining_supply_sales 
GROUP BY product_name 
HAVING SUM(amount) > 
     ( SELECT AVG(product_revenue)
      FROM 
         ( SELECT SUM(amount) AS product_revenue 
FROM mining_supply_sales 
GROUP BY product_name ) x
);
  
  
  -- 5. What is the daily sales revenue trend..? 
 SELECT sale_date,
        SUM(amount) AS daily_revenue
 FROM mining_supply_sales 
 GROUP BY sale_date
 ORDER BY sale_date;
 
 -- 6. Which day recorded the highest revenue..?  
 SELECT sale_date,
        SUM(amount) AS daily_revenue 
 FROM mining_supply_sales 
 GROUP BY sale_date 
 ORDER BY daily_revenue DESC
 LIMIT 1 ;


-- 7. Products performance benchmarking 
SELECT product_name,
       SUM(amount) AS revenue ,
  RANK() OVER ( 
               ORDER BY SUM(amount) DESC 
               )  AS revenue_rank 
 FROM mining_supply_sales 
 GROUP BY product_name;
 
 
 
 -- 8.What percentage of total revenue does each product contribute..?   
 SELECT product_name,
        SUM(amount) AS revenue, 
			ROUND( SUM(amount)  * 100 / 
                   (SELECT SUM(amount) FROM mining_supply_sales),2 )
         AS revenue_percentage 
 FROM mining_supply_sales
 GROUP BY product_name
 ORDER BY revenue DESC;
 
 -- 9.How does daily revenue change compared to previous day..?
WITH daily_sales AS (
    SELECT sale_date,
           SUM(amount) AS daily_revenue 
    FROM mining_supply_sales 
    GROUP BY sale_date
    ) 
 SELECT sale_date,
           daily_revenue, 
 LAG(daily_revenue) OVER(ORDER BY sale_date) AS previous_day_revenue,
 daily_revenue - LAG(daily_revenue) OVER(ORDER BY sale_date) AS revenue_difference 
 FROM daily_sales; 

 -- 10.Product segment analysis 
SELECT product_name,
       SUM(amount) AS revenue,
CASE 
    WHEN SUM(amount) >= 30000 THEN 'High Revenue'
    WHEN SUM(amount) >= 15000 THEN 'Medium Revenue'
    ELSE 'Low Revenue' 
          END AS Revenue_Category
FROM mining_supply_sales
GROUP BY product_name;    


-- 11. Which products are among the top 3 revenue generators..?  
WITH product_revenue AS (
     SELECT product_name,
            SUM(amount) AS revenue ,
	   RANK() OVER (ORDER BY SUM(amount) DESC) AS rank_number
   FROM mining_supply_sales 
   GROUP BY product_name )
SELECT *
        FROM product_revenue
        WHERE rank_number <= 3;
        
       
-- 12.What is the cummulative revenue over time..?  
WITH daily_sales AS (
     SELECT sale_date,
            SUM(amount) AS daily_revenue 
       FROM mining_supply_sales
       GROUP BY sale_date )
 SELECT sale_date,
             daily_revenue, SUM(daily_revenue)
               OVER(ORDER BY sale_date) AS cummulative_revenue
FROM daily_sales;               
        
        

-- 13.What is the average revenue per sale for each product..? 
SELECT product_name,
        ROUND(AVG(amount),2) AS Avg_Sale_Revenue
  FROM mining_supply_sales
  GROUP BY product_name
  ORDER BY Avg_Sale_Revenue DESC;
  
  
  
-- Which products perform above their category average..?  
WITH product_sales AS (
     SELECT product_name,
            SUM(amount) AS revenue 
       FROM mining_supply_sales
       GROUP BY product_name ) 
 SELECT 
       product_name,revenue,
         AVG(revenue) OVER() AS Overall_Avg_Revenue
       FROM product_sales
WHERE revenue >  ( SELECT AVG(revenue) FROM product_sales );       
        

