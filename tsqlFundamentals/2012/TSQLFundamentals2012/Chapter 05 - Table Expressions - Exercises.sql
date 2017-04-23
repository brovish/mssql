---------------------------------------------------------------------
-- Microsoft SQL Server 2012 T-SQL Fundamentals
-- Chapter 05 - Table Expressions
-- Exercises
-- © Itzik Ben-Gan 
---------------------------------------------------------------------

-- 1-1
-- Write a query that returns the maximum order date for each employee
-- Tables involved: TSQL2012 database, Sales.Orders table

--Desired output
empid       maxorderdate
----------- -----------------------
3           2008-04-30 00:00:00.000
6           2008-04-23 00:00:00.000
9           2008-04-29 00:00:00.000
7           2008-05-06 00:00:00.000
1           2008-05-06 00:00:00.000
4           2008-05-06 00:00:00.000
2           2008-05-05 00:00:00.000
5           2008-04-22 00:00:00.000
8           2008-05-06 00:00:00.000

(9 row(s) affected)

-- 1-2
-- Encapsulate the query from exercise 1-1 in a derived table
-- Write a join query between the derived table and the Sales.Orders
-- table to return the Sales.Orders with the maximum order date for 
-- each employee
-- Tables involved: Sales.Orders

-- Desired output:
empid       orderdate               orderid     custid
----------- ----------------------- ----------- -----------
9           2008-04-29 00:00:00.000 11058       6
8           2008-05-06 00:00:00.000 11075       68
7           2008-05-06 00:00:00.000 11074       73
6           2008-04-23 00:00:00.000 11045       10
5           2008-04-22 00:00:00.000 11043       74
4           2008-05-06 00:00:00.000 11076       9
3           2008-04-30 00:00:00.000 11063       37
2           2008-05-05 00:00:00.000 11073       58
2           2008-05-05 00:00:00.000 11070       44
1           2008-05-06 00:00:00.000 11077       65

(10 row(s) affected)

-- 2-1
-- Write a query that calculates a row number for each order
-- based on orderdate, orderid ordering
-- Tables involved: Sales.Orders

-- Desired output:
orderid     orderdate               custid      empid       rownum
----------- ----------------------- ----------- ----------- -------
10248       2006-07-04 00:00:00.000 85          5           1
10249       2006-07-05 00:00:00.000 79          6           2
10250       2006-07-08 00:00:00.000 34          4           3
10251       2006-07-08 00:00:00.000 84          3           4
10252       2006-07-09 00:00:00.000 76          4           5
10253       2006-07-10 00:00:00.000 34          3           6
10254       2006-07-11 00:00:00.000 14          5           7
10255       2006-07-12 00:00:00.000 68          9           8
10256       2006-07-15 00:00:00.000 88          3           9
10257       2006-07-16 00:00:00.000 35          4           10
...

(830 row(s) affected)

-- 2-2
-- Write a query that returns rows with row numbers 11 through 20
-- based on the row number definition in exercise 2-1
-- Use a CTE to encapsulate the code from exercise 2-1
-- Tables involved: Sales.Orders

-- Desired output:
orderid     orderdate               custid      empid       rownum
----------- ----------------------- ----------- ----------- -------
10258       2006-07-17 00:00:00.000 20          1           11
10259       2006-07-18 00:00:00.000 13          4           12
10260       2006-07-19 00:00:00.000 56          4           13
10261       2006-07-19 00:00:00.000 61          4           14
10262       2006-07-22 00:00:00.000 65          8           15
10263       2006-07-23 00:00:00.000 20          9           16
10264       2006-07-24 00:00:00.000 24          6           17
10265       2006-07-25 00:00:00.000 7           2           18
10266       2006-07-26 00:00:00.000 87          3           19
10267       2006-07-29 00:00:00.000 25          4           20

(10 row(s) affected)

-- 3 (Optional, Advanced)
-- Write a solution using a recursive CTE that returns the 
-- management chain leading to Zoya Dolgopyatova (employee ID 9)
-- Tables involved: HR.Employees

