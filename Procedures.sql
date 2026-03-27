--Understanding Stored Procedures,Triggers and Functions

CREATE DATABASE CompanyDB;
GO

USE CompanyDB;

CREATE TABLE Employees(
EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
FullName VARCHAR(100),
Department VARCHAR(50),
Salary DECIMAL(10,2),
HireDate DATE
);

INSERT INTO Employees(FullName,Department,Salary,HireDate)
VALUES
('Lord Wood','IT',5000,'2022-01-10'),
('Jenny Smith','Finance',6000,'2021-06-15'),
('Joseph Mensah','IT',4500,'2023-03-20'),
('Mara Dickson','HR',4000,'2022-04-19'),
('Esther shakes','Finance',6000,'2021-06-13');

--Simple Procedure
CREATE PROCEDURE GetAllEmployees
AS 
BEGIN 
   SELECT* FROM Employees;
END;

EXEC GetAllEmployees;

-- Procedure with parameters
CREATE PROCEDURE GetEmployeesByDepartment
@Dept VARCHAR(50)
AS 
 BEGIN 
  SELECT* FROM Employees
    WHERE Department = @Dept;
     END;

EXEC GetEmployeesByDepartment @Dept = 'Finance';


--Insering using procedure 
CREATE PROCEDURE AddEmployee
@Name VARCHAR(100),
@Department VARCHAR(50),
@Salary DECIMAL(10,2),
@HireDate DATE
AS 
 BEGIN 
   INSERT INTO Employees (FullName,Department,Salary,HireDate)
    VALUES(@Name,@Department,@Salary,@HireDate);
END;

EXEC AddEmployee 'James Annan','HR',5500,'2024-01-01';


--Procedure with IF ELSE
CREATE PROCEDURE CheckSalary @EmpID INT 
AS 
 BEGIN 
  DECLARE @Salary DECIMAL(10,2);

   SELECT @Salary = Salary
   FROM Employees 
   WHERE EmployeeID = @EmpID;

   IF @Salary > 5000
      PRINT 'High Salary';
   ELSE
      PRINT 'Normal Salary';
      END;



CREATE PROCEDURE GetSalary
 @EmpID INT, @EmpSalary DECIMAL(10,2)
 AS 
  BEGIN 
   SELECT @EmpSalary = Salary 
   FROM Employees
   WHERE EmployeeID = @EmpID;
END; 


-- USER-DEFINED FUNCTIONS

-- Scalar Function (returns a single value)
CREATE FUNCTION GetAnnualSalary (@MonthlySalary DECIMAL (10,2))
RETURNS DECIMAL(10,2)
AS 
BEGIN 
   RETURN @MonthlySalary * 12;
   END;


SELECT FullName,Salary,dbo.GetAnnualSalary(Salary) AS
AnnualSalary 
   FROM Employees;


--Table-Valued Function (returns a table)
CREATE FUNCTION GetEmployeesByDeptFunc(@Dept VARCHAR(50))
RETURNS TABLE 
 AS RETURN
   ( SELECT * FROM Employees
     WHERE Department = @Dept
    );

SELECT * FROM dbo.GetEmployeesByDeptFunc('IT');




-- TRIGGERS

CREATE TABLE EmployeeAudit(
AuditID INT IDENTITY(1,1) PRIMARY KEY,
EmployeeID INT,
ActionType VARCHAR(10),
ActionDate DATETIME
);


--After INSERT Trigger
CREATE TRIGGER trg_AfterInsertEmployee 
ON Employees 
AFTER INSERT
AS 
BEGIN 
   INSERT INTO EmployeeAudit(EmployeeID,ActionType,ActionDate)
   SELECT EmployeeID,'INSERT', GETDATE()
   FROM inserted;
END;

--inserting a new record
INSERT INTO Employees(FullName,Department,Salary,HireDate)
VALUES ('Rockson Baidoo','IT',4800,'2024-02-01');

SELECT * FROM EmployeeAudit;



--Prevent low salary(using trigger and if)

CREATE TRIGGER trg_CheckSalary ON Employees
INSTEAD OF INSERT 
AS 
 BEGIN 
  IF EXISTS (SELECT 1 FROM inserted WHERE Salary < 3000)
   BEGIN 
    PRINT 'Salary too low';
    END 
     ELSE
      BEGIN 
       INSERT INTO Employees (FullName,Department,Salary,HireDate)
       SELECT FullName,Department,Salary,HireDate
        FROM inserted;
        END
END;





