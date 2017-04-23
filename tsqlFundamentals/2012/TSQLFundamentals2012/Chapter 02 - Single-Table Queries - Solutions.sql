---------------------------------------------------------------------
-- Microsoft SQL Server 2012 T-SQL Fundamentals
-- Chapter 02 - Single-Table Queries
-- Solutions
-- © Itzik Ben-Gan 
---------------------------------------------------------------------

-- 1 
-- Return orders placed on June 2007
-- Tables involved: TSQL2012 database, Sales.Orders table

-- Desired output:
orderid     orderdate               custid      empid
----------- ----------------------- ----------- -----------
10555       2007-06-02 00:00:00.000 71          6
10556       2007-06-03 00:00:00.000 73          2
10557       2007-06-03 00:00:00.000 44          9
10558       2007-06-04 00:00:00.000 4           1
10559       2007-06-05 00:00:00.000 7           6
10560       2007-06-06 00:00:00.000 25          8
10561       2007-06-06 00:00:00.000 24          2
10562       2007-06-09 00:00:00.000 66          1
10563       2007-06-10 00:00:00.000 67          2
10564       2007-06-10 00:00:00.000 65          4
10565       2007-06-11 00:00:00.000 51          8
10566       2007-06-12 00:00:00.000 7           9
10567       2007-06-12 00:00:00.000 37          1
10568       2007-06-13 00:00:00.000 29          3
10569       2007-06-16 00:00:00.000 65          5
10570       2007-06-17 00:00:00.000 51          3
10571       2007-06-17 00:00:00.000 20          8
10572       2007-06-18 00:00:00.000 5           3
10573       2007-06-19 00:00:00.000 3           7
10574       2007-06-19 00:00:00.000 82          4
10575       2007-06-20 00:00:00.000 52          5
10576       2007-06-23 00:00:00.000 80          3
10577       2007-06-23 00:00:00.000 82          9
10578       2007-06-24 00:00:00.000 11          4
10579       2007-06-25 00:00:00.000 45          1
10580       2007-06-26 00:00:00.000 56          4
10581       2007-06-26 00:00:00.000 21          3
10582       2007-06-27 00:00:00.000 6           3
10583       2007-06-30 00:00:00.000 87          2
10584       2007-06-30 00:00:00.000 7           4

(30 row(s) affected)

-- Solution
USE TSQL2012;

SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE orderdate >= '20070601' 
  AND orderdate < '20070701';

-- 2
-- Return orders placed on the last day of the month
-- Tables involved: Sales.Orders table

-- Desired output:
orderid     orderdate               custid      empid
----------- ----------------------- ----------- -----------
10269       2006-07-31 00:00:00.000 89          5
10317       2006-09-30 00:00:00.000 48          6
10343       2006-10-31 00:00:00.000 44          4
10399       2006-12-31 00:00:00.000 83          8
10432       2007-01-31 00:00:00.000 75          3
10460       2007-02-28 00:00:00.000 24          8
10461       2007-02-28 00:00:00.000 46          1
10490       2007-03-31 00:00:00.000 35          7
10491       2007-03-31 00:00:00.000 28          8
10522       2007-04-30 00:00:00.000 44          4
10583       2007-06-30 00:00:00.000 87          2
10584       2007-06-30 00:00:00.000 7           4
10616       2007-07-31 00:00:00.000 32          1
10617       2007-07-31 00:00:00.000 32          4
10686       2007-09-30 00:00:00.000 59          2
10687       2007-09-30 00:00:00.000 37          9
10725       2007-10-31 00:00:00.000 21          4
10806       2007-12-31 00:00:00.000 84          3
10807       2007-12-31 00:00:00.000 27          4
10987       2008-03-31 00:00:00.000 19          8
10988       2008-03-31 00:00:00.000 65          3
10989       2008-03-31 00:00:00.000 61          2
11060       2008-04-30 00:00:00.000 27          2
11061       2008-04-30 00:00:00.000 32          4
11062       2008-04-30 00:00:00.000 66          4
11063       2008-04-30 00:00:00.000 37          3

(26 row(s) affected)

-- Solution

-- in SQL Server 2012
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE orderdate = EOMONTH(orderdate);

-- pre-SQL Server 2012 (advanced)
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE orderdate = DATEADD(month, DATEDIFF(month, '19991231', orderdate), '19991231');

-- 3 
-- Return employees with last name containing the letter 'a' twice or more
-- Tables involved: HR.Employees table

-- Desired output:
empid       firstname  lastname
----------- ---------- --------------------
9           Zoya       Dolgopyatova

(1 row(s) affected)

-- Solution
SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname LIKE '%a%a%';

-- 4 
-- Return orders with total value(qty*unitprice) greater than 10000
-- sorted by total value
-- Tables involved: Sales.OrderDetails table

