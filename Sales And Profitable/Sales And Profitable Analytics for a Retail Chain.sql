CREATE DATABASE Business;

/* What are the top 5 profitable products per region */
WITH product_profit_by_region AS (
 SELECT 
 s.region,
 p.product_name,
 SUM(o.profit) AS total_profit,
 RANK() OVER (PARTITION BY s.region ORDER BY SUM(o.profit) DESC)
    AS  profit_rank
    FROM orders o 
    JOIN products p ON o.product_id = p.product_id
      JOIN stores s ON o.store_id = s.store_id
        GROUP BY s.region,p.product_name 
          )
          SELECT 
            region,
             product_name,
              total_profit
          FROM product_profit_by_region
          WHERE profit_rank <= 5
          ORDER BY region,profit_rank;


/*Which customer segments drive the most revenue*/
   SELECT 
     c.segment,
    ROUND(SUM(o.revenue),2) AS total_revenue
     FROM orders o    
     JOIN customers c ON o.customer_id = c.customer_id
     GROUP BY c.segment
     ORDER BY total_revenue DESC;
     
   
   /*What are the monthly sales trends across all stores*/
     SELECT
      DATE_FORMAT(order_date,'%Y-%m') AS order_month,
       ROUND(SUM(revenue),2) AS total_monthly_sales
       FROM orders
       GROUP BY order_month
       ORDER BY order_month;
       
       /*Which store have the highest return rates*/
       WITH  total_orders AS (
        SELECT store_id, COUNT(*) AS total_orders
         FROM orders
         GROUP BY store_id 
         ),
         returned_orders AS (
         SELECT o.store_id,COUNT(*) AS returned_orders
           FROM returns r   
             JOIN orders o ON r.order_id = o.order_id
              GROUP BY o.store_id
              )
              SELECT 
              s.store_name,
              s.region,
              t.total_orders,
              COALESCE(r.returned_orders,0) AS returned_orders,
               ROUND(COALESCE(r.returned_orders,0) / t.total_orders * 100,2) AS 
                return_rate_percent
                FROM total_orders t
                JOIN stores s ON t.store_id = s.store_id
                 LEFT JOIN returned_orders r ON t.store_id = r.store_id
                  ORDER BY return_rate_percent DESC;
                  
                  
                  /*What's the Customer Lifetime Value for each customer*/
                   SELECT
                   c.customer_id,
                   c.customer_name,
                   c.segment,
                   COUNT(o.order_id) AS total_orders,
                   ROUND(SUM(o.revenue),2) AS customer_lifetime_value
                   FROM orders o 
                   JOIN customers c ON o.customer_id = c.customer_id
                   GROUP BY c.customer_id,c.customer_name,c.segment
                   ORDER BY customer_lifetime_value DESC;
                   
                   /*What are the top categories with consistent growth*/
                   SELECT
                    DATE_FORMAT(o.order_date,'%Y-%m') AS order_month,
                      p.category,
                      ROUND(SUM(o.revenue),2) AS monthly_revenue
                      FROM orders o  
                      JOIN products p ON o.product_id = p.product_id
                      GROUP BY order_month, p.category
                      ORDER BY order_month, p.category;
     
        /*Forecasting future sales using moving averages*/
        WITH monthly_sales AS (
        SELECT
         DATE_FORMAT(order_date, '%Y-%m') AS order_month,
         ROUND(SUM(revenue),2) AS total_revenue
         FROM orders
         GROUP BY order_month
           )
           SELECT 
            order_month,
            total_revenue,
            ROUND(AVG(total_revenue) OVER (
             ORDER BY order_month
              ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
              ),2) AS moving_avg_3_months
              FROM monthly_sales
              ORDER BY order_month;