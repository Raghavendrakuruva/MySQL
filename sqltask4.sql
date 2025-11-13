-- 1.create a database
create database company;


use company;
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

select * from employees;
-- SET OPERATIONS (UNION / UNION ALL)
-- 1Q.List all unique departments from both Working and Old Employees.
select distinct department from employees  where status='working'
union
select distinct department from employees  where status='oldemployee';

-- 2q.Show all job titles (including duplicates) of employees from both HR and IT departments.
select jobtitle from employees where department='HR'
union
select jobtitle from employees where department='IT';

-- 3q.Combine the first names of employees from HR and Finance departments and remove duplicates.
select firstname from employees where department='HR'
union
select firstname from employees where department='Finance';

-- 4q.List all job titles that appear in either Working or Old Employees.
select distinct jobtitle from employees  where status='working'
union all
select distinct jobtitle from employees  where status='oldemployee';

-- DERIVED TABLES (Virtual/Temporary Subqueries in FROM clause)
-- 5Q.Use a derived table to calculate the average salary per department, and then select departments with an average above 50,000
select department,avgsalary from(
select department,avg(salary) as avgsalary from employees group by department) as d
where avgsalary>50000;

-- 6q.Use a derived table to count the number of employees hired in each year, then select only years with more than 10 hires.
select hiredate,countofemployess from(
select year(hiredate) as hiredate,count(*) as countofemployess from employees group by year(hiredate)) as d
where countofemployess>10;

-- 7q. Create a derived table to count the number of employees in each department, and list those departments with more than 3 employees.
select department,countofemployess from(
select department,count(*) as countofemployess from employees group by department) d
where countofemployess>3;

-- CTEs (Common Table Expressions)
-- 8q.Write a CTE to calculate the total salary per department, and select departments where the total is above 200,000.
with cte_salaryperdepartment as(
select  department,sum(salary) as sumsalary from employees
group by department)
select * from cte_salaryperdepartment
where sumsalary>200000;

-- 9Q.Use a CTE to count how many employees were hired per year, and show only years with more than 3 hires
with cte_hiredate as(
select year(hiredate) as hiredate,count(*) as countofemployess from employees group by year(hiredate))
select * from cte_hiredate
where countofemployess>3;

-- 10Q.Write a CTE that gets the average salary per year of hire, and return only the years where the average salary was above 50,000
with cte_salaryperyear as(
select year(hiredate) as hiredate,avg(salary) as avgsalary from employees
group by hiredate)
select * from cte_salaryperyear
where avgsalary>50000;

-- 11Q.Use a CTE to count the number of employees in each department, and display departments with more than 2 employees.
with cte_noofemployees as(
select department,count(*) as countofemployess from employees group by department)
select * from cte_noofemployees where countofemployess>2;

-- 12Q.Write a CTE to count the number of employees by status (Working or Old Employee), and show statuses with less than 5 employees.
with cte_noofemployees as(
select status,count(*) as countofemployess from employees group by status)
select * from cte_noofemployees where countofemployess<5;

