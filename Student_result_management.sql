CREATE DATABASE student_result_management;

USE student_result_management;

CREATE TABLE Department (
    Dept_ID INT PRIMARY KEY,
    Dept_name VARCHAR(50),
    HOD_name VARCHAR(50)
);

CREATE TABLE Student (
    USN VARCHAR(20) PRIMARY KEY,
    Name VARCHAR(50),
    DOB DATE,
    Semester INT,
    Dept_ID INT,
    FOREIGN KEY (Dept_ID) REFERENCES Department(Dept_ID)
);

CREATE TABLE Subject (
    Sub_code VARCHAR(20) PRIMARY KEY,
    Sub_name VARCHAR(50),
    Semester INT,
    Credits INT,
    Dept_ID INT,
    Subject_Type VARCHAR(20),
    FOREIGN KEY (Dept_ID) REFERENCES Department(Dept_ID)
);

CREATE TABLE Marks (
    USN VARCHAR(20),
    Sub_code VARCHAR(20),
    CIE1 INT,
    CIE2 INT,
    CIE3 INT,
    Assignment_Marks INT,
    Lab_Marks INT,
    SEE INT,
    Internal_Marks INT,
    External_Marks INT,
    Final_Total INT,
    Grade VARCHAR(5),
    Grade_Point DECIMAL(3,1),
    PRIMARY KEY (USN, Sub_code),
    FOREIGN KEY (USN) REFERENCES Student(USN),
    FOREIGN KEY (Sub_code) REFERENCES Subject(Sub_code)
);

CREATE TABLE Result (
    Result_ID INT PRIMARY KEY AUTO_INCREMENT,
    USN VARCHAR(20),
    Semester INT,
    SGPA DECIMAL(4,2),
    CGPA DECIMAL(4,2),
    FOREIGN KEY (USN) REFERENCES Student(USN)
);

CREATE TABLE User_Login (
    User_ID VARCHAR(20) PRIMARY KEY,
    Password VARCHAR(50),
    Role VARCHAR(20)
);


INSERT INTO Department
VALUES
(1, 'AIML', 'Dr. Shobha'),
(2, 'CSE', 'Dr. Kumar');

INSERT INTO Subject
VALUES
('AIM401', 'Mathematics', 4, 4, 1, 'Theory'),
('AIM402', 'DBMS', 4, 3, 1, 'Theory'),
('AIM404', 'Java', 4, 2, 1, 'IPCC');

INSERT INTO Student
VALUES
('4SF23AI001', 'Akanksha', '2005-06-15', 4, 1),
('4SF23AI002', 'Sahana', '2005-08-21', 4, 1);

INSERT INTO User_Login
VALUES
('teacher1', 'admin123', 'teacher'),
('4SF23AI001', 'stud123', 'student'),
('4SF23AI002', 'stud456', 'student');

INSERT INTO Marks
VALUES
('4SF23AI001','AIM401',25,27,28,18,0,45,44,89,'A+',9.0),
('4SF23AI001','AIM402',26,25,27,19,0,46,48,94,'O',10.0);


DELIMITER //
CREATE TRIGGER Calculate_Result
BEFORE INSERT ON Marks
FOR EACH ROW
BEGIN
    DECLARE sub_type VARCHAR(20);
    SELECT Subject_Type
    INTO sub_type
    FROM Subject
    WHERE Sub_code = NEW.Sub_code;
    IF sub_type = 'Theory' THEN
        SET NEW.Internal_Marks =
        ROUND((NEW.CIE1 + NEW.CIE2 + NEW.CIE3)/3)
        + NEW.Assignment_Marks;
    ELSEIF sub_type = 'IPCC' THEN
        SET NEW.Internal_Marks =
        ROUND((NEW.CIE1 + NEW.CIE2 + NEW.CIE3)/6)
        + NEW.Assignment_Marks
        + NEW.Lab_Marks;
    END IF;
    SET NEW.External_Marks =
    ROUND(NEW.SEE / 2);
    SET NEW.Final_Total =
    NEW.Internal_Marks + NEW.External_Marks;
    IF NEW.Final_Total >= 90 THEN
        SET NEW.Grade = 'O';
        SET NEW.Grade_Point = 10;
    ELSEIF NEW.Final_Total >= 80 THEN
        SET NEW.Grade = 'A+';
        SET NEW.Grade_Point = 9;
    ELSEIF NEW.Final_Total >= 70 THEN
        SET NEW.Grade = 'A';
        SET NEW.Grade_Point = 8;
    ELSEIF NEW.Final_Total >= 60 THEN
        SET NEW.Grade = 'B+';
        SET NEW.Grade_Point = 7;
    ELSEIF NEW.Final_Total >= 50 THEN
        SET NEW.Grade = 'B';
        SET NEW.Grade_Point = 6;
    ELSE
        SET NEW.Grade = 'F';
        SET NEW.Grade_Point = 0;
    END IF;
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE Calculate_SGPA
(
    IN p_USN VARCHAR(20),
    IN p_Semester INT
)
BEGIN
    DECLARE total_points DECIMAL(10,2);
    DECLARE total_credits INT;
    DECLARE sgpa DECIMAL(4,2);
    SELECT
        SUM(M.Grade_Point * S.Credits),
        SUM(S.Credits)
    INTO total_points, total_credits
    FROM Marks M
    JOIN Subject S
        ON M.Sub_code = S.Sub_code
    WHERE M.USN = p_USN
      AND S.Semester = p_Semester;
    SET sgpa = total_points / total_credits;
    INSERT INTO Result
    (
        USN,
        Semester,
        SGPA,
        CGPA
    )
    VALUES
    (
        p_USN,
        p_Semester,
        sgpa,
        sgpa
    );
END //
DELIMITER ;

