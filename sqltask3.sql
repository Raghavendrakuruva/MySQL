-- 1.create a database
create database empll;


use empll;
-- 2q:Create a table named Employees with the above 10 columns.Apply appropriate constraints such as:
create table  Employees(
EmployeeID int , -- primary key
firstname varchar(30) ,
lastname varchar(40),
email varchar(50) unique,
PhoneNumber bigint not null,
hiredate varchar(12),
jobtitle varchar(30) default 'employee', -- default
department varchar(20),
salary decimal(10,2),
status varchar(20) check (status in ('oldemployee','working','inactive')), -- check
primary key(employeeid,phonenumber) -- composite key
);
-- 3Q Insert at least 8–10 realistic records into the Employees table
INSERT INTO Employees 
(EmployeeID, firstname, lastname, email, PhoneNumber, hiredate, jobtitle, department, salary, status) 
VALUES
(1, 'Ravi', 'Kumar', 'ravi.kumar@example.com', 9876543210, '2020-01-15', 'Manager', 'HR', 65000.00, 'working'),

(2, 'Sita', 'Reddy', 'sita.reddy@example.com', 9876543211, '2019-03-22', DEFAULT, 'Finance', 55000.50, 'working'),

(3, 'Arjun', 'Varma', 'arjun.varma@example.com', 9876543212, '2021-07-10', 'Developer', 'IT', 48000.75, 'working'),

(4, 'Priya', 'Naidu', 'priya.naidu@example.com', 9876543213, '2018-11-05', DEFAULT, 'Sales', 43000.00, 'oldemployee'),

(5, 'Vikram', 'Singh', 'vikram.singh@example.com', 9876543214, '2022-04-01', 'Team Lead', 'IT', 72000.25, 'working'),

(6, 'Meena', 'Sharma', 'meena.sharma@example.com', 9876543215, '2017-09-18', DEFAULT, 'HR', 39500.00, 'oldemployee'),

(7, 'Kiran', 'Das', 'kiran.das@example.com', 9876543216, '2023-06-12', 'Analyst', 'Finance', 51000.00, 'working'),

(8, 'Anita', 'Rao', 'anita.rao@example.com', 9876543217, '2016-02-27', DEFAULT, 'Admin', 38000.00, 'oldemployee');

-- subquries 
-- 1q.Find the details of the employee with the highest salary.
select max(salary) from employees;
-- 2q.Show the average salary of employees in the same department as a given employee. (Assume the employee's name is provided — e.g., 'John')
select department,avg(salary) as avgdept from employees group by department;
-- 3Q.Multiple-Row Subqueries List employees who work in departments where the average salary is more than 50,000
select department,avg(salary) as avgsalary from employees 
group by department
 having avgsalary>50000;
 -- 4q.Retrieve EmployeeID and FirstName of employees who share the same salary and department as any other employee
-- 1way
SELECT e.employeeid, e.firstname, e.department, e.salary
FROM employees e
WHERE EXISTS (
    SELECT 1 
    FROM employees d
    WHERE d.department = e.department
      AND d.salary = e.salary
      AND d.employeeid <> e.employeeid
);


-- Correlated Subqueries
-- 5Q.Find employees who earn more than the average salary of their department
select * from employees as e
left join 
(select department,avg(salary) as avgsalary from employees 
group by department) as f on f.department=e.department
where salary>f.avgsalary;
-- 6Q.Display employees who joined earliest in their department.

SELECT *
FROM (
    SELECT firstname,
           department,hiredate,
           NTILE(3) OVER (PARTITION BY department ORDER BY hiredate) AS i
    FROM employees
) t
WHERE i = 1;

-- Joins 
-- Inner Join
-- 7q.Get all employees with their department names
select * from employees e
inner join (select firstname,department from employees ) as d
on d.firstname=e.firstname;
INSERT INTO Employees 
(EmployeeID, firstname, lastname, email, PhoneNumber, hiredate, jobtitle, salary, status) 
VALUES
(99, 'Ravi', 'Kumar', 'ravi.kumarr@example.com', 98765430210, '2020-01-15', 'Manager', 65000.00, 'working');
-- 8q.Left Join -- Display all employees along with their department names, including those with missing department info
select e.firstname,coalesce(d.department,'missing')from employees e
left join (select firstname,department from employees ) as d
on d.firstname=e.firstname;

-- 9q.Right Join --List all departments and their employees, including departments with no employees
select e.firstname,coalesce(d.department,'missing')from employees e
right join (select firstname,department from employees ) as d
on d.firstname=e.firstname;
-- 10Q.Cross Join--Show all combinations of employees and department names.
select e.employeeid,e.firstname,d.department from employees e
cross join  (select distinct department from employees ) as d;
-- 11Q.selfjoin Find pairs of employees who work in the same department.
SELECT e1.firstname AS emp1, 
       e2.firstname AS emp2, 
       e1.department
FROM employees e1
JOIN employees e2 
     ON e1.department = e2.department;
-- AND e1.EmployeeID < e2.EmployeeID;

-- 12q.Inner Join (Self Join with Hierarchy)-- List employees along with their managers.
alter table employees
add manager int;
UPDATE employees SET manager = 2 WHERE EmployeeID = 1;
UPDATE employees SET manager = 99 WHERE EmployeeID = 2;
UPDATE employees SET manager = 2 WHERE EmployeeID = 3;
UPDATE employees SET manager = 3 WHERE EmployeeID = 4;
UPDATE employees SET manager = 3 WHERE EmployeeID = 5;
UPDATE employees SET manager = 3 WHERE EmployeeID = 6;
UPDATE employees SET manager = 4 WHERE EmployeeID = 7;
UPDATE employees SET manager = 4 WHERE EmployeeID = 8;
UPDATE employees SET manager = 5 WHERE EmployeeID = 99;

select * from employees;
select e.employeeid,e.firstname,d.manager  ,f.firstname as manager from employees e
join (select employeeid,firstname,manager from employees ) as d 
on e.employeeid=d.employeeid
left join (select employeeid,firstname from employees) f on e.manager=f.employeeid;

-- Subqueries + Joins (Advanced Thinking) 
-- 13q.List employees with department names, filtering only active departments using a subquery in a join.
update employees
set status='inactive'
where hiredate between '2001-01-01' and '2022-01-01';
select e.employeeid,e.firstname,e.department ,d.status from employees e
join (select employeeid,status from employees where status='working') as d on
e.employeeid=d.employeeid;

-- 14Q.Show employees whose salary is above the department average, including department names
-- 1way coorelation
select e.employeeid,e.firstname,e.salary from employees e
where salary>(select avg(salary) from employees as d where e.department=d.department);
-- 2way join
SELECT e.employeeid, e.firstname, e.department, e.salary, dept.avg_salary
FROM employees e
JOIN (
    SELECT department, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department
) dept
ON dept.department = e.department
WHERE e.salary > dept.avg_salary;

-- 15Q.For each department, display the department name, number of employees, and average salary
select department,count(employeeid),avg(salary) from employees group by department;
-- 2way by joins
select e.department ,count_employees,avg_salary from employees e
join (select department,count(employeeid) as count_employees,avg(salary) as avg_salary from employees  group by department) as d on
e.department=d.department
group by e.department;



select * from employees;