-- Desired output:
orderid     totalvalue
----------- ---------------------
10865       17250.00
11030       16321.90
10981       15810.00
10372       12281.20
10424       11493.20
10817       11490.70
10889       11380.00
10417       11283.20
10897       10835.24
10353       10741.60
10515       10588.50
10479       10495.60
10540       10191.70
10691       10164.80

(14 row(s) affected)

-- Solution
SELECT orderid, SUM(qty*unitprice) AS totalvalue
FROM Sales.OrderDetails
GROUP BY orderid
HAVING SUM(qty*unitprice) > 10000
ORDER BY totalvalue DESC;

-- 5 
-- Return the three ship countries with the highest average freight in 2007
-- Tables involved: Sales.Orders table

-- Desired output:
shipcountry     avgfreight
--------------- ---------------------
Austria         178.3642
Switzerland     117.1775
Sweden          105.16

(3 row(s) affected)

-- Solution
SELECT TOP (3) shipcountry, AVG(freight) AS avgfreight
FROM Sales.Orders
WHERE orderdate >= '20070101' AND orderdate < '20080101'
GROUP BY shipcountry
ORDER BY avgfreight DESC;

-- in SQL Server 2012
SELECT shipcountry, AVG(freight) AS avgfreight
FROM Sales.Orders
WHERE orderdate >= '20070101' AND orderdate < '20080101'
GROUP BY shipcountry
ORDER BY avgfreight DESC
OFFSET 0 ROWS FETCH FIRST 3 ROWS ONLY;

-- 6 
-- Calculate row numbers for orders
-- based on order date ordering (using order id as tiebreaker)
-- for each customer separately
-- Tables involved: Sales.Orders table

-- Desired output:
custid      orderdate               orderid     rownum
----------- ----------------------- ----------- --------------------
1           2007-08-25 00:00:00.000 10643       1
1           2007-10-03 00:00:00.000 10692       2
1           2007-10-13 00:00:00.000 10702       3
1           2008-01-15 00:00:00.000 10835       4
1           2008-03-16 00:00:00.000 10952       5
1           2008-04-09 00:00:00.000 11011       6
2           2006-09-18 00:00:00.000 10308       1
2           2007-08-08 00:00:00.000 10625       2
2           2007-11-28 00:00:00.000 10759       3
2           2008-03-04 00:00:00.000 10926       4
...

(830 row(s) affected)

-- Solution
SELECT custid, orderdate, orderid,
  ROW_NUMBER() OVER(PARTITION BY custid ORDER BY orderdate, orderid) AS rownum
FROM Sales.Orders
ORDER BY custid, rownum;

-- 7
-- Figure out and return for each employee the gender based on the title of courtesy
-- Ms., Mrs. - Female, Mr. - Male, Dr. - Unknown
-- Tables involved: HR.Employees table

-- Desired output:
empid       firstname  lastname             titleofcourtesy           gender
----------- ---------- -------------------- ------------------------- -------
1           Sara       Davis                Ms.                       Female 
2           Don        Funk                 Dr.                       Unknown
3           Judy       Lew                  Ms.                       Female 
4           Yael       Peled                Mrs.                      Female 
5           Sven       Buck                 Mr.                       Male   
6           Paul       Suurs                Mr.                       Male   
7           Russell    King                 Mr.                       Male   
8           Maria      Cameron              Ms.                       Female 
9           Zoya       Dolgopyatova         Ms.                       Female 

(9 row(s) affected)

-- Solutions
SELECT empid, firstname, lastname, titleofcourtesy,
  CASE titleofcourtesy
    WHEN 'Ms.'  THEN 'Female'
    WHEN 'Mrs.' THEN 'Female'
    WHEN 'Mr.'  THEN 'Male'
    ELSE             'Unknown'
  END AS gender
FROM HR.Employees;

SELECT empid, firstname, lastname, titleofcourtesy,
  CASE 
    WHEN titleofcourtesy IN('Ms.', 'Mrs.') THEN 'Female'
    WHEN titleofcourtesy = 'Mr.'           THEN 'Male'
    ELSE                                        'Unknown'
  END AS gender
FROM HR.Employees;

-- 8 (advanced, optional)
-- Return for each customer the customer ID and region
-- sort the rows in the output by region
-- having NULLs sort last (after non-NULL values)
-- Note that the default in T-SQL is that NULL sort first
-- Tables involved: Sales.Customers table

-- Desired output:
custid      region
----------- ---------------
55          AK
10          BC
42          BC
45          CA
37          Co. Cork
33          DF
71          ID
38          Isle of Wight
46          Lara
78          MT
...
1           NULL
2           NULL
3           NULL
4           NULL
5           NULL
6           NULL
7           NULL
8           NULL
9           NULL
11          NULL
...

(91 row(s) affected)

-- Solution
SELECT custid, region
FROM Sales.Customers
ORDER BY
  CASE WHEN region IS NULL THEN 1 ELSE 0 END, region;
