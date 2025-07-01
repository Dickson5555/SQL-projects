CREATE DATABASE subquery;

/*Scalar Subquery:using subquery to gey total amount spent by each customer*/

SELECT name,
   (SELECT SUM(amount)
     FROM orders
      WHERE orders.customer_id = customers.customer_id) AS total_spent
        FROM customers;
   
   /*Finding customers who have placed orders above the average amount*/

SELECT name
	FROM customers
	 WHERE customer_id IN (
       SELECT customer_id
       FROM orders
        WHERE amount > (SELECT AVG(amount) FROM orders));
         
         
         /*Finding the most recent order amount for each customer*/
SELECT customer_id,amount
  FROM orders o1
   WHERE order_date = (SELECT MAX(order_date)
    FROM orders o2
     WHERE O2.customer_id = o1.customer_id);
   
   
   /*Finding customers with total amount spent,then filter those spending over 400.*/
   SELECT name,total_spent
     FROM(
      SELECT customers.name, SUM(orders.amount) AS total_spent
       FROM customers
         JOIN orders ON customers.customer_id = orders.customer_id
           GROUP BY customers.name )
              AS Spending
              WHERE total_spent > 400;
              
              
    /*Finding customrs who have made at least one order*/
 SELECT name
   FROM customers c
    WHERE EXISTS(
      SELECT 1
        FROM orders o 
          WHERE o.customer_id = c.customer_id);