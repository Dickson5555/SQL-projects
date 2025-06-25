/*INNER JOIN : returns only rows with matching department_id*/
SELECT e.full_name,d.department_name
FROM employees e
INNER JOIN departments d
ON e.department_id = d.department_id;

/*Robert Wilson is excluded - he has no department*/

/*LEFT JOIN : returns all employees,even if they don't have a department*/
SELECT e.full_name, d.department_name
FROM employees e
LEFT JOIN departments d
ON e.department_id = d.department_id;

/*RIGHT JOIN: returns all departments,even if they have no employees*/
SELECT d.department_name,e.full_name
FROM employees e
RIGHT JOIN departments d
ON e.department_id = d.department_id;
/*sales has no employees ,but still shows up*/

/* CROSS JOIN : every row from department table is combined
     with every row from employees table*/
     
SELECT e.full_name, d.department_name
FROM employees e
CROSS JOIN departments d;   
/* you get 5 employees x 4 departments = 20 */


/*SELF JOIN: a table joins with itself.use when
 comparing rows in the same column */
 SELECT a.full_name AS employee1, b.full_name AS employee2, 
 a.department_id FROM employees a
 JOIN employees b
 ON a.department_id = b.department_id 
 AND a.employee_id < b.employee_id;
 /* finding pairs of employees in the same department*/
 
 
 /*JOIN WITH FILTERS: combine joins with WHERE,GROUP BY,and HAVING */
 SELECT d.department_name,
 COUNT(e.employee_id) AS employee_count
 FROM departments d 
 LEFT JOIN employees e ON d.department_id = e.department_id
 GROUP BY d.department_name 
 HAVING COUNT(e.employee_id ) > 1;
     

/*FULL OUTER JOIN: all rows from both tables ;non-matching rows show null */
SELECT e.full_name,d.department_name
FROM employees e 
LEFT JOIN departments d ON e.department_id = d.department_id
UNION
SELECT e.full_name,d.department_name
FROM employees e
RIGHT JOIN departments d ON e.department_id = d.department_id;







