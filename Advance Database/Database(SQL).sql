CREATE DATABASE University;
GO 

USE University;
GO

CREATE TABLE StudentsFCM_41_023_025_24(
student_id INT IDENTITY(1,1) PRIMARY KEY,
full_name VARCHAR(100) NOT NULL,
email VARCHAR(100) UNIQUE,
program VARCHAR(50),
year_of_study INT
);


CREATE TABLE CoursesFCM_41_023_025_24(
course_id INT IDENTITY(1,1) PRIMARY KEY,
course_name VARCHAR(100),
credit_hours INT
);

CREATE TABLE EnrollmentFCM_41_023_025_24(
enrollment_id INT IDENTITY(1,1) PRIMARY KEY,
student_id INT,
course_id INT ,
semester VARCHAR(20),
FOREIGN KEY (student_id) REFERENCES StudentsFCM_41_023_025_24(student_id),
FOREIGN KEY (course_id) REFERENCES CoursesFCM_41_023_025_24(course_id)
);

CREATE TABLE StaffFCM_41_023_025_24(
staff_id INT IDENTITY(1,1) PRIMARY KEY,
staff_name VARCHAR(100),
role VARCHAR(50)
);

CREATE TABLE GradesFCM_41_023_025_24(
grade_id INT IDENTITY PRIMARY KEY,
enrollment_id INT,
score DECIMAL(5,2),
FOREIGN KEY (enrollment_id) REFERENCES EnrollmentFCM_41_023_025_24(enrollment_id)
);

INSERT INTO StudentsFCM_41_023_025_24(full_name,email,program,year_of_study)
VALUES
('Bismark Mensah','Bissy@gmail.com','Computer Science',2),
('Ruth Wendy','Wendy11@gmail.com','CyberSecurity',1),
('Mohammed Alpha','AlphaMU@gmail.com','IT',3),
('Bridget Wood','Bwood@gmail.com','Data Science',3),
('John Oduro','OOduro@gmail.com','Computer Science',4);


USE master;
GO

CREATE LOGIN admin1 WITH PASSWORD = 'Admin@123';
CREATE LOGIN staff1 WITH PASSWORD = 'Staff@123';
CREATE LOGIN student1 WITH PASSWORD = 'Student@123';
GO


USE University;
GO

CREATE USER admin1 FOR LOGIN admin1;
CREATE USER staff1 FOR LOGIN staff1;
CREATE USER student1 FOR LOGIN student1;
GO


CREATE ROLE admin_role;
CREATE ROLE staff_role;
CREATE ROLE student_role;


ALTER ROLE admin_role ADD MEMBER admin1;
GRANT CONTROL ON
DATABASE::University TO admin_role;


ALTER ROLE staff_role ADD MEMBER staff1;
GRANT SELECT ON StudentsFCM_41_023_025_24 TO staff_role;
GRANT SELECT,UPDATE ON GradesFCM_41_023_025_24 TO staff_role;


ALTER ROLE student_role ADD MEMBER student1;
GRANT SELECT ON StudentsFCM_41_023_025_24 TO student_role;
GRANT SELECT ON GradesFCM_41_023_025_24 TO student_role;


--REVOKE UPDATE ON GradesFCM_41_023_025_24 FROM staff_role;


CREATE PROCEDURE register_student
 @p_name VARCHAR(100),
 @p_email VARCHAR(100),
 @p_program VARCHAR(50),
 @p_year INT
 AS 
   BEGIN 
     INSERT INTO StudentsFCM_41_023_025_24(full_name,email,program,year_of_study)
       VALUES( @p_name,@p_email ,@p_program , @p_year );
       PRINT'Student Registered Successfully';
       END;
       GO

EXEC register_student 'Sarah Darko','darko@gmail.com','IT',1;

--SELECT* FROM StudentsFCM_41_023_025_24;



CREATE TRIGGER check_grade ON GradesFCM_41_023_025_24
 INSTEAD OF INSERT 
  AS 
   BEGIN 
    IF EXISTS (SELECT* FROM inserted WHERE score < 0 OR score > 100)
      BEGIN 
       THROW 50001,'Invalid score value.Must be between 0 and 100',1;
        END 
INSERT INTO GradesFCM_41_023_025_24(enrollment_id,score)
 SELECT enrollment_id,score FROM inserted;
 END;
 GO



 CREATE FUNCTION calculate_cwa (@studentId INT) RETURNS DECIMAL(4,2) AS
 BEGIN 
  DECLARE @cwa DECIMAL(4,2);

   SELECT @cwa = AVG(score)/ 25
   FROM GradesFCM_41_023_025_24  G  JOIN EnrollmentFCM_41_023_025_24 E 
   ON  G.enrollment_id = E.enrollment_id
   WHERE E.student_id = @studentId;

   RETURN @cwa;
   END;
   GO


   --SELECT dbo.calculate_cwa(1) AS CWA;


   CREATE PROCEDURE check_graduation @studentId INT 
   AS 
   BEGIN 
    DECLARE @cwa DECIMAL(4,2);

    SET @cwa = dbo.calculate_cwa(@studentId);

    IF @cwa >= 2.0 
    PRINT'Eligible for Graduation';
    ELSE 
     PRINT'Not Eligible';
     END;
     GO
     --EXEC check_graduation

     

     CREATE TABLE audit_log (
     log_id INT IDENTITY(1,1) PRIMARY KEY,
     user_name VARCHAR(50),
     action_performed VARCHAR(255),
     action_time DATETIME DEFAULT GETDATE()
     );


     CREATE TRIGGER log_student_insert ON StudentsFCM_41_023_025_24
     AFTER INSERT 
     AS 
     BEGIN 
      INSERT INTO audit_log(user_name,action_performed)
      VALUES (SYSTEM_USER,'Inserted new student');
      END;
      GO 



      --SELECT*FROM audit_log;

     -- BACKUP DATABASE University
     -- TO DISK = 'C:\Backup\University_backup.bak'
     -- WITH FORMAT;


     --RESTORE DATABASE University
     --FROM DISK = 'C:\Backup\University_backup.bak'
     --WITH REPLACE