-- Desired output:
empid       mgrid       firstname  lastname
----------- ----------- ---------- --------------------
9           5           Zoya       Dolgopyatova
5           2           Sven       Buck
2           1           Don        Funk
1           NULL        Sara       Davis

(4 row(s) affected)

-- 4-1
-- Create a view that returns the total qty
-- for each employee and year
-- Tables involved: Sales.Orders and Sales.OrderDetails

-- Desired output when running:
-- SELECT * FROM  Sales.VEmpOrders ORDER BY empid, orderyear
empid       orderyear   qty
----------- ----------- -----------
1           2006        1620
1           2007        3877
1           2008        2315
2           2006        1085
2           2007        2604
2           2008        2366
3           2006        940
3           2007        4436
3           2008        2476
4           2006        2212
4           2007        5273
4           2008        2313
5           2006        778
5           2007        1471
5           2008        787
6           2006        963
6           2007        1738
6           2008        826
7           2006        485
7           2007        2292
7           2008        1877
8           2006        923
8           2007        2843
8           2008        2147
9           2006        575
9           2007        955
9           2008        1140

(27 row(s) affected)

-- 4-2 (Optional, Advanced)
-- Write a query against Sales.VEmpOrders
-- that returns the running qty for each employee and year
-- Tables involved: TSQL2012 database, Sales.VEmpOrders view

-- Desired output:
empid       orderyear   qty         runqty
----------- ----------- ----------- -----------
1           2006        1620        1620
1           2007        3877        5497
1           2008        2315        7812
2           2006        1085        1085
2           2007        2604        3689
2           2008        2366        6055
3           2006        940         940
3           2007        4436        5376
3           2008        2476        7852
4           2006        2212        2212
4           2007        5273        7485
4           2008        2313        9798
5           2006        778         778
5           2007        1471        2249
5           2008        787         3036
6           2006        963         963
6           2007        1738        2701
6           2008        826         3527
7           2006        485         485
7           2007        2292        2777
7           2008        1877        4654
8           2006        923         923
8           2007        2843        3766
8           2008        2147        5913
9           2006        575         575
9           2007        955         1530
9           2008        1140        2670

(27 row(s) affected)

-- 5-1
-- Create an inline function that accepts as inputs
-- a supplier id (@supid AS INT), 
-- and a requested number of products (@n AS INT)
-- The function should return @n products with the highest unit prices
-- that are supplied by the given supplier id
-- Tables involved: Production.Products

-- Desired output when issuing the following query:
-- SELECT * FROM Production.TopProducts(5, 2)

productid   productname                              unitprice
----------- ---------------------------------------- ---------------------
12          Product OSFNS                            38.00
11          Product QMVUN                            21.00

(2 row(s) affected)

-- 5-2
-- Using the CROSS APPLY operator
-- and the function you created in exercise 5-1,
-- return, for each supplier, the two most expensive products

-- Desired output 
supplierid  companyname     productid   productname     unitprice
----------- --------------- ----------- --------------- ----------
8           Supplier BWGYE  20          Product QHFFP   81.00
8           Supplier BWGYE  68          Product TBTBL   12.50
20          Supplier CIYNM  43          Product ZZZHR   46.00
20          Supplier CIYNM  44          Product VJIEO   19.45
23          Supplier ELCRN  49          Product FPYPN   20.00
23          Supplier ELCRN  76          Product JYGFE   18.00
5           Supplier EQPNC  12          Product OSFNS   38.00
5           Supplier EQPNC  11          Product QMVUN   21.00
...

(55 row(s) affected)

-- When you’re done, run the following code for cleanup:
IF OBJECT_ID('Sales.VEmpOrders') IS NOT NULL
  DROP VIEW Sales.VEmpOrders;
IF OBJECT_ID('Production.TopProducts') IS NOT NULL
  DROP FUNCTION Production.TopProducts;